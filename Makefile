.PHONY: build app dmg install uninstall run clean

APP_NAME := Focnotes
VERSION := 26.7.0
BUILD_DIR := build
APP_DIR := $(BUILD_DIR)/$(APP_NAME).app
DMG_PATH := $(BUILD_DIR)/$(APP_NAME)-$(VERSION).dmg
DMG_STAGE := $(BUILD_DIR)/dmg
EXECUTABLE := .build/apple/Products/Release/$(APP_NAME)

build:
	swift build -c release --arch arm64 --arch x86_64

app: build
	rm -rf "$(APP_DIR)"
	mkdir -p "$(APP_DIR)/Contents/MacOS"
	mkdir -p "$(APP_DIR)/Contents/Resources"
	mkdir -p "$(APP_DIR)/Contents/Resources/AppIcon.iconset"
	cp "$(EXECUTABLE)" "$(APP_DIR)/Contents/MacOS/$(APP_NAME)"
	"$(EXECUTABLE)" --export-icon-dir "$(APP_DIR)/Contents/Resources/AppIcon.iconset"
	iconutil -c icns "$(APP_DIR)/Contents/Resources/AppIcon.iconset" -o "$(APP_DIR)/Contents/Resources/AppIcon.icns"
	rm -rf "$(APP_DIR)/Contents/Resources/AppIcon.iconset"
	printf '%s\n' \
	'<?xml version="1.0" encoding="UTF-8"?>' \
	'<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' \
	'<plist version="1.0">' \
	'<dict>' \
	'  <key>CFBundleExecutable</key>' \
	'  <string>$(APP_NAME)</string>' \
	'  <key>CFBundleIdentifier</key>' \
	'  <string>com.local.focnotes</string>' \
	'  <key>CFBundleName</key>' \
	'  <string>$(APP_NAME)</string>' \
	'  <key>CFBundleShortVersionString</key>' \
	'  <string>$(VERSION)</string>' \
	'  <key>CFBundleVersion</key>' \
	'  <string>$(VERSION)</string>' \
	'  <key>CFBundleIconFile</key>' \
	'  <string>AppIcon</string>' \
	'  <key>CFBundlePackageType</key>' \
	'  <string>APPL</string>' \
	'  <key>LSMinimumSystemVersion</key>' \
	'  <string>13.0</string>' \
	'  <key>LSUIElement</key>' \
	'  <true/>' \
	'  <key>LSMultipleInstancesProhibited</key>' \
	'  <true/>' \
	'  <key>CFBundleDocumentTypes</key>' \
	'  <array>' \
	'    <dict>' \
	'      <key>CFBundleTypeName</key>' \
	'      <string>Text Document</string>' \
	'      <key>CFBundleTypeRole</key>' \
	'      <string>Editor</string>' \
	'      <key>LSItemContentTypes</key>' \
	'      <array>' \
	'        <string>public.text</string>' \
	'        <string>net.daringfireball.markdown</string>' \
	'      </array>' \
	'    </dict>' \
	'  </array>' \
	'  <key>NSHighResolutionCapable</key>' \
	'  <true/>' \
	'</dict>' \
	'</plist>' > "$(APP_DIR)/Contents/Info.plist"
	printf '%s\n' \
	'#!/bin/sh' \
	'TARGET="$$(readlink "$$0" 2>/dev/null || printf "%s" "$$0")"' \
	'APP="$$(cd "$$(dirname "$$TARGET")/../.." && pwd)"' \
	'if [ "$${#}" -eq 0 ]; then' \
	'  exec open -a "$$APP"' \
	'fi' \
	'case "$$1" in' \
	'  /*) FILE="$$1" ;;' \
	'  *) FILE="$$PWD/$$1" ;;' \
	'esac' \
	'if [ ! -e "$$FILE" ]; then : > "$$FILE" || exit 1; fi' \
	'exec open -a "$$APP" "$$FILE"' > "$(APP_DIR)/Contents/MacOS/foc"
	chmod +x "$(APP_DIR)/Contents/MacOS/foc"
	codesign --force --deep --sign - "$(APP_DIR)"

dmg: app
	rm -rf "$(DMG_STAGE)" "$(DMG_PATH)"
	mkdir -p "$(DMG_STAGE)"
	ditto "$(APP_DIR)" "$(DMG_STAGE)/$(APP_NAME).app"
	ln -s /Applications "$(DMG_STAGE)/Applications"
	hdiutil create -volname "$(APP_NAME)" -srcfolder "$(DMG_STAGE)" -ov -format UDZO "$(DMG_PATH)"
	rm -rf "$(DMG_STAGE)"

install: app
	rm -rf "/Applications/$(APP_NAME).app"
	cp -R "$(APP_DIR)" "/Applications/$(APP_NAME).app"

uninstall:
	rm -f "/usr/local/bin/foc"
	rm -rf "/Applications/$(APP_NAME).app"

run: app
	open "$(APP_DIR)"

clean:
	rm -rf .build "$(BUILD_DIR)"
