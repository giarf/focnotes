import AppKit
import Carbon
import Markdown

private extension NSAttributedString.Key {
    static let focnotesInlineCode = NSAttributedString.Key("FocnotesInlineCode")
}

private extension NSColor {
    convenience init?(hex: String) {
        var value = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if value.hasPrefix("#") { value.removeFirst() }
        guard value.count == 6, let number = UInt64(value, radix: 16) else { return nil }
        self.init(
            srgbRed: CGFloat((number >> 16) & 0xFF) / 255,
            green: CGFloat((number >> 8) & 0xFF) / 255,
            blue: CGFloat(number & 0xFF) / 255,
            alpha: 1
        )
    }

    var hexValue: String {
        guard let rgb = usingColorSpace(.sRGB) else { return "#FFD61F" }
        return String(
            format: "#%02X%02X%02X",
            Int(round(rgb.redComponent * 255)),
            Int(round(rgb.greenComponent * 255)),
            Int(round(rgb.blueComponent * 255))
        )
    }

    var rgbComponents255: (red: Int, green: Int, blue: Int) {
        guard let rgb = usingColorSpace(.sRGB) else { return (255, 214, 31) }
        return (
            Int(round(rgb.redComponent * 255)),
            Int(round(rgb.greenComponent * 255)),
            Int(round(rgb.blueComponent * 255))
        )
    }

    var isDark: Bool {
        guard let rgb = usingColorSpace(.sRGB) else { return false }
        let luminance = 0.2126 * rgb.redComponent + 0.7152 * rgb.greenComponent + 0.0722 * rgb.blueComponent
        return luminance < 0.48
    }
}

private enum NoteTheme: String, CaseIterable {
    case yellow
    case dark
    case cream
    case sage
    case sky
    case lavender
    case coral

    var title: String {
        switch self {
        case .yellow: return "Amarillo"
        case .dark: return "Oscuro"
        case .cream: return "Crema"
        case .sage: return "Salvia"
        case .sky: return "Cielo"
        case .lavender: return "Lavanda"
        case .coral: return "Coral"
        }
    }

    var color: NSColor {
        switch self {
        case .yellow: return NSColor(hex: "#FFD61F")!
        case .dark: return NSColor(hex: "#202127")!
        case .cream: return NSColor(hex: "#F3E7CF")!
        case .sage: return NSColor(hex: "#CFE5D2")!
        case .sky: return NSColor(hex: "#CAE4F7")!
        case .lavender: return NSColor(hex: "#DED5F7")!
        case .coral: return NSColor(hex: "#F6D0C6")!
        }
    }
}

private enum FocnotesPalette {
    static var paper: NSColor { AppPreferences.noteColor.withAlphaComponent(AppPreferences.noteOpacity / 100) }
    static var ink: NSColor { paper.isDark ? NSColor(white: 0.96, alpha: 1) : NSColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1) }
    static var mutedInk: NSColor { ink.withAlphaComponent(0.58) }
    static var faintInk: NSColor { ink.withAlphaComponent(0.36) }
    static var accent: NSColor {
        AppPreferences.accentColor ?? (paper.isDark ? NSColor(hex: "#A99BFF")! : NSColor(hex: "#5C40F2")!)
    }
    static var accentBlue: NSColor { paper.isDark ? NSColor(hex: "#77B7FF")! : NSColor(red: 0.02, green: 0.33, blue: 0.82, alpha: 1) }
    static var code: NSColor { accent }
    static var highlight: NSColor { paper.isDark ? NSColor(hex: "#DCD7A0")! : NSColor(red: 1.0, green: 0.95, blue: 0.63, alpha: 1) }
}

private enum AppPreferences {
    static let alwaysOnTopKey = "alwaysOnTop"
    static let showOnAllSpacesKey = "showOnAllSpaces"
    static let editorFontSizeKey = "editorFontSize"
    static let noteOpacityKey = "noteOpacity"
    static let blurIntensityKey = "blurIntensity"
    static let noteThemeKey = "noteTheme"
    static let customNoteColorKey = "customNoteColor"
    static let accentColorKey = "accentColor"
    static let focusShortcutKeyCodeKey = "focusShortcutKeyCode"
    static let focusShortcutModifiersKey = "focusShortcutModifiers"
    static let focusShortcutLabelKey = "focusShortcutLabel"
    static let reopenLastNoteKey = "reopenLastNote"
    static let changedNotification = Notification.Name("FocnotesPreferencesChanged")

    static var alwaysOnTop: Bool {
        UserDefaults.standard.object(forKey: alwaysOnTopKey) as? Bool ?? true
    }

    static var showOnAllSpaces: Bool {
        UserDefaults.standard.object(forKey: showOnAllSpacesKey) as? Bool ?? true
    }

    static var reopenLastNote: Bool {
        UserDefaults.standard.object(forKey: reopenLastNoteKey) as? Bool ?? true
    }

    static var editorFontSize: CGFloat {
        let value = UserDefaults.standard.double(forKey: editorFontSizeKey)
        return [13, 15, 17].contains(value) ? CGFloat(value) : 15
    }

    static var noteOpacity: Double {
        guard UserDefaults.standard.object(forKey: noteOpacityKey) != nil else { return 100 }
        return min(max(UserDefaults.standard.double(forKey: noteOpacityKey), 20), 100)
    }

    static var blurIntensity: Double {
        guard UserDefaults.standard.object(forKey: blurIntensityKey) != nil else { return 100 }
        return min(max(UserDefaults.standard.double(forKey: blurIntensityKey), 20), 100)
    }

    static var noteTheme: NoteTheme? {
        NoteTheme(rawValue: UserDefaults.standard.string(forKey: noteThemeKey) ?? NoteTheme.yellow.rawValue)
    }

    static var customNoteColor: NSColor {
        NSColor(hex: UserDefaults.standard.string(forKey: customNoteColorKey) ?? "#FFD61F") ?? NoteTheme.yellow.color
    }

    static var noteColor: NSColor {
        noteTheme?.color ?? customNoteColor
    }

    static var accentColor: NSColor? {
        guard let hex = UserDefaults.standard.string(forKey: accentColorKey) else { return nil }
        return NSColor(hex: hex)
    }

    static var focusShortcut: KeyboardShortcut {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: focusShortcutKeyCodeKey) != nil else {
            return .defaultFocusShortcut
        }
        return KeyboardShortcut(
            keyCode: UInt32(defaults.integer(forKey: focusShortcutKeyCodeKey)),
            modifiers: UInt32(defaults.integer(forKey: focusShortcutModifiersKey)),
            keyLabel: defaults.string(forKey: focusShortcutLabelKey) ?? "N"
        )
    }

    static func set(_ value: Bool, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
        NotificationCenter.default.post(name: changedNotification, object: nil)
    }

    static func setEditorFontSize(_ value: CGFloat) {
        UserDefaults.standard.set(Double(value), forKey: editorFontSizeKey)
        NotificationCenter.default.post(name: changedNotification, object: nil)
    }

    static func setNoteOpacity(_ value: Double) {
        UserDefaults.standard.set(min(max(value, 20), 100), forKey: noteOpacityKey)
        NotificationCenter.default.post(name: changedNotification, object: nil)
    }

    static func setBlurIntensity(_ value: Double) {
        UserDefaults.standard.set(min(max(value, 20), 100), forKey: blurIntensityKey)
        NotificationCenter.default.post(name: changedNotification, object: nil)
    }

    static func setNoteTheme(_ theme: NoteTheme?) {
        UserDefaults.standard.set(theme?.rawValue ?? "custom", forKey: noteThemeKey)
        NotificationCenter.default.post(name: changedNotification, object: nil)
    }

    static func setCustomNoteColor(_ color: NSColor) {
        UserDefaults.standard.set(color.hexValue, forKey: customNoteColorKey)
        UserDefaults.standard.set("custom", forKey: noteThemeKey)
        NotificationCenter.default.post(name: changedNotification, object: nil)
    }

    static func setAccentColor(_ color: NSColor) {
        UserDefaults.standard.set(color.hexValue, forKey: accentColorKey)
        NotificationCenter.default.post(name: changedNotification, object: nil)
    }


    static func setFocusShortcut(_ shortcut: KeyboardShortcut) {
        UserDefaults.standard.set(Int(shortcut.keyCode), forKey: focusShortcutKeyCodeKey)
        UserDefaults.standard.set(Int(shortcut.modifiers), forKey: focusShortcutModifiersKey)
        UserDefaults.standard.set(shortcut.keyLabel, forKey: focusShortcutLabelKey)
        NotificationCenter.default.post(name: changedNotification, object: nil)
    }
}

private struct KeyboardShortcut {
    let keyCode: UInt32
    let modifiers: UInt32
    let keyLabel: String

    static let defaultFocusShortcut = KeyboardShortcut(
        keyCode: UInt32(kVK_ANSI_N),
        modifiers: UInt32(cmdKey | shiftKey),
        keyLabel: "N"
    )

    var displayValue: String {
        var value = ""
        if modifiers & UInt32(controlKey) != 0 { value += "⌃" }
        if modifiers & UInt32(optionKey) != 0 { value += "⌥" }
        if modifiers & UInt32(shiftKey) != 0 { value += "⇧" }
        if modifiers & UInt32(cmdKey) != 0 { value += "⌘" }
        return value + keyLabel.uppercased()
    }
}

private func sealIcon(size: CGFloat, template: Bool) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    let scale = size / 64
    func rect(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> NSRect {
        NSRect(x: x * scale, y: y * scale, width: width * scale, height: height * scale)
    }

    if !template {
        FocnotesPalette.paper.setFill()
        NSBezierPath(roundedRect: rect(2, 2, 60, 60), xRadius: 14 * scale, yRadius: 14 * scale).fill()
    }

    let ink = template ? NSColor.black : FocnotesPalette.ink
    if template {
        ink.setStroke()
        let outline = NSBezierPath()
        outline.move(to: NSPoint(x: 19 * scale, y: 41 * scale))
        outline.curve(
            to: NSPoint(x: 45 * scale, y: 41 * scale),
            controlPoint1: NSPoint(x: 16 * scale, y: 58 * scale),
            controlPoint2: NSPoint(x: 48 * scale, y: 58 * scale)
        )
        outline.curve(
            to: NSPoint(x: 32 * scale, y: 12 * scale),
            controlPoint1: NSPoint(x: 50 * scale, y: 25 * scale),
            controlPoint2: NSPoint(x: 43 * scale, y: 12 * scale)
        )
        outline.curve(
            to: NSPoint(x: 19 * scale, y: 41 * scale),
            controlPoint1: NSPoint(x: 21 * scale, y: 12 * scale),
            controlPoint2: NSPoint(x: 14 * scale, y: 25 * scale)
        )
        outline.lineWidth = max(1.5, 4 * scale)
        outline.lineJoinStyle = .round
        outline.lineCapStyle = .round
        outline.stroke()
    } else {
        ink.setFill()
        NSBezierPath(ovalIn: rect(13, 11, 38, 43)).fill()
        NSBezierPath(ovalIn: rect(10, 35, 14, 17)).fill()
        NSBezierPath(ovalIn: rect(40, 35, 14, 17)).fill()
    }

    let face = template ? NSColor.clear : FocnotesPalette.highlight
    if !template {
        face.setFill()
        NSBezierPath(ovalIn: rect(17, 16, 30, 32)).fill()
    }

    ink.setFill()
    NSBezierPath(ovalIn: rect(23, 34, 4, 5)).fill()
    NSBezierPath(ovalIn: rect(37, 34, 4, 5)).fill()
    NSBezierPath(ovalIn: rect(29, 25, 6, 5)).fill()

    ink.setStroke()
    for (x1, y1, x2, y2) in [(27, 26, 17, 28), (27, 23, 16, 21), (37, 26, 47, 28), (37, 23, 48, 21)] {
        let whisker = NSBezierPath()
        whisker.move(to: NSPoint(x: CGFloat(x1) * scale, y: CGFloat(y1) * scale))
        whisker.line(to: NSPoint(x: CGFloat(x2) * scale, y: CGFloat(y2) * scale))
        whisker.lineWidth = max(1, 1.5 * scale)
        whisker.lineCapStyle = .round
        whisker.stroke()
    }
    image.unlockFocus()
    image.isTemplate = template
    return image
}

private func exportSealIcons(to directory: String) {
    let sizes = [16, 32, 128, 256, 512]
    for size in sizes {
        for scale in [1, 2] {
            let pixels = size * scale
            let image = sealIcon(size: CGFloat(pixels), template: false)
            guard let data = image.tiffRepresentation,
                  let bitmap = NSBitmapImageRep(data: data),
                  let png = bitmap.representation(using: .png, properties: [:]) else { continue }
            let suffix = scale == 2 ? "@2x" : ""
            let url = URL(fileURLWithPath: directory).appendingPathComponent("icon_\(size)x\(size)\(suffix).png")
            try? png.write(to: url)
        }
    }
}

final class FloatingNotePanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

final class PointingHandButton: NSButton {
    override func resetCursorRects() {
        super.resetCursorRects()
        addCursorRect(bounds, cursor: .pointingHand)
    }
}

final class MarkdownTextView: NSTextView, NSViewToolTipOwner {
    private struct FencedCodeBlock {
        let range: NSRange
        let codeRange: NSRange
    }

    var checkboxClicked: ((NSRange) -> Void)?
    private var linkToolTips: [NSView.ToolTipTag: String] = [:]
    private var hoverTrackingArea: NSTrackingArea?

    override func insertText(_ insertString: Any, replacementRange: NSRange) {
        let insertedText: String
        if let string = insertString as? String {
            insertedText = string
        } else if let attributedString = insertString as? NSAttributedString {
            insertedText = attributedString.string
        } else {
            super.insertText(insertString, replacementRange: replacementRange)
            return
        }

        let pairs = ["(": ")", "[": "]", "{": "}"]
        let range = replacementRange.location == NSNotFound ? selectedRange() : replacementRange
        if let closing = pairs[insertedText], NSMaxRange(range) <= (string as NSString).length {
            let selectedText = (string as NSString).substring(with: range)
            super.insertText(insertedText + selectedText + closing, replacementRange: range)
            setSelectedRange(NSRange(location: range.location + 1, length: range.length))
            return
        }

        if pairs.values.contains(insertedText), range.length == 0 {
            let source = string as NSString
            if range.location < source.length,
               source.substring(with: NSRange(location: range.location, length: 1)) == insertedText {
                setSelectedRange(NSRange(location: range.location + 1, length: 0))
                return
            }
        }

        super.insertText(insertString, replacementRange: replacementRange)
    }

    private func selectionTouches(_ range: NSRange) -> Bool {
        selectedRanges.map(\.rangeValue).contains { selection in
            if selection.length > 0 {
                return NSIntersectionRange(selection, range).length > 0
            }
            return selection.location >= range.location && selection.location < NSMaxRange(range)
        }
    }

    private func selectionTouchesLink(_ range: NSRange) -> Bool {
        selectedRanges.map(\.rangeValue).contains { selection in
            if selection.length > 0 {
                return NSIntersectionRange(selection, range).length > 0
            }
            return selection.location >= range.location && selection.location <= NSMaxRange(range)
        }
    }

    private func fencedCodeBlocks(in source: NSString) -> [FencedCodeBlock] {
        let openingPattern = "^[ \\t]{0,3}(`{3,}|~{3,})[^\\r\\n]*(?:\\r?\\n)"
        guard let openingExpression = try? NSRegularExpression(
            pattern: openingPattern,
            options: .anchorsMatchLines
        ) else { return [] }

        var blocks: [FencedCodeBlock] = []
        var searchLocation = 0
        while searchLocation < source.length,
              let opening = openingExpression.firstMatch(
                in: source as String,
                range: NSRange(location: searchLocation, length: source.length - searchLocation)
              ) {
            let fenceRange = opening.range(at: 1)
            let fenceCharacter = source.substring(with: NSRange(location: fenceRange.location, length: 1))
            let escapedCharacter = NSRegularExpression.escapedPattern(for: fenceCharacter)
            let closingPattern = "^[ \\t]{0,3}\(escapedCharacter){\(fenceRange.length),}[ \\t]*(?:\\r?\\n|$)"
            guard let closingExpression = try? NSRegularExpression(
                pattern: closingPattern,
                options: .anchorsMatchLines
            ), let closing = closingExpression.firstMatch(
                in: source as String,
                range: NSRange(
                    location: NSMaxRange(opening.range),
                    length: source.length - NSMaxRange(opening.range)
                )
            ) else {
                searchLocation = NSMaxRange(opening.range)
                continue
            }

            blocks.append(FencedCodeBlock(
                range: NSRange(
                    location: opening.range.location,
                    length: NSMaxRange(closing.range) - opening.range.location
                ),
                codeRange: NSRange(
                    location: NSMaxRange(opening.range),
                    length: closing.range.location - NSMaxRange(opening.range)
                )
            ))
            searchLocation = NSMaxRange(closing.range)
        }
        return blocks
    }

    private func codeBlockRect(
        for block: FencedCodeBlock,
        layoutManager: NSLayoutManager,
        textContainer: NSTextContainer
    ) -> NSRect {
        let glyphRange = layoutManager.glyphRange(forCharacterRange: block.range, actualCharacterRange: nil)
        let glyphRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        let origin = textContainerOrigin
        let x = max(bounds.minX, origin.x - 5)
        return NSRect(
            x: x,
            y: glyphRect.minY + origin.y - 3,
            width: max(0, min(textContainer.size.width + 10, bounds.maxX - x)),
            height: max(24, glyphRect.height + 6)
        )
    }

    private func copyButtonRect(for blockRect: NSRect) -> NSRect {
        NSRect(x: blockRect.maxX - 25, y: blockRect.minY + 3, width: 20, height: 18)
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command,
              let key = event.charactersIgnoringModifiers?.lowercased() else {
            return super.performKeyEquivalent(with: event)
        }
        switch key {
        case "x":
            cut(nil)
        case "c":
            copy(nil)
        case "v":
            paste(nil)
        case "a":
            selectAll(nil)
        default:
            return super.performKeyEquivalent(with: event)
        }
        return true
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let hoverTrackingArea {
            removeTrackingArea(hoverTrackingArea)
        }
        let trackingArea = NSTrackingArea(
            rect: .zero,
            options: [.mouseMoved, .cursorUpdate, .activeInKeyWindow, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
        hoverTrackingArea = trackingArea
    }

    override func mouseMoved(with event: NSEvent) {
        if updateCodeCopyCursor(for: event) { return }
        if updateCheckboxCursor(for: event) { return }
        super.mouseMoved(with: event)
    }

    override func cursorUpdate(with event: NSEvent) {
        if updateCodeCopyCursor(for: event) { return }
        if updateCheckboxCursor(for: event) { return }
        super.cursorUpdate(with: event)
    }

    private func updateCodeCopyCursor(for event: NSEvent) -> Bool {
        guard let layoutManager, let textContainer else { return false }
        let point = convert(event.locationInWindow, from: nil)
        let source = string as NSString
        for block in fencedCodeBlocks(in: source) {
            let blockRect = codeBlockRect(for: block, layoutManager: layoutManager, textContainer: textContainer)
            if copyButtonRect(for: blockRect).contains(point) {
                NSCursor.pointingHand.set()
                return true
            }
        }
        return false
    }

    private func updateCheckboxCursor(for event: NSEvent) -> Bool {
        guard let layoutManager, let textContainer else { return false }
        let point = convert(event.locationInWindow, from: nil)
        let source = string as NSString
        let fullRange = NSRange(location: 0, length: source.length)
        guard let expression = try? NSRegularExpression(
            pattern: "(?m)^[ \\t]*([-*+] (\\[[ xX]\\]))(?=[ \\t])"
        ) else { return false }

        for result in expression.matches(in: string, range: fullRange) {
            let syntaxRange = result.range(at: 1)
            let interactionRange = NSRange(location: syntaxRange.location, length: syntaxRange.length + 1)
            guard !selectionTouches(interactionRange) else { continue }
            let glyphRange = layoutManager.glyphRange(
                forCharacterRange: result.range(at: 2),
                actualCharacterRange: nil
            )
            var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
            rect.origin.x += textContainerOrigin.x + 3
            rect.origin.y += textContainerOrigin.y + (rect.height - 14) / 2
            rect.size = NSSize(width: 14, height: 14)
            if rect.insetBy(dx: -5, dy: -3).contains(point) {
                NSCursor.pointingHand.set()
                return true
            }
        }
        return false
    }

    override func resetCursorRects() {
        super.resetCursorRects()
        removeAllToolTips()
        linkToolTips.removeAll()
        guard let layoutManager, let textContainer else { return }
        let source = string as NSString
        let fullRange = NSRange(location: 0, length: source.length)
        guard let expression = try? NSRegularExpression(
            pattern: "(?<!\\!)\\[([^\\]\\n]+)\\]\\(([^\\n)]*)\\)"
        ) else { return }

        expression.enumerateMatches(in: string, range: fullRange) { [weak self] result, _, _ in
            guard let self, let result, !selectionTouchesLink(result.range) else { return }
            let glyphRange = layoutManager.glyphRange(
                forCharacterRange: result.range(at: 1),
                actualCharacterRange: nil
            )
            var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
            rect.origin.x += textContainerOrigin.x
            rect.origin.y += textContainerOrigin.y
            addCursorRect(rect, cursor: .pointingHand)

            let destination = source.substring(with: result.range(at: 2))
            let tag = addToolTip(rect, owner: self, userData: nil)
            linkToolTips[tag] = "⌘ clic para abrir \(destination)"
        }

        let tasks = try? NSRegularExpression(
            pattern: "(?m)^[ \\t]*([-*+] (\\[[ xX]\\]))(?=[ \\t])"
        )
        tasks?.enumerateMatches(in: string, range: fullRange) { [weak self] result, _, _ in
            guard let self, let result else { return }
            let syntaxRange = result.range(at: 1)
            let separatorLength: Int
            if NSMaxRange(syntaxRange) < source.length {
                let character = source.character(at: NSMaxRange(syntaxRange))
                separatorLength = character == 0x20 || character == 0x09 ? 1 : 0
            } else {
                separatorLength = 0
            }
            let interactionRange = NSRange(
                location: syntaxRange.location,
                length: syntaxRange.length + separatorLength
            )
            guard !selectionTouches(interactionRange) else { return }

            let glyphRange = layoutManager.glyphRange(
                forCharacterRange: result.range(at: 2),
                actualCharacterRange: nil
            )
            var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
            rect.origin.x += textContainerOrigin.x + 3
            rect.origin.y += textContainerOrigin.y + (rect.height - 14) / 2
            rect.size = NSSize(width: 14, height: 14)
            addCursorRect(rect.insetBy(dx: -5, dy: -3), cursor: .pointingHand)
        }


        for block in fencedCodeBlocks(in: source) {
            let blockRect = codeBlockRect(for: block, layoutManager: layoutManager, textContainer: textContainer)
            let buttonRect = copyButtonRect(for: blockRect)
            addCursorRect(buttonRect, cursor: .pointingHand)
            let tag = addToolTip(buttonRect, owner: self, userData: nil)
            linkToolTips[tag] = "Copiar código"
        }
    }

    func view(
        _ view: NSView,
        stringForToolTip tag: NSView.ToolTipTag,
        point: NSPoint,
        userData data: UnsafeMutableRawPointer?
    ) -> String {
        linkToolTips[tag] ?? "⌘ clic para abrir enlace"
    }

    override func draw(_ dirtyRect: NSRect) {
        drawCodeBlockBackgrounds(in: dirtyRect)
        drawInlineCodeBackgrounds(in: dirtyRect)
        super.draw(dirtyRect)
        guard let layoutManager, let textContainer else { return }
        let source = string as NSString
        let fullRange = NSRange(location: 0, length: source.length)

        let tasks = try? NSRegularExpression(pattern: "(?m)^[ \\t]*([-*+] (\\[[ xX]\\]))(?=[ \\t])")
        tasks?.enumerateMatches(in: string, range: fullRange) { [weak self] result, _, _ in
            guard let self, let result else { return }
            let markerSyntaxRange = result.range(at: 1)
            let separatorLength: Int
            if NSMaxRange(markerSyntaxRange) < source.length {
                let character = source.character(at: NSMaxRange(markerSyntaxRange))
                separatorLength = character == 0x20 || character == 0x09 ? 1 : 0
            } else {
                separatorLength = 0
            }
            let interactionRange = NSRange(
                location: markerSyntaxRange.location,
                length: markerSyntaxRange.length + separatorLength
            )
            guard !selectionTouches(interactionRange) else { return }
            let markerRange = result.range(at: 2)
            let glyphRange = layoutManager.glyphRange(forCharacterRange: markerRange, actualCharacterRange: nil)
            var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
            rect.origin.x += textContainerOrigin.x + 3
            rect.origin.y += textContainerOrigin.y + (rect.height - 14) / 2
            rect.size = NSSize(width: 14, height: 14)
            guard dirtyRect.intersects(rect.insetBy(dx: -2, dy: -2)) else { return }

            let box = NSBezierPath(roundedRect: rect, xRadius: 3, yRadius: 3)
            FocnotesPalette.accent.setStroke()
            box.lineWidth = 1.5
            box.stroke()
            if source.substring(with: markerRange).lowercased() == "[x]" {
                FocnotesPalette.accent.setFill()
                box.fill()
                let check = NSBezierPath()
                check.move(to: NSPoint(x: rect.minX + 3, y: rect.midY))
                check.line(to: NSPoint(x: rect.minX + 6, y: rect.maxY - 3))
                check.line(to: NSPoint(x: rect.maxX - 2.5, y: rect.minY + 3))
                NSColor.white.setStroke()
                check.lineWidth = 1.7
                check.lineCapStyle = .round
                check.lineJoinStyle = .round
                check.stroke()
            }
        }

        let bullets = try? NSRegularExpression(pattern: "(?m)^[ \\t]*([-*+])(?=[ \\t]+(?!\\[[ xX]\\]))")
        bullets?.enumerateMatches(in: string, range: fullRange) { [weak self] result, _, _ in
            guard let self, let result else { return }
            let markerRange = result.range(at: 1)
            let syntaxRange = NSRange(location: markerRange.location, length: min(2, source.length - markerRange.location))
            guard !selectionTouches(syntaxRange) else { return }
            let glyphRange = layoutManager.glyphRange(forCharacterRange: markerRange, actualCharacterRange: nil)
            var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
            rect.origin.x += textContainerOrigin.x
            rect.origin.y += textContainerOrigin.y
            guard dirtyRect.intersects(rect.insetBy(dx: -2, dy: -2)) else { return }

            let radius = max(2, min(3, rect.width * 0.28))
            let dot = NSBezierPath(ovalIn: NSRect(
                x: rect.midX - radius,
                y: rect.midY - radius,
                width: radius * 2,
                height: radius * 2
            ))
            FocnotesPalette.accent.setFill()
            dot.fill()
        }

        drawCodeBlockCopyButtons(in: dirtyRect)
    }

    private func drawCodeBlockBackgrounds(in dirtyRect: NSRect) {
        guard let layoutManager, let textContainer else { return }
        let source = string as NSString
        for block in fencedCodeBlocks(in: source) {
            let rect = codeBlockRect(for: block, layoutManager: layoutManager, textContainer: textContainer)
            guard dirtyRect.intersects(rect) else { continue }
            NSColor.black.withAlphaComponent(FocnotesPalette.paper.isDark ? 0.16 : 0.08).setFill()
            NSBezierPath(roundedRect: rect, xRadius: 6, yRadius: 6).fill()
        }
    }

    private func drawInlineCodeBackgrounds(in dirtyRect: NSRect) {
        guard let layoutManager, let textContainer, let textStorage, textStorage.length > 0 else { return }
        var characterIndex = 0
        while characterIndex < textStorage.length {
            var effectiveRange = NSRange(location: 0, length: 0)
            let isInlineCode = layoutManager.temporaryAttribute(
                .focnotesInlineCode,
                atCharacterIndex: characterIndex,
                effectiveRange: &effectiveRange
            ) != nil
            guard effectiveRange.length > 0 else { break }
            defer { characterIndex = NSMaxRange(effectiveRange) }
            guard isInlineCode else { continue }

            let glyphRange = layoutManager.glyphRange(
                forCharacterRange: effectiveRange,
                actualCharacterRange: nil
            )
            layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) {
                [weak self] _, _, _, lineGlyphRange, _ in
                guard let self else { return }
                let visibleGlyphRange = NSIntersectionRange(glyphRange, lineGlyphRange)
                guard visibleGlyphRange.length > 0 else { return }
                var rect = layoutManager.boundingRect(forGlyphRange: visibleGlyphRange, in: textContainer)
                rect.origin.x += textContainerOrigin.x
                rect.origin.y += textContainerOrigin.y
                rect = rect.insetBy(dx: -3, dy: -1.5)
                guard dirtyRect.intersects(rect) else { return }
                NSColor.black.withAlphaComponent(FocnotesPalette.paper.isDark ? 0.16 : 0.08).setFill()
                NSBezierPath(roundedRect: rect, xRadius: 4, yRadius: 4).fill()
            }
        }
    }

    private func drawCodeBlockCopyButtons(in dirtyRect: NSRect) {
        guard let layoutManager, let textContainer else { return }
        let source = string as NSString
        for block in fencedCodeBlocks(in: source) {
            let blockRect = codeBlockRect(for: block, layoutManager: layoutManager, textContainer: textContainer)
            let buttonRect = copyButtonRect(for: blockRect)
            guard dirtyRect.intersects(buttonRect) else { continue }

            FocnotesPalette.ink.withAlphaComponent(0.06).setFill()
            NSBezierPath(roundedRect: buttonRect, xRadius: 4, yRadius: 4).fill()

            let backPage = NSRect(x: buttonRect.minX + 4, y: buttonRect.minY + 4, width: 8, height: 9)
            let frontPage = NSRect(x: buttonRect.minX + 8, y: buttonRect.minY + 6, width: 8, height: 9)
            FocnotesPalette.mutedInk.setStroke()
            for page in [backPage, frontPage] {
                let path = NSBezierPath(roundedRect: page, xRadius: 1.5, yRadius: 1.5)
                path.lineWidth = 1
                path.stroke()
            }
        }
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        let index = characterIndexForInsertion(at: point)
        let source = string as NSString
        guard source.length > 0 else {
            super.mouseDown(with: event)
            return
        }
        if copyCodeBlock(at: point, source: source) {
            return
        }
        if event.modifierFlags.contains(.command), openRenderedLink(at: index, in: source) {
            return
        }
        let lineRange = source.lineRange(for: NSRange(location: min(index, source.length - 1), length: 0))
        let line = source.substring(with: lineRange) as NSString
        let checkboxRange = line.range(of: "^[ \\t]*[-*+] \\[[ xX]\\](?=[ \\t])", options: .regularExpression)
        guard checkboxRange.location != NSNotFound else {
            super.mouseDown(with: event)
            return
        }
        let markerRange = line.range(of: "\\[[ xX]\\]", options: .regularExpression, range: checkboxRange)
        guard markerRange.location != NSNotFound else {
            super.mouseDown(with: event)
            return
        }
        let absoluteRange = NSRange(location: lineRange.location + markerRange.location, length: markerRange.length)
        guard let layoutManager, let textContainer else {
            super.mouseDown(with: event)
            return
        }
        let glyphRange = layoutManager.glyphRange(forCharacterRange: absoluteRange, actualCharacterRange: nil)
        var checkboxRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        checkboxRect.origin.x += textContainerOrigin.x
        checkboxRect.origin.y += textContainerOrigin.y
        checkboxRect = checkboxRect.insetBy(dx: -5, dy: -3)
        if checkboxRect.contains(point) {
            checkboxClicked?(absoluteRange)
            return
        }
        super.mouseDown(with: event)
    }

    private func copyCodeBlock(at point: NSPoint, source: NSString) -> Bool {
        guard let layoutManager, let textContainer else { return false }
        guard let block = fencedCodeBlocks(in: source).first(where: { block in
            let blockRect = codeBlockRect(for: block, layoutManager: layoutManager, textContainer: textContainer)
            return copyButtonRect(for: blockRect).contains(point)
        }) else { return false }

        var code = source.substring(with: block.codeRange)
        if code.hasSuffix("\r\n") {
            code.removeLast(2)
        } else if code.hasSuffix("\n") || code.hasSuffix("\r") {
            code.removeLast()
        }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(code, forType: .string)
        return true
    }

    private func openRenderedLink(at index: Int, in source: NSString) -> Bool {
        guard let expression = try? NSRegularExpression(
            pattern: "(?<!\\!)\\[([^\\]\\n]+)\\]\\(([^\\n)]*)\\)"
        ) else { return false }
        let fullRange = NSRange(location: 0, length: source.length)
        guard let match = expression.matches(in: source as String, range: fullRange).first(where: {
            NSLocationInRange(index, $0.range(at: 1)) || NSLocationInRange(index, $0.range(at: 2))
        }) else { return false }

        let destination = source.substring(with: match.range(at: 2))
        guard let url = URL(string: destination),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https" else { return false }
        return NSWorkspace.shared.open(url)
    }
}

final class MarkdownPresentationRenderer {
    private let source: String
    private let sourceNSString: NSString
    private let textStorage: NSTextStorage
    private let layoutManager: NSLayoutManager
    private let selections: [NSRange]
    private let baseFont: NSFont
    private var lineStarts: [String.UTF8View.Index] = []

    init(
        source: String,
        textStorage: NSTextStorage,
        layoutManager: NSLayoutManager,
        selections: [NSRange],
        fontSize: CGFloat
    ) {
        self.source = source
        self.sourceNSString = source as NSString
        self.textStorage = textStorage
        self.layoutManager = layoutManager
        self.selections = selections
        self.baseFont = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        var index = source.utf8.startIndex
        lineStarts = [index]
        while index < source.utf8.endIndex {
            if source.utf8[index] == 0x0A {
                lineStarts.append(source.utf8.index(after: index))
            }
            index = source.utf8.index(after: index)
        }
    }

    func render(_ markup: Markup) {
        if let range = characterRange(for: markup) {
            switch markup {
            case let heading as Heading:
                styleHeading(heading, range: range)
            case _ as Strong:
                styleInline(range, openingLength: 2, closingLength: 2, attributes: [
                    .font: NSFont.monospacedSystemFont(ofSize: baseFont.pointSize, weight: .bold)
                ])
            case _ as Emphasis:
                styleInline(range, openingLength: 1, closingLength: 1, attributes: [
                    .font: NSFontManager.shared.convert(baseFont, toHaveTrait: .italicFontMask)
                ])
            case _ as Strikethrough:
                styleInline(range, openingLength: 2, closingLength: 2, attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue
                ])
            case _ as InlineCode:
                styleCodeSpan(range)
            case _ as Link:
                styleLink(range)
            case _ as Image:
                applyPresentation([
                    .foregroundColor: FocnotesPalette.accentBlue,
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ], forCharacterRange: range)
            case let codeBlock as CodeBlock:
                styleCodeBlock(codeBlock, range: range)
                return
            case _ as InlineHTML, _ as HTMLBlock:
                applyPresentation([
                    .font: NSFont.monospacedSystemFont(ofSize: max(11, baseFont.pointSize - 2), weight: .regular),
                    .foregroundColor: FocnotesPalette.code
                ], forCharacterRange: range)
            case _ as BlockQuote:
                styleLines(in: range, markerPattern: "^[ \\t]*>\\s?", color: FocnotesPalette.mutedInk)
            case _ as UnorderedList:
                styleLines(in: range, markerPattern: "^[ \\t]*[-*+]\\s+", color: FocnotesPalette.accent)
            case _ as OrderedList:
                styleLines(in: range, markerPattern: "^[ \\t]*\\d+[.)]\\s+", color: FocnotesPalette.accent)
            case _ as Table:
                applyPresentation([
                    .font: NSFont.monospacedSystemFont(ofSize: max(11, baseFont.pointSize - 2), weight: .regular),
                    .foregroundColor: FocnotesPalette.accentBlue
                ], forCharacterRange: range)
            case _ as ThematicBreak:
                applyPresentation([
                    .foregroundColor: FocnotesPalette.faintInk,
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue
                ], forCharacterRange: range)
            default:
                break
            }
        }

        for child in markup.children {
            render(child)
        }
    }

    func renderInlineLinks() {
        guard let expression = try? NSRegularExpression(
            pattern: "(?<!\\!)\\[[^\\]\\n]+\\]\\([^\\n)]*\\)"
        ) else { return }
        let fullRange = NSRange(location: 0, length: sourceNSString.length)
        expression.enumerateMatches(in: source, range: fullRange) { [weak self] result, _, _ in
            guard let self, let result else { return }
            styleLink(result.range)
        }
    }

    private func styleHeading(_ heading: Heading, range: NSRange) {
        let size = baseFont.pointSize
        let headingSizes: [CGFloat] = [size + 8, size + 6, size + 4, size + 2, size, max(11, size - 1)]
        let value = sourceNSString.substring(with: range) as NSString
        let marker = value.range(of: "^#{1,6}\\s+", options: .regularExpression)
        let isActiveLine = selectionTouchesHeadingLine(range)
        let contentRange: NSRange
        if marker.location != NSNotFound {
            contentRange = NSRange(location: range.location + marker.length, length: range.length - marker.length)
        } else {
            let firstLine = value.lineRange(for: NSRange(location: 0, length: 0))
            contentRange = NSRange(
                location: range.location,
                length: firstLine.length - (value.substring(with: firstLine).hasSuffix("\n") ? 1 : 0)
            )
        }
        applyPresentation([
            .font: NSFont.monospacedSystemFont(ofSize: headingSizes[min(max(heading.level, 1), 6) - 1], weight: .bold),
            .foregroundColor: FocnotesPalette.ink
        ], forCharacterRange: contentRange)
        if marker.location != NSNotFound {
            let markerRange = NSRange(location: range.location, length: marker.length)
            if isActiveLine {
                applyPresentation([
                    .font: NSFont.monospacedSystemFont(ofSize: headingSizes[min(max(heading.level, 1), 6) - 1], weight: .bold),
                    .foregroundColor: FocnotesPalette.faintInk
                ], forCharacterRange: markerRange)
            } else {
                hide(markerRange)
            }
        } else if !isActiveLine, NSMaxRange(contentRange) < NSMaxRange(range) {
                hide(NSRange(location: NSMaxRange(contentRange), length: NSMaxRange(range) - NSMaxRange(contentRange)))
        }
    }

    private func styleInline(
        _ range: NSRange,
        openingLength: Int,
        closingLength: Int,
        attributes: [NSAttributedString.Key: Any]
    ) {
        guard range.length >= openingLength + closingLength else { return }
        let content = NSRange(
            location: range.location + openingLength,
            length: range.length - openingLength - closingLength
        )
        applyPresentation(attributes, forCharacterRange: content)
        guard !selectionTouchesIncludingEnd(range) else { return }
        hide(NSRange(location: range.location, length: openingLength))
        hide(NSRange(location: NSMaxRange(range) - closingLength, length: closingLength))
    }

    private func styleCodeSpan(_ range: NSRange) {
        let value = sourceNSString.substring(with: range) as NSString
        var delimiterLength = 0
        while delimiterLength < value.length && value.character(at: delimiterLength) == 0x60 {
            delimiterLength += 1
        }
        styleInline(range, openingLength: delimiterLength, closingLength: delimiterLength, attributes: [
            .font: baseFont,
            .focnotesInlineCode: true
        ])
    }

    private func styleCodeBlock(_ codeBlock: CodeBlock, range: NSRange) {
        let codeAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: max(11, baseFont.pointSize - 2), weight: .regular),
            .foregroundColor: FocnotesPalette.ink.withAlphaComponent(0.82)
        ]
        applyPresentation(codeAttributes, forCharacterRange: range)

        let value = sourceNSString.substring(with: range) as NSString
        let fullRange = NSRange(location: 0, length: value.length)
        guard let openingExpression = try? NSRegularExpression(
            pattern: "^[ \\t]{0,3}(`{3,}|~{3,})[^\\r\\n]*(?:\\r?\\n)?",
            options: .anchorsMatchLines
        ), let opening = openingExpression.firstMatch(in: value as String, range: fullRange),
           opening.range.location == 0 else { return }

        let fence = value.substring(with: opening.range(at: 1)) as NSString
        guard fence.length >= 3 else { return }
        let fenceCharacter = value.substring(with: NSRange(location: opening.range(at: 1).location, length: 1))
        let escapedFenceCharacter = NSRegularExpression.escapedPattern(for: fenceCharacter)
        guard let closingExpression = try? NSRegularExpression(
            pattern: "^[ \\t]{0,3}\(escapedFenceCharacter){\(fence.length),}[ \\t]*(?:\\r?\\n)?$",
            options: .anchorsMatchLines
        ) else { return }
        let closing = closingExpression.matches(in: value as String, range: fullRange).last { match in
            match.range.location >= NSMaxRange(opening.range)
        }
        guard let closing else { return }

        let openingRange = NSRange(location: range.location, length: opening.range.length)
        let closingRange = NSRange(location: range.location + closing.range.location, length: closing.range.length)
        if selectionTouchesIncludingEnd(range) {
            applyPresentation([.foregroundColor: FocnotesPalette.faintInk], forCharacterRange: openingRange)
            applyPresentation([.foregroundColor: FocnotesPalette.faintInk], forCharacterRange: closingRange)
            if let language = codeBlock.language?.trimmingCharacters(in: .whitespacesAndNewlines),
               !language.isEmpty {
                let languageSearchRange = NSRange(
                    location: NSMaxRange(opening.range(at: 1)),
                    length: NSMaxRange(opening.range) - NSMaxRange(opening.range(at: 1))
                )
                let languageRange = value.range(of: language, options: [], range: languageSearchRange)
                if languageRange.location != NSNotFound {
                    applyPresentation(
                        [.foregroundColor: FocnotesPalette.accentBlue],
                        forCharacterRange: NSRange(
                            location: range.location + languageRange.location,
                            length: languageRange.length
                        )
                    )
                }
            }
            return
        }

        hide(openingRange)
        hide(closingRange)
    }

    private func styleLink(_ range: NSRange) {
        let value = sourceNSString.substring(with: range) as NSString
        let closeLabel = value.range(of: "]")
        guard value.hasPrefix("["), closeLabel.location != NSNotFound else { return }
        let label = NSRange(location: range.location + 1, length: max(0, closeLabel.location - 1))
        applyPresentation([
            .foregroundColor: FocnotesPalette.accentBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ], forCharacterRange: label)
        if selectionTouchesLink(range) {
            let destinationStart = closeLabel.location + 2
            if value.hasSuffix(")"), destinationStart < value.length - 1 {
                let destination = NSRange(
                    location: range.location + destinationStart,
                    length: value.length - destinationStart - 1
                )
                applyPresentation([
                    .foregroundColor: FocnotesPalette.accentBlue,
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ], forCharacterRange: destination)
            }
            return
        }
        hide(NSRange(location: range.location, length: 1))
        hide(NSRange(location: range.location + closeLabel.location, length: range.length - closeLabel.location))
    }

    private func styleLines(in range: NSRange, markerPattern: String, color: NSColor) {
        guard let expression = try? NSRegularExpression(pattern: markerPattern, options: .anchorsMatchLines) else { return }
        expression.enumerateMatches(in: source, range: range) { [weak self] result, _, _ in
            guard let self, let result else { return }
            applyPresentation([.foregroundColor: color], forCharacterRange: result.range)
        }
    }

    private func hide(_ range: NSRange) {
        guard range.length > 0 else { return }
        applyPresentation([
            .font: NSFont.monospacedSystemFont(ofSize: 0.1, weight: .regular),
            .foregroundColor: NSColor.clear
        ], forCharacterRange: range)
    }

    private func selectionTouches(_ range: NSRange) -> Bool {
        return selections.contains { selection in
            if selection.length > 0 {
                return NSIntersectionRange(selection, range).length > 0
            }
            return selection.location >= range.location && selection.location < NSMaxRange(range)
        }
    }

    private func selectionTouchesIncludingEnd(_ range: NSRange) -> Bool {
        selections.contains { selection in
            if selection.length > 0 {
                return NSIntersectionRange(selection, range).length > 0
            }
            return selection.location >= range.location && selection.location <= NSMaxRange(range)
        }
    }

    private func selectionTouchesLink(_ range: NSRange) -> Bool {
        selectionTouchesIncludingEnd(range)
    }

    private func selectionTouchesHeadingLine(_ range: NSRange) -> Bool {
        let lineRange = sourceNSString.lineRange(for: NSRange(location: range.location, length: 0))
        let line = sourceNSString.substring(with: lineRange)
        let lineEnd = NSMaxRange(lineRange) - (line.hasSuffix("\n") ? 1 : 0)
        let activeRange = NSRange(location: lineRange.location, length: lineEnd - lineRange.location)
        return selections.contains { selection in
            if selection.length > 0 {
                return NSIntersectionRange(selection, activeRange).length > 0
            }
            return selection.location >= lineRange.location && selection.location <= lineEnd
        }
    }

    private func applyPresentation(
        _ attributes: [NSAttributedString.Key: Any],
        forCharacterRange range: NSRange
    ) {
        var temporaryAttributes = attributes
        if let font = temporaryAttributes.removeValue(forKey: .font) {
            textStorage.addAttribute(.font, value: font, range: range)
        }
        if !temporaryAttributes.isEmpty {
            layoutManager.addTemporaryAttributes(temporaryAttributes, forCharacterRange: range)
        }
    }

    private func characterRange(for markup: Markup) -> NSRange? {
        guard let range = markup.range,
              let lower = stringIndex(for: range.lowerBound),
              let upper = stringIndex(for: range.upperBound),
              lower <= upper else { return nil }
        return NSRange(lower..<upper, in: source)
    }

    private func stringIndex(for location: SourceLocation) -> String.Index? {
        guard location.line > 0, location.line <= lineStarts.count, location.column > 0 else { return nil }
        let lineStart = lineStarts[location.line - 1]
        guard let utf8Index = source.utf8.index(
            lineStart,
            offsetBy: location.column - 1,
            limitedBy: source.utf8.endIndex
        ) else { return nil }
        return String.Index(utf8Index, within: source)
    }
}

final class NoteView: NSView {
    private let blurView = NSVisualEffectView()
    private let paperTintView = NSView()
    private let titleBar = NSView()
    private let titleLabel = NSTextField(labelWithString: "")
    private let closeButton = PointingHandButton()
    private let newNoteButton = PointingHandButton()
    private let textView = MarkdownTextView()
    private let textRightPadding: CGFloat = 0
    private let fileURL: URL?
    private let initialText: String?
    private let titleChanged: (String) -> Void
    private let textChanged: (String) -> Void
    private let newNoteRequested: () -> Void
    private var isUpdatingMarkdown = false
    private var isApplyingHighlighting = false
    private var preferencesObserver: NSObjectProtocol?
    private var isMarkdown: Bool {
        guard let extensionName = fileURL?.pathExtension.lowercased(), !extensionName.isEmpty else { return true }
        return extensionName == "md" || extensionName == "markdown"
    }

    init(
        frame frameRect: NSRect,
        fileURL: URL?,
        initialText: String? = nil,
        titleChanged: @escaping (String) -> Void = { _ in },
        textChanged: @escaping (String) -> Void = { _ in },
        newNoteRequested: @escaping () -> Void = {}
    ) {
        self.fileURL = fileURL
        self.initialText = initialText
        self.titleChanged = titleChanged
        self.textChanged = textChanged
        self.newNoteRequested = newNoteRequested
        super.init(frame: frameRect)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if let preferencesObserver {
            NotificationCenter.default.removeObserver(preferencesObserver)
        }
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard window != nil else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.updateTextLayoutWidth()
            self.updateLivePreview()
            if let layoutManager = self.textView.layoutManager,
               let textContainer = self.textView.textContainer {
                layoutManager.ensureLayout(for: textContainer)
                layoutManager.invalidateDisplay(forCharacterRange: NSRange(location: 0, length: self.textView.string.utf16.count))
            }
            self.textView.needsDisplay = true
            self.textView.enclosingScrollView?.needsDisplay = true
            self.displayIfNeeded()
        }
    }

    override func layout() {
        super.layout()
        updateTextLayoutWidth()
    }

    func focusEditor() {
        window?.makeFirstResponder(textView)
    }

    private func setupView() {
        wantsLayer = true
        layer?.cornerRadius = 22
        layer?.backgroundColor = NSColor.clear.cgColor
        layer?.borderWidth = 1
        layer?.borderColor = FocnotesPalette.ink.withAlphaComponent(0.18).cgColor
        layer?.shadowColor = FocnotesPalette.ink.cgColor
        layer?.shadowOpacity = 0.18
        layer?.shadowRadius = 24
        layer?.shadowOffset = CGSize(width: 0, height: -10)

        blurView.frame = bounds
        blurView.autoresizingMask = [.width, .height]
        blurView.blendingMode = .behindWindow
        blurView.material = .popover
        blurView.state = .active
        blurView.alphaValue = AppPreferences.blurIntensity / 100
        blurView.wantsLayer = true
        blurView.layer?.cornerRadius = 22
        blurView.layer?.masksToBounds = true

        paperTintView.frame = bounds
        paperTintView.autoresizingMask = [.width, .height]
        paperTintView.wantsLayer = true
        paperTintView.layer?.cornerRadius = 22
        paperTintView.layer?.masksToBounds = true
        paperTintView.layer?.backgroundColor = FocnotesPalette.paper.cgColor

        titleBar.translatesAutoresizingMaskIntoConstraints = false
        titleBar.wantsLayer = true
        titleBar.layer?.cornerRadius = 22
        titleBar.layer?.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        titleBar.layer?.backgroundColor = FocnotesPalette.ink.withAlphaComponent(0.025).cgColor

        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.scrollerStyle = .overlay
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 11, weight: .regular)
        titleLabel.textColor = FocnotesPalette.mutedInk.withAlphaComponent(0.24)
        titleLabel.alignment = .center
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.maximumNumberOfLines = 1
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleBar.addSubview(titleLabel)

        closeButton.title = "×"
        closeButton.font = .systemFont(ofSize: 15, weight: .regular)
        closeButton.contentTintColor = FocnotesPalette.mutedInk.withAlphaComponent(0.24)
        closeButton.isBordered = false
        closeButton.toolTip = "Cerrar"
        closeButton.target = self
        closeButton.action = #selector(closeNote)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        titleBar.addSubview(closeButton)

        newNoteButton.title = "+"
        newNoteButton.font = .systemFont(ofSize: 15, weight: .regular)
        newNoteButton.contentTintColor = FocnotesPalette.mutedInk.withAlphaComponent(0.24)
        newNoteButton.isBordered = false
        newNoteButton.toolTip = "Nueva nota (⌘N)"
        newNoteButton.target = self
        newNoteButton.action = #selector(requestNewNote)
        newNoteButton.translatesAutoresizingMaskIntoConstraints = false
        titleBar.addSubview(newNoteButton)

        textView.frame = NSRect(
            x: 0,
            y: 0,
            width: max(bounds.width - 48, 100),
            height: max(bounds.height - 24, 100)
        )
        textView.autoresizingMask = []
        if let fileURL {
            textView.string = (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""
        } else {
            textView.string = initialText ?? ""
        }
        if isMarkdown {
            textView.string = normalizeLegacyMarkdown(textView.string)
        }
        textView.font = .monospacedSystemFont(ofSize: AppPreferences.editorFontSize, weight: .regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        textView.defaultParagraphStyle = paragraphStyle
        textView.textColor = FocnotesPalette.ink.withAlphaComponent(0.86)
        textView.backgroundColor = .clear
        textView.insertionPointColor = FocnotesPalette.accent
        textView.isRichText = false
        textView.allowsUndo = true
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.minSize = NSSize(width: 0, height: scrollView.contentSize.height)
        textView.maxSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
        textView.textContainer?.containerSize = NSSize(
            width: scrollView.contentSize.width,
            height: CGFloat.greatestFiniteMagnitude
        )
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.lineBreakMode = .byCharWrapping
        textView.textContainerInset = CGSize(width: 0, height: 4)
        textView.delegate = self
        textView.checkboxClicked = { [weak self] range in
            self?.toggleCheckbox(at: range)
        }
        preferencesObserver = NotificationCenter.default.addObserver(
            forName: AppPreferences.changedNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applyTheme()
        }
        scrollView.documentView = textView
        applyTheme()
        updateTitle()

        addSubview(blurView)
        addSubview(paperTintView)
        addSubview(titleBar)
        addSubview(scrollView)

        NSLayoutConstraint.activate([
            titleBar.topAnchor.constraint(equalTo: topAnchor),
            titleBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleBar.heightAnchor.constraint(equalToConstant: 24),
            titleLabel.centerYAnchor.constraint(equalTo: titleBar.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleBar.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: titleBar.trailingAnchor, constant: -30),
            closeButton.centerYAnchor.constraint(equalTo: titleBar.centerYAnchor),
            closeButton.leadingAnchor.constraint(equalTo: titleBar.leadingAnchor, constant: 8),
            closeButton.widthAnchor.constraint(equalToConstant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 20),
            newNoteButton.centerYAnchor.constraint(equalTo: titleBar.centerYAnchor),
            newNoteButton.trailingAnchor.constraint(equalTo: titleBar.trailingAnchor, constant: -8),
            newNoteButton.widthAnchor.constraint(equalToConstant: 20),
            newNoteButton.heightAnchor.constraint(equalToConstant: 20),
            scrollView.topAnchor.constraint(equalTo: titleBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
        layoutSubtreeIfNeeded()
        updateTextLayoutWidth()
    }

    private func updateTextLayoutWidth() {
        guard let scrollView = textView.enclosingScrollView else { return }
        textView.frame.size.width = max(scrollView.contentSize.width - textRightPadding, 100)
        textView.textContainer?.containerSize = NSSize(
            width: textView.frame.width,
            height: CGFloat.greatestFiniteMagnitude
        )
    }

    private func normalizeLegacyMarkdown(_ text: String) -> String {
        text
            .replacingOccurrences(of: "(?m)^(\\s*)☐\\s?", with: "$1- [ ] ", options: .regularExpression)
            .replacingOccurrences(of: "(?m)^(\\s*)☑\\s?", with: "$1- [x] ", options: .regularExpression)
            .replacingOccurrences(of: "(?m)^(\\s*)•\\s?", with: "$1- ", options: .regularExpression)
    }

    private func applyMarkdownHighlighting() {
        guard isMarkdown, !isApplyingHighlighting,
              let storage = textView.textStorage,
              let layoutManager = textView.layoutManager else { return }
        isApplyingHighlighting = true
        defer { isApplyingHighlighting = false }
        let scrollView = textView.enclosingScrollView
        let visibleOrigin = scrollView?.contentView.bounds.origin
        let fullRange = NSRange(location: 0, length: storage.length)
        let baseFont = NSFont.monospacedSystemFont(ofSize: AppPreferences.editorFontSize, weight: .regular)
        let baseColor = FocnotesPalette.ink.withAlphaComponent(0.86)

        for key: NSAttributedString.Key in [
            .font,
            .foregroundColor,
            .backgroundColor,
            .strikethroughStyle,
            .underlineStyle,
            .focnotesInlineCode
        ] {
            layoutManager.removeTemporaryAttribute(key, forCharacterRange: fullRange)
        }

        storage.beginEditing()
        storage.addAttribute(.font, value: baseFont, range: fullRange)
        if let paragraphStyle = textView.defaultParagraphStyle {
            storage.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
        }
        let document = Document(parsing: storage.string, options: [.disableSmartOpts])
        let renderer = MarkdownPresentationRenderer(
            source: storage.string,
            textStorage: storage,
            layoutManager: layoutManager,
            selections: textView.selectedRanges.map(\.rangeValue),
            fontSize: AppPreferences.editorFontSize
        )
        renderer.render(document)
        renderer.renderInlineLinks()
        storage.endEditing()
        applyListDecorations(storage: storage, layoutManager: layoutManager)

        textView.typingAttributes = [
            .font: baseFont,
            .foregroundColor: baseColor,
            .paragraphStyle: textView.defaultParagraphStyle ?? NSParagraphStyle.default
        ]
        layoutManager.invalidateLayout(forCharacterRange: fullRange, actualCharacterRange: nil)
        if let textContainer = textView.textContainer {
            layoutManager.ensureLayout(for: textContainer)
        }
        if let scrollView, let visibleOrigin {
            scrollView.contentView.scroll(to: visibleOrigin)
            scrollView.reflectScrolledClipView(scrollView.contentView)
        }
        textView.needsDisplay = true
        textView.window?.invalidateCursorRects(for: textView)
    }

    private func applyListDecorations(storage: NSTextStorage, layoutManager: NSLayoutManager) {
        let fullRange = NSRange(location: 0, length: storage.length)
        let source = storage.string as NSString
        let selections = textView.selectedRanges.map(\.rangeValue)
        let selectionTouches: (NSRange) -> Bool = { range in
            selections.contains { selection in
                if selection.length > 0 {
                    return NSIntersectionRange(selection, range).length > 0
                }
                return selection.location >= range.location && selection.location < NSMaxRange(range)
            }
        }

        let tasks = try? NSRegularExpression(pattern: "(?m)^[ \\t]*([-*+] (\\[[ xX]\\]))(?=[ \\t])")
        tasks?.enumerateMatches(in: storage.string, range: fullRange) { result, _, _ in
            guard let result else { return }
            let syntaxRange = result.range(at: 1)
            let separatorLength: Int
            if NSMaxRange(syntaxRange) < source.length {
                let character = source.character(at: NSMaxRange(syntaxRange))
                separatorLength = character == 0x20 || character == 0x09 ? 1 : 0
            } else {
                separatorLength = 0
            }
            let interactionRange = NSRange(
                location: syntaxRange.location,
                length: syntaxRange.length + separatorLength
            )
            guard !selectionTouches(interactionRange) else { return }
            let listMarkerRange = NSRange(location: syntaxRange.location, length: 2)
            storage.addAttribute(
                .font,
                value: NSFont.monospacedSystemFont(ofSize: 0.1, weight: .regular),
                range: listMarkerRange
            )
            storage.addAttribute(
                .font,
                value: NSFont.monospacedSystemFont(ofSize: 8, weight: .regular),
                range: result.range(at: 2)
            )
            layoutManager.addTemporaryAttributes(
                [.foregroundColor: NSColor.clear],
                forCharacterRange: syntaxRange
            )
        }


        let bullets = try? NSRegularExpression(pattern: "(?m)^[ \\t]*([-*+])(?=[ \\t]+(?!\\[[ xX]\\]))")
        bullets?.enumerateMatches(in: storage.string, range: fullRange) { result, _, _ in
            guard let result else { return }
            let markerRange = result.range(at: 1)
            let syntaxRange = NSRange(location: markerRange.location, length: min(2, storage.length - markerRange.location))
            guard !selectionTouches(syntaxRange) else { return }
            layoutManager.addTemporaryAttribute(.foregroundColor, value: NSColor.clear, forCharacterRange: markerRange)
        }
    }

    private func updateLivePreview() {
        applyMarkdownHighlighting()
    }

    private func applyTheme() {
        blurView.alphaValue = AppPreferences.blurIntensity / 100
        paperTintView.layer?.backgroundColor = FocnotesPalette.paper.cgColor
        titleBar.layer?.backgroundColor = FocnotesPalette.ink.withAlphaComponent(0.025).cgColor
        layer?.borderColor = FocnotesPalette.ink.withAlphaComponent(0.18).cgColor
        layer?.shadowColor = FocnotesPalette.ink.cgColor
        titleLabel.textColor = FocnotesPalette.mutedInk.withAlphaComponent(0.24)
        closeButton.contentTintColor = titleLabel.textColor
        newNoteButton.contentTintColor = titleLabel.textColor
        textView.textColor = FocnotesPalette.ink.withAlphaComponent(0.86)
        textView.insertionPointColor = FocnotesPalette.accent
        updateLivePreview()
    }

    @objc private func requestNewNote() {
        newNoteRequested()
    }

    @objc private func closeNote() {
        NSApp.terminate(nil)
    }

    private func toggleCheckbox(at range: NSRange) {
        let source = textView.string as NSString
        guard NSMaxRange(range) <= source.length else { return }
        let current = source.substring(with: range)
        let replacement = current.lowercased() == "[x]" ? "[ ]" : "[x]"
        textView.textStorage?.replaceCharacters(in: range, with: replacement)
        persistText()
        applyMarkdownHighlighting()
    }

    private func updateTitle() {
        let title = fileURL?.lastPathComponent ?? Self.noteTitle(for: textView.string)
        titleLabel.stringValue = title
        titleChanged(title)
    }

    static func noteTitle(for text: String) -> String {
        guard let line = text.split(whereSeparator: \Character.isNewline).first(where: {
            !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }) else { return "Nota sin título" }
        let title = String(line)
            .replacingOccurrences(of: "^\\s{0,3}#{1,6}\\s+", with: "", options: .regularExpression)
            .replacingOccurrences(of: "^\\s*[-*+]\\s+(?:\\[[ xX]\\]\\s+)?", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return "Nota sin título" }
        return String(title.prefix(48))
    }

    private func persistText() {
        if let fileURL {
            try? textView.string.write(to: fileURL, atomically: true, encoding: .utf8)
        } else {
            textChanged(textView.string)
        }
        updateTitle()
    }
}

extension NoteView: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        guard !isUpdatingMarkdown else { return }
        updateLivePreview()
        persistText()
    }

    func textViewDidChangeSelection(_ notification: Notification) {
        guard !isApplyingHighlighting else { return }
        updateLivePreview()
    }

    func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
            textView.window?.makeFirstResponder(nil)
            textView.window?.resignKey()
            NSApp.deactivate()
            return true
        }
        guard isMarkdown else { return false }
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            return continueMarkdownLine()
        }
        if commandSelector == #selector(NSResponder.insertTab(_:)) {
            return indentCurrentLine(remove: false)
        }
        if commandSelector == #selector(NSResponder.insertBacktab(_:)) {
            return indentCurrentLine(remove: true)
        }
        return false
    }

    private func continueMarkdownLine() -> Bool {
        let source = textView.string as NSString
        let selection = textView.selectedRange()
        let lineRange = source.lineRange(for: NSRange(location: min(selection.location, source.length), length: 0))
        let line = source.substring(with: lineRange).trimmingCharacters(in: .newlines)
        let visualPattern = "^(\\s*)([☐☑•]) "
        if let expression = try? NSRegularExpression(pattern: visualPattern),
           let match = expression.firstMatch(in: line, range: NSRange(location: 0, length: (line as NSString).length)) {
            let marker = (line as NSString).substring(with: match.range)
            if line == marker {
                replaceText(
                    in: NSRange(location: lineRange.location, length: marker.utf16.count),
                    with: "\n"
                )
            } else {
                let indentation = (line as NSString).substring(with: match.range(at: 1))
                let symbol = (line as NSString).substring(with: match.range(at: 2))
                let nextMarker = symbol == "•" ? "- " : "- [ ] "
                replaceText(in: selection, with: "\n\(indentation)\(nextMarker)")
            }
            return true
        }

        let lineNSRange = NSRange(location: 0, length: (line as NSString).length)
        let taskPattern = "^(\\s*)[-*+] \\[[ xX]\\] "
        if let expression = try? NSRegularExpression(pattern: taskPattern),
           let match = expression.firstMatch(in: line, range: lineNSRange) {
            let marker = (line as NSString).substring(with: match.range)
            if line == marker {
                replaceText(in: NSRange(location: lineRange.location, length: marker.utf16.count), with: "\n")
            } else {
                let indentation = (line as NSString).substring(with: match.range(at: 1))
                replaceText(in: selection, with: "\n\(indentation)- [ ] ")
            }
            return true
        }

        let orderedPattern = "^(\\s*)(\\d+)([.)]) "
        if let expression = try? NSRegularExpression(pattern: orderedPattern),
           let match = expression.firstMatch(in: line, range: lineNSRange) {
            let marker = (line as NSString).substring(with: match.range)
            if line == marker {
                replaceText(in: NSRange(location: lineRange.location, length: marker.utf16.count), with: "\n")
            } else {
                let indentation = (line as NSString).substring(with: match.range(at: 1))
                let number = Int((line as NSString).substring(with: match.range(at: 2))) ?? 0
                let delimiter = (line as NSString).substring(with: match.range(at: 3))
                replaceText(in: selection, with: "\n\(indentation)\(number + 1)\(delimiter) ")
            }
            return true
        }

        let quotePattern = "^(\\s*)> "
        if let expression = try? NSRegularExpression(pattern: quotePattern),
           let match = expression.firstMatch(in: line, range: lineNSRange) {
            let marker = (line as NSString).substring(with: match.range)
            if line == marker {
                replaceText(in: NSRange(location: lineRange.location, length: marker.utf16.count), with: "\n")
            } else {
                let indentation = (line as NSString).substring(with: match.range(at: 1))
                replaceText(in: selection, with: "\n\(indentation)> ")
            }
            return true
        }

        let listPattern = "^(\\s*)[-*+] "
        guard let expression = try? NSRegularExpression(pattern: listPattern),
              let match = expression.firstMatch(in: line, range: lineNSRange) else { return false }
        let marker = (line as NSString).substring(with: match.range)
        if line == marker {
            replaceText(
                in: NSRange(location: lineRange.location, length: marker.utf16.count),
                with: "\n"
            )
        } else {
            let indentation = (line as NSString).substring(with: match.range(at: 1))
            replaceText(in: selection, with: "\n\(indentation)- ")
        }
        return true
    }

    private func indentCurrentLine(remove: Bool) -> Bool {
        let source = textView.string as NSString
        let selection = textView.selectedRange()
        let lineRange = source.lineRange(for: NSRange(location: min(selection.location, source.length), length: 0))
        if remove {
            let removable = source.substring(with: lineRange).hasPrefix("  ") ? 2 : 0
            guard removable > 0 else { return true }
            replaceText(in: NSRange(location: lineRange.location, length: removable), with: "")
        } else {
            replaceText(in: NSRange(location: lineRange.location, length: 0), with: "  ")
        }
        return true
    }

    private func replaceText(in range: NSRange, with replacement: String) {
        guard textView.shouldChangeText(in: range, replacementString: replacement) else { return }
        isUpdatingMarkdown = true
        textView.textStorage?.replaceCharacters(in: range, with: replacement)
        let cursor = range.location + replacement.utf16.count
        textView.setSelectedRange(NSRange(location: cursor, length: 0))
        isUpdatingMarkdown = false
        textView.didChangeText()
    }
}

private final class ShortcutRecorderButton: NSButton {
    var onShortcutChanged: ((KeyboardShortcut) -> Void)?

    private var shortcut: KeyboardShortcut
    private var isRecordingShortcut = false

    init(shortcut: KeyboardShortcut) {
        self.shortcut = shortcut
        super.init(frame: .zero)
        title = shortcut.displayValue
        font = .monospacedSystemFont(ofSize: 13, weight: .medium)
        bezelStyle = .rounded
        target = self
        action = #selector(beginRecording)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var acceptsFirstResponder: Bool { true }

    @objc private func beginRecording() {
        isRecordingShortcut = true
        title = "Presiona un atajo…"
        window?.makeFirstResponder(self)
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if isRecordingShortcut {
            record(event)
            return true
        }
        return super.performKeyEquivalent(with: event)
    }

    override func keyDown(with event: NSEvent) {
        guard isRecordingShortcut else {
            super.keyDown(with: event)
            return
        }
        record(event)
    }

    private func record(_ event: NSEvent) {
        if event.keyCode == UInt16(kVK_Escape) {
            finishRecording(with: nil)
            return
        }

        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        var modifiers: UInt32 = 0
        if flags.contains(.control) { modifiers |= UInt32(controlKey) }
        if flags.contains(.option) { modifiers |= UInt32(optionKey) }
        if flags.contains(.shift) { modifiers |= UInt32(shiftKey) }
        if flags.contains(.command) { modifiers |= UInt32(cmdKey) }
        guard modifiers != 0, let label = keyLabel(for: event) else {
            NSSound.beep()
            return
        }

        finishRecording(with: KeyboardShortcut(
            keyCode: UInt32(event.keyCode),
            modifiers: modifiers,
            keyLabel: label
        ))
    }

    private func finishRecording(with newShortcut: KeyboardShortcut?) {
        isRecordingShortcut = false
        if let newShortcut {
            shortcut = newShortcut
            onShortcutChanged?(newShortcut)
        }
        title = shortcut.displayValue
        window?.makeFirstResponder(nil)
    }

    private func keyLabel(for event: NSEvent) -> String? {
        switch Int(event.keyCode) {
        case kVK_Space: return "Space"
        case kVK_Return: return "↩"
        case kVK_Tab: return "⇥"
        case kVK_Delete: return "⌫"
        case kVK_ForwardDelete: return "⌦"
        case kVK_LeftArrow: return "←"
        case kVK_RightArrow: return "→"
        case kVK_UpArrow: return "↑"
        case kVK_DownArrow: return "↓"
        default:
            guard let characters = event.charactersIgnoringModifiers,
                  let character = characters.first,
                  !character.isWhitespace,
                  !character.isNewline else { return nil }
            return String(character).uppercased()
        }
    }
}

private final class WheelColorWell: NSColorWell {
    override func activate(_ exclusive: Bool) {
        NSColorPanel.shared.mode = .wheel
        super.activate(exclusive)
    }
}

private final class ThemePickerView: NSView {
    private var themeButtons: [NoteTheme: NSButton] = [:]
    private let colorWell = WheelColorWell()
    private let hexField = NSTextField()
    private let redField = NSTextField()
    private let greenField = NSTextField()
    private let blueField = NSTextField()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        translatesAutoresizingMaskIntoConstraints = false
        buildView()
        updateControls(color: AppPreferences.customNoteColor)
        updateSelection()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildView() {
        let presets = NSStackView()
        presets.orientation = .horizontal
        presets.alignment = .top
        presets.distribution = .fillEqually
        presets.spacing = 10

        for theme in NoteTheme.allCases {
            let button = NSButton(title: "", target: self, action: #selector(selectTheme(_:)))
            button.tag = NoteTheme.allCases.firstIndex(of: theme) ?? 0
            button.isBordered = false
            button.wantsLayer = true
            button.layer?.backgroundColor = theme.color.cgColor
            button.layer?.cornerRadius = 18
            button.layer?.borderWidth = 2
            button.toolTip = theme.title
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 36),
                button.heightAnchor.constraint(equalToConstant: 36)
            ])
            themeButtons[theme] = button

            let label = NSTextField(labelWithString: theme.title)
            label.font = .systemFont(ofSize: 10)
            label.alignment = .center
            label.textColor = .secondaryLabelColor
            let item = NSStackView(views: [button, label])
            item.orientation = .vertical
            item.alignment = .centerX
            item.spacing = 5
            presets.addArrangedSubview(item)
        }

        configureField(hexField, width: 86, placeholder: "#FFD61F")
        [redField, greenField, blueField].forEach { configureField($0, width: 46, placeholder: "0") }
        colorWell.target = self
        colorWell.action = #selector(changeColorWell(_:))
        colorWell.translatesAutoresizingMaskIntoConstraints = false
        colorWell.widthAnchor.constraint(equalToConstant: 54).isActive = true
        colorWell.heightAnchor.constraint(equalToConstant: 30).isActive = true

        let customControls = NSStackView(views: [
            fieldLabel("HEX"), hexField,
            fieldLabel("R"), redField,
            fieldLabel("G"), greenField,
            fieldLabel("B"), blueField,
            colorWell
        ])
        customControls.orientation = .horizontal
        customControls.alignment = .centerY
        customControls.spacing = 7

        let customTitle = NSTextField(labelWithString: "PERSONALIZADO")
        customTitle.font = .systemFont(ofSize: 11, weight: .medium)
        customTitle.textColor = .secondaryLabelColor
        let hint = NSTextField(wrappingLabelWithString: "Escribe un color HEX o RGB, o abre la rueda de color.")
        hint.font = .systemFont(ofSize: 11)
        hint.textColor = .secondaryLabelColor

        let custom = NSStackView(views: [customTitle, customControls, hint])
        custom.orientation = .vertical
        custom.alignment = .leading
        custom.spacing = 7

        let stack = NSStackView(views: [presets, custom])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            presets.widthAnchor.constraint(equalTo: stack.widthAnchor)
        ])
    }

    private func configureField(_ field: NSTextField, width: CGFloat, placeholder: String) {
        field.placeholderString = placeholder
        field.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        field.alignment = .center
        field.target = self
        field.action = field === hexField ? #selector(changeHex(_:)) : #selector(changeRGB(_:))
        field.translatesAutoresizingMaskIntoConstraints = false
        field.widthAnchor.constraint(equalToConstant: width).isActive = true
    }

    private func fieldLabel(_ title: String) -> NSTextField {
        let label = NSTextField(labelWithString: title)
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textColor = .secondaryLabelColor
        return label
    }

    @objc private func selectTheme(_ sender: NSButton) {
        let themes = NoteTheme.allCases
        guard themes.indices.contains(sender.tag) else { return }
        AppPreferences.setNoteTheme(themes[sender.tag])
        updateSelection()
    }

    @objc private func changeColorWell(_ sender: NSColorWell) {
        applyCustomColor(sender.color)
    }

    @objc private func changeHex(_ sender: NSTextField) {
        guard let color = NSColor(hex: sender.stringValue) else {
            NSSound.beep()
            updateControls(color: AppPreferences.customNoteColor)
            return
        }
        applyCustomColor(color)
    }

    @objc private func changeRGB(_ sender: NSTextField) {
        let values = [redField, greenField, blueField].compactMap { Int($0.stringValue) }
        guard values.count == 3, values.allSatisfy({ (0...255).contains($0) }) else {
            NSSound.beep()
            updateControls(color: AppPreferences.customNoteColor)
            return
        }
        applyCustomColor(NSColor(
            srgbRed: CGFloat(values[0]) / 255,
            green: CGFloat(values[1]) / 255,
            blue: CGFloat(values[2]) / 255,
            alpha: 1
        ))
    }

    private func applyCustomColor(_ color: NSColor) {
        AppPreferences.setCustomNoteColor(color)
        updateControls(color: color)
        updateSelection()
    }

    private func updateControls(color: NSColor) {
        colorWell.color = color
        hexField.stringValue = color.hexValue
        let rgb = color.rgbComponents255
        redField.stringValue = String(rgb.red)
        greenField.stringValue = String(rgb.green)
        blueField.stringValue = String(rgb.blue)
    }

    private func updateSelection() {
        let selected = AppPreferences.noteTheme
        themeButtons.forEach { theme, button in
            button.layer?.borderColor = theme == selected
                ? NSColor.controlAccentColor.cgColor
                : NSColor.separatorColor.cgColor
        }
    }
}

private final class AccentPickerView: NSView {
    private let presets: [(name: String, color: NSColor)] = [
        ("Morado", NSColor(hex: "#5C40F2")!),
        ("Azul", NSColor(hex: "#087FE7")!),
        ("Turquesa", NSColor(hex: "#008A83")!),
        ("Verde", NSColor(hex: "#27833D")!),
        ("Naranja", NSColor(hex: "#D45D00")!),
        ("Rojo", NSColor(hex: "#D73333")!)
    ]
    private var presetButtons: [NSButton] = []
    private let colorWell = WheelColorWell()
    private let hexField = NSTextField()
    private let redField = NSTextField()
    private let greenField = NSTextField()
    private let blueField = NSTextField()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        translatesAutoresizingMaskIntoConstraints = false
        buildView()
        updateControls(color: FocnotesPalette.accent)
        updateSelection()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildView() {
        let presetStack = NSStackView()
        presetStack.orientation = .horizontal
        presetStack.alignment = .centerY
        presetStack.spacing = 10

        for (index, preset) in presets.enumerated() {
            let button = NSButton(title: "", target: self, action: #selector(selectPreset(_:)))
            button.tag = index
            button.isBordered = false
            button.wantsLayer = true
            button.layer?.backgroundColor = preset.color.cgColor
            button.layer?.cornerRadius = 14
            button.layer?.borderWidth = 2
            button.toolTip = preset.name
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 28),
                button.heightAnchor.constraint(equalToConstant: 28)
            ])
            presetButtons.append(button)
            presetStack.addArrangedSubview(button)
        }

        configureField(hexField, width: 86, placeholder: "#5C40F2")
        [redField, greenField, blueField].forEach { configureField($0, width: 46, placeholder: "0") }
        colorWell.target = self
        colorWell.action = #selector(changeColorWell(_:))
        colorWell.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorWell.widthAnchor.constraint(equalToConstant: 54),
            colorWell.heightAnchor.constraint(equalToConstant: 30)
        ])

        let customControls = NSStackView(views: [
            fieldLabel("HEX"), hexField,
            fieldLabel("R"), redField,
            fieldLabel("G"), greenField,
            fieldLabel("B"), blueField,
            colorWell
        ])
        customControls.orientation = .horizontal
        customControls.alignment = .centerY
        customControls.spacing = 7

        let hint = NSTextField(wrappingLabelWithString: "Elige un color rápido o escribe un color HEX o RGB.")
        hint.font = .systemFont(ofSize: 11)
        hint.textColor = .secondaryLabelColor

        let stack = NSStackView(views: [presetStack, customControls, hint])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }

    private func configureField(_ field: NSTextField, width: CGFloat, placeholder: String) {
        field.placeholderString = placeholder
        field.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        field.alignment = .center
        field.target = self
        field.action = field === hexField ? #selector(changeHex(_:)) : #selector(changeRGB(_:))
        field.translatesAutoresizingMaskIntoConstraints = false
        field.widthAnchor.constraint(equalToConstant: width).isActive = true
    }

    private func fieldLabel(_ title: String) -> NSTextField {
        let label = NSTextField(labelWithString: title)
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textColor = .secondaryLabelColor
        return label
    }

    @objc private func selectPreset(_ sender: NSButton) {
        guard presets.indices.contains(sender.tag) else { return }
        applyColor(presets[sender.tag].color)
    }

    @objc private func changeColorWell(_ sender: NSColorWell) {
        applyColor(sender.color)
    }

    @objc private func changeHex(_ sender: NSTextField) {
        guard let color = NSColor(hex: sender.stringValue) else {
            NSSound.beep()
            updateControls(color: FocnotesPalette.accent)
            return
        }
        applyColor(color)
    }

    @objc private func changeRGB(_ sender: NSTextField) {
        let values = [redField, greenField, blueField].compactMap { Int($0.stringValue) }
        guard values.count == 3, values.allSatisfy({ (0...255).contains($0) }) else {
            NSSound.beep()
            updateControls(color: FocnotesPalette.accent)
            return
        }
        applyColor(NSColor(
            srgbRed: CGFloat(values[0]) / 255,
            green: CGFloat(values[1]) / 255,
            blue: CGFloat(values[2]) / 255,
            alpha: 1
        ))
    }

    private func applyColor(_ color: NSColor) {
        AppPreferences.setAccentColor(color)
        updateControls(color: color)
        updateSelection()
    }

    private func updateControls(color: NSColor) {
        colorWell.color = color
        hexField.stringValue = color.hexValue
        let rgb = color.rgbComponents255
        redField.stringValue = String(rgb.red)
        greenField.stringValue = String(rgb.green)
        blueField.stringValue = String(rgb.blue)
    }

    private func updateSelection() {
        let selectedHex = FocnotesPalette.accent.hexValue
        for (index, button) in presetButtons.enumerated() {
            button.layer?.borderColor = presets[index].color.hexValue == selectedHex
                ? NSColor.controlAccentColor.cgColor
                : NSColor.separatorColor.cgColor
        }
    }
}

private enum SettingsSection: Int, CaseIterable {
    case general
    case editor
    case appearance
    case about

    var title: String {
        switch self {
        case .general: return "General"
        case .editor: return "Editor"
        case .appearance: return "Apariencia"
        case .about: return "Acerca de"
        }
    }

    var symbolName: String {
        switch self {
        case .general: return "seal"
        case .editor: return "textformat"
        case .appearance: return "paintpalette"
        case .about: return "info.circle"
        }
    }
}

final class SettingsViewController: NSViewController, NSTextFieldDelegate {
    var commandAction: (() -> Void)?

    private let contentView = NSView()
    private var sidebarButtons: [SettingsSection: NSButton] = [:]
    private var activeSection = SettingsSection.general
    private weak var opacitySlider: NSSlider?
    private weak var opacityField: NSTextField?
    private weak var blurSlider: NSSlider?
    private weak var blurField: NSTextField?

    override func loadView() {
        let root = NSView()
        root.wantsLayer = true
        root.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        view = root

        let sidebar = NSVisualEffectView()
        sidebar.material = .sidebar
        sidebar.blendingMode = .behindWindow
        sidebar.state = .active
        sidebar.translatesAutoresizingMaskIntoConstraints = false

        let brandImage = NSImageView(image: sealIcon(size: 38, template: false))
        brandImage.translatesAutoresizingMaskIntoConstraints = false
        let brandLabel = NSTextField(labelWithString: "Focnotes")
        brandLabel.font = .systemFont(ofSize: 17, weight: .bold)
        let brand = NSStackView(views: [brandImage, brandLabel])
        brand.orientation = .horizontal
        brand.alignment = .centerY
        brand.spacing = 9

        let navigation = NSStackView()
        navigation.orientation = .vertical
        navigation.alignment = .leading
        navigation.spacing = 5
        for section in SettingsSection.allCases {
            let button = NSButton(title: section.title, target: self, action: #selector(selectSection(_:)))
            button.tag = section.rawValue
            button.isBordered = false
            button.bezelStyle = .recessed
            button.alignment = .left
            button.font = .systemFont(ofSize: 13, weight: .medium)
            button.image = NSImage(systemSymbolName: section.symbolName, accessibilityDescription: section.title)
            button.imagePosition = .imageLeading
            button.imageScaling = .scaleProportionallyDown
            button.wantsLayer = true
            button.layer?.cornerRadius = 7
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalToConstant: 148).isActive = true
            button.heightAnchor.constraint(equalToConstant: 34).isActive = true
            sidebarButtons[section] = button
            navigation.addArrangedSubview(button)
        }

        let sidebarStack = NSStackView(views: [brand, navigation])
        sidebarStack.orientation = .vertical
        sidebarStack.alignment = .leading
        sidebarStack.spacing = 22
        sidebarStack.translatesAutoresizingMaskIntoConstraints = false
        sidebar.addSubview(sidebarStack)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(sidebar)
        root.addSubview(contentView)
        NSLayoutConstraint.activate([
            sidebar.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            sidebar.topAnchor.constraint(equalTo: root.topAnchor),
            sidebar.bottomAnchor.constraint(equalTo: root.bottomAnchor),
            sidebar.widthAnchor.constraint(equalToConstant: 176),
            sidebarStack.leadingAnchor.constraint(equalTo: sidebar.leadingAnchor, constant: 14),
            sidebarStack.trailingAnchor.constraint(lessThanOrEqualTo: sidebar.trailingAnchor, constant: -14),
            sidebarStack.topAnchor.constraint(equalTo: sidebar.topAnchor, constant: 28),
            brandImage.widthAnchor.constraint(equalToConstant: 38),
            brandImage.heightAnchor.constraint(equalToConstant: 38),
            contentView.leadingAnchor.constraint(equalTo: sidebar.trailingAnchor),
            contentView.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: root.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: root.bottomAnchor)
        ])
        showSection(.general)
    }

    @objc private func selectSection(_ sender: NSButton) {
        guard let section = SettingsSection(rawValue: sender.tag) else { return }
        showSection(section)
    }

    private func showSection(_ section: SettingsSection) {
        activeSection = section
        sidebarButtons.forEach { key, button in
            button.layer?.backgroundColor = key == section
                ? FocnotesPalette.paper.withAlphaComponent(0.78).cgColor
                : NSColor.clear.cgColor
        }
        contentView.subviews.forEach { $0.removeFromSuperview() }

        let sectionView: NSView
        switch section {
        case .general: sectionView = generalView()
        case .editor: sectionView = editorView()
        case .appearance: sectionView = appearanceView()
        case .about: sectionView = aboutView()
        }
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sectionView)
        NSLayoutConstraint.activate([
            sectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            sectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            sectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            sectionView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    private func generalView() -> NSView {
        let focusShortcut = ShortcutRecorderButton(shortcut: AppPreferences.focusShortcut)
        focusShortcut.onShortcutChanged = { shortcut in
            AppPreferences.setFocusShortcut(shortcut)
        }

        let alwaysOnTop = NSSwitch()
        alwaysOnTop.state = AppPreferences.alwaysOnTop ? .on : .off
        alwaysOnTop.tag = 1
        alwaysOnTop.target = self
        alwaysOnTop.action = #selector(togglePreference(_:))

        let allSpaces = NSSwitch()
        allSpaces.state = AppPreferences.showOnAllSpaces ? .on : .off
        allSpaces.tag = 2
        allSpaces.target = self
        allSpaces.action = #selector(togglePreference(_:))

        let reopenLastNote = NSSwitch()
        reopenLastNote.state = AppPreferences.reopenLastNote ? .on : .off
        reopenLastNote.tag = 3
        reopenLastNote.target = self
        reopenLastNote.action = #selector(togglePreference(_:))

        return sectionStack(title: "General", groups: [
            ("ATAJO", [
                settingRow(
                    title: "Enfocar la nota",
                    detail: "Trae Focnotes al frente y coloca el cursor en el editor.",
                    control: focusShortcut
                )
            ]),
            ("VENTANA", [
                settingRow(
                    title: "Mantener sobre otras ventanas",
                    detail: "La nota permanece visible mientras usas otras aplicaciones.",
                    control: alwaysOnTop
                ),
                settingRow(
                    title: "Mostrar en todos los escritorios",
                    detail: "La nota acompaña tus cambios entre Spaces.",
                    control: allSpaces
                )
            ]),
            ("INICIO", [
                settingRow(
                    title: "Abrir la última nota",
                    detail: "Al iniciar, recupera la última nota interna o el último archivo abierto.",
                    control: reopenLastNote
                )
            ])
        ])
    }

    private func editorView() -> NSView {
        let fontSize = NSPopUpButton()
        [(13, "Pequeño"), (15, "Predeterminado"), (17, "Grande")].forEach { size, label in
            fontSize.addItem(withTitle: label)
            fontSize.lastItem?.tag = size
        }
        fontSize.selectItem(withTag: Int(AppPreferences.editorFontSize))
        fontSize.target = self
        fontSize.action = #selector(changeFontSize(_:))

        return sectionStack(title: "Editor", groups: [
            ("TEXTO", [
                settingRow(
                    title: "Tamaño del texto",
                    detail: "Ajusta el contenido y los encabezados de la nota.",
                    control: fontSize
                )
            ])
        ])
    }

    private func appearanceView() -> NSView {
        let opacityControl = makeOpacityControl()
        let blurControl = makeBlurControl()
        return sectionStack(title: "Apariencia", groups: [
            ("EFECTO DE FONDO", [
                settingRow(
                    title: "Opacidad",
                    detail: "Ajusta la transparencia del color de la nota.",
                    control: opacityControl
                ),
                settingRow(
                    title: "Blur",
                    detail: "Ajusta la intensidad visual del desenfoque del fondo.",
                    control: blurControl
                )
            ]),
            ("COLOR DE LA NOTA", [ThemePickerView()]),
            ("COLOR DE ACENTO", [AccentPickerView()])
        ])
    }

    private func makeOpacityControl() -> NSView {
        let slider = NSSlider(
            value: AppPreferences.noteOpacity,
            minValue: 20,
            maxValue: 100,
            target: self,
            action: #selector(changeOpacitySlider(_:))
        )
        slider.numberOfTickMarks = 5
        slider.tickMarkPosition = .below
        slider.allowsTickMarkValuesOnly = true
        slider.isContinuous = true
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.widthAnchor.constraint(equalToConstant: 150).isActive = true

        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimum = 20
        formatter.maximum = 100
        formatter.allowsFloats = false

        let field = NSTextField(string: String(Int(AppPreferences.noteOpacity)))
        field.alignment = .right
        field.formatter = formatter
        field.target = self
        field.action = #selector(changeOpacityField(_:))
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        field.widthAnchor.constraint(equalToConstant: 44).isActive = true

        let percent = NSTextField(labelWithString: "%")
        percent.textColor = .secondaryLabelColor
        let control = NSStackView(views: [slider, field, percent])
        control.orientation = .horizontal
        control.alignment = .centerY
        control.spacing = 5

        opacitySlider = slider
        opacityField = field
        return control
    }

    private func makeBlurControl() -> NSView {
        let slider = NSSlider(
            value: AppPreferences.blurIntensity,
            minValue: 20,
            maxValue: 100,
            target: self,
            action: #selector(changeBlurSlider(_:))
        )
        slider.numberOfTickMarks = 5
        slider.tickMarkPosition = .below
        slider.allowsTickMarkValuesOnly = true
        slider.isContinuous = true
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.widthAnchor.constraint(equalToConstant: 150).isActive = true

        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimum = 20
        formatter.maximum = 100
        formatter.allowsFloats = false

        let field = NSTextField(string: String(Int(AppPreferences.blurIntensity)))
        field.alignment = .right
        field.formatter = formatter
        field.target = self
        field.action = #selector(changeBlurField(_:))
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        field.widthAnchor.constraint(equalToConstant: 44).isActive = true

        let percent = NSTextField(labelWithString: "%")
        percent.textColor = .secondaryLabelColor
        let control = NSStackView(views: [slider, field, percent])
        control.orientation = .horizontal
        control.alignment = .centerY
        control.spacing = 5

        blurSlider = slider
        blurField = field
        return control
    }

    private func aboutView() -> NSView {
        let commandInstalled = FileManager.default.fileExists(atPath: "/usr/local/bin/foc")
        let commandButton = NSButton(
            title: commandInstalled ? "Desinstalar" : "Instalar",
            target: self,
            action: #selector(toggleCommand)
        )
        commandButton.bezelStyle = .rounded

        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let identity = NSStackView(views: [
            NSImageView(image: sealIcon(size: 64, template: false)),
            makeIdentityLabels(version: version)
        ])
        identity.orientation = .horizontal
        identity.alignment = .centerY
        identity.spacing = 16

        return sectionStack(title: "Acerca de", leadingView: identity, groups: [
            ("LÍNEA DE COMANDOS", [
                settingRow(
                    title: "Comando foc",
                    detail: commandInstalled
                        ? "Instalado en /usr/local/bin/foc."
                        : "Abre notas desde Terminal con foc archivo.md.",
                    control: commandButton
                )
            ])
        ])
    }

    private func makeIdentityLabels(version: String) -> NSView {
        let name = NSTextField(labelWithString: "Focnotes")
        name.font = .systemFont(ofSize: 20, weight: .bold)
        let detail = NSTextField(labelWithString: "Versión \(version)\nNotas flotantes para macOS")
        detail.textColor = .secondaryLabelColor
        detail.font = .systemFont(ofSize: 12)
        detail.maximumNumberOfLines = 2
        let labels = NSStackView(views: [name, detail])
        labels.orientation = .vertical
        labels.alignment = .leading
        labels.spacing = 3
        return labels
    }

    private func sectionStack(
        title: String,
        leadingView: NSView? = nil,
        groups: [(String, [NSView])]
    ) -> NSView {
        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 20
        stack.addArrangedSubview(titleLabel)
        if let leadingView {
            stack.addArrangedSubview(leadingView)
        }
        for (groupTitle, rows) in groups {
            let label = NSTextField(labelWithString: groupTitle)
            label.font = .systemFont(ofSize: 11, weight: .medium)
            label.textColor = .secondaryLabelColor

            let card = NSStackView(views: rows)
            card.orientation = .vertical
            card.alignment = .width
            card.spacing = 1
            card.wantsLayer = true
            card.layer?.cornerRadius = 9
            card.layer?.borderWidth = 1
            card.layer?.borderColor = NSColor.separatorColor.cgColor
            card.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
            card.translatesAutoresizingMaskIntoConstraints = false

            let group = NSStackView(views: [label, card])
            group.orientation = .vertical
            group.alignment = .leading
            group.spacing = 7
            group.translatesAutoresizingMaskIntoConstraints = false
            stack.addArrangedSubview(group)
            NSLayoutConstraint.activate([
                group.widthAnchor.constraint(equalTo: stack.widthAnchor),
                card.widthAnchor.constraint(equalTo: group.widthAnchor)
            ])
        }
        return stack
    }

    private func settingRow(title: String, detail: String, control: NSView) -> NSView {
        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        let detailLabel = NSTextField(wrappingLabelWithString: detail)
        detailLabel.font = .systemFont(ofSize: 11)
        detailLabel.textColor = .secondaryLabelColor
        detailLabel.maximumNumberOfLines = 2
        let labels = NSStackView(views: [titleLabel, detailLabel])
        labels.orientation = .vertical
        labels.alignment = .leading
        labels.spacing = 2

        control.setContentHuggingPriority(.required, for: .horizontal)
        let row = NSStackView(views: [labels, control])
        row.orientation = .horizontal
        row.alignment = .centerY
        row.distribution = .fill
        row.spacing = 18
        row.edgeInsets = NSEdgeInsets(top: 11, left: 14, bottom: 11, right: 14)
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(greaterThanOrEqualToConstant: 64).isActive = true
        return row
    }

    @objc private func togglePreference(_ sender: NSSwitch) {
        let key: String
        switch sender.tag {
        case 1: key = AppPreferences.alwaysOnTopKey
        case 2: key = AppPreferences.showOnAllSpacesKey
        default: key = AppPreferences.reopenLastNoteKey
        }
        AppPreferences.set(sender.state == .on, forKey: key)
    }

    @objc private func changeFontSize(_ sender: NSPopUpButton) {
        AppPreferences.setEditorFontSize(CGFloat(sender.selectedTag()))
    }

    @objc private func changeOpacitySlider(_ sender: NSSlider) {
        let value = (sender.doubleValue / 20).rounded() * 20
        sender.doubleValue = value
        opacityField?.integerValue = Int(value)
        AppPreferences.setNoteOpacity(value)
    }

    @objc private func changeOpacityField(_ sender: NSTextField) {
        guard let value = Double(sender.stringValue), (20...100).contains(value) else {
            NSSound.beep()
            sender.integerValue = Int(AppPreferences.noteOpacity)
            return
        }
        opacitySlider?.doubleValue = value
        sender.integerValue = Int(value)
        AppPreferences.setNoteOpacity(value)
    }

    @objc private func changeBlurSlider(_ sender: NSSlider) {
        let value = (sender.doubleValue / 20).rounded() * 20
        sender.doubleValue = value
        blurField?.integerValue = Int(value)
        AppPreferences.setBlurIntensity(value)
    }

    @objc private func changeBlurField(_ sender: NSTextField) {
        guard let value = Double(sender.stringValue), (20...100).contains(value) else {
            NSSound.beep()
            sender.integerValue = Int(AppPreferences.blurIntensity)
            return
        }
        blurSlider?.doubleValue = value
        sender.integerValue = Int(value)
        AppPreferences.setBlurIntensity(value)
    }

    func controlTextDidEndEditing(_ notification: Notification) {
        guard let field = notification.object as? NSTextField else { return }
        if field === opacityField {
            changeOpacityField(field)
        } else if field === blurField {
            changeBlurField(field)
        }
    }

    @objc private func toggleCommand() {
        commandAction?()
        showSection(.about)
    }
}

final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    init(commandAction: @escaping () -> Void) {
        let viewController = SettingsViewController()
        viewController.commandAction = commandAction
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 720, height: 480),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Configuración de Focnotes"
        window.contentViewController = viewController
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("FocnotesSettingsWindow")
        super.init(window: window)
        window.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func present() {
        NSApp.setActivationPolicy(.regular)
        showWindow(nil)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func windowWillClose(_ notification: Notification) {
        NSApp.deactivate()
        NSApp.setActivationPolicy(.accessory)
    }
}

struct HistoryItem: Codable {
    let path: String
    var isPinned: Bool
    var lastOpened: Date
}

struct InternalNote: Codable {
    let id: String
    var text: String
    let createdAt: Date
    var updatedAt: Date
    var lastOpened: Date
    var isPinned: Bool

    init(
        id: String,
        text: String,
        createdAt: Date,
        updatedAt: Date,
        lastOpened: Date,
        isPinned: Bool = false
    ) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastOpened = lastOpened
        self.isPinned = isPinned
    }

    private enum CodingKeys: String, CodingKey {
        case id, text, createdAt, updatedAt, lastOpened, isPinned
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        lastOpened = try container.decode(Date.self, forKey: .lastOpened)
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
    }

    var title: String { NoteView.noteTitle(for: text) }
}

struct LastOpenedItem: Codable {
    enum Kind: String, Codable {
        case internalNote
        case file
    }

    let kind: Kind
    let value: String
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let historyKey = "fileHistory"
    private let internalNotesKey = "internalNotes"
    private let internalNotesRecoveryKey = "internalNotesRecoveryBackup"
    private let legacyNoteTextKey = "noteText"
    private let lastOpenedItemKey = "lastOpenedItem"
    private var panel: FloatingNotePanel?
    private var statusItem: NSStatusItem?
    private var currentFileURL: URL?
    private var currentNoteID: String?
    private var history: [HistoryItem] = []
    private var internalNotes: [InternalNote] = []
    private var pendingDefaultPanel: DispatchWorkItem?
    private var settingsWindowController: SettingsWindowController?
    private var preferencesObserver: NSObjectProtocol?
    private var focusHotKey: EventHotKeyRef?
    private var hotKeyHandler: EventHandlerRef?
    private var pendingOpenURL: URL?
    private var isReadyForFiles = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        loadHistory()
        loadInternalNotes()
        let commandLineURL = CommandLine.arguments.dropFirst().first { !$0.hasPrefix("-psn_") }.map {
            URL(fileURLWithPath: $0).standardizedFileURL
        }
        let launchFileURL = pendingOpenURL ?? commandLineURL
        pendingOpenURL = nil
        createMainMenu()
        createStatusMenu()
        installHotKeyHandler()
        registerFocusHotKey()
        preferencesObserver = NotificationCenter.default.addObserver(
            forName: AppPreferences.changedNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applyPanelPreferences()
            self?.registerFocusHotKey()
        }
        isReadyForFiles = true
        if let launchFileURL {
            openFile(launchFileURL)
        } else {
            let workItem = DispatchWorkItem { [weak self] in
                guard let self, self.panel == nil else { return }
                self.openInitialNote()
            }
            pendingDefaultPanel = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: workItem)
        }
    }

    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        guard let filename = filenames.first else {
            sender.reply(toOpenOrPrint: .failure)
            return
        }
        let url = URL(fileURLWithPath: filename).standardizedFileURL
        if isReadyForFiles {
            openFile(url)
            focusNote()
        } else {
            pendingOpenURL = url
        }
        sender.reply(toOpenOrPrint: .success)
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let focusHotKey {
            UnregisterEventHotKey(focusHotKey)
        }
        if let hotKeyHandler {
            RemoveEventHandler(hotKeyHandler)
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        focusNote()
        return true
    }

    private func installHotKeyHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData in
                guard let event, let userData else { return noErr }
                var hotKeyID = EventHotKeyID()
                let status = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                guard status == noErr, hotKeyID.id == 1 else { return noErr }
                let delegate = Unmanaged<AppDelegate>.fromOpaque(userData).takeUnretainedValue()
                DispatchQueue.main.async {
                    delegate.focusNote()
                }
                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &hotKeyHandler
        )
    }

    private func registerFocusHotKey() {
        if let focusHotKey {
            UnregisterEventHotKey(focusHotKey)
            self.focusHotKey = nil
        }
        let shortcut = AppPreferences.focusShortcut
        let hotKeyID = EventHotKeyID(signature: OSType(0x464F_434E), id: 1)
        RegisterEventHotKey(
            shortcut.keyCode,
            shortcut.modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &focusHotKey
        )
    }

    private func focusNote() {
        pendingDefaultPanel?.cancel()
        pendingDefaultPanel = nil
        if panel == nil {
            if let currentFileURL {
                createPanel(fileURL: currentFileURL)
            } else if let currentNoteID {
                openInternalNote(id: currentNoteID)
            } else {
                openInitialNote()
            }
        }
        guard let panel else { return }
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        DispatchQueue.main.async { [weak panel] in
            guard let panel else { return }
            panel.makeKey()
            (panel.contentView as? NoteView)?.focusEditor()
        }
    }

    private func openFile(_ url: URL) {
        pendingDefaultPanel?.cancel()
        pendingDefaultPanel = nil
        currentFileURL = url
        currentNoteID = nil
        recordFile(url)
        saveLastOpenedItem(LastOpenedItem(kind: .file, value: url.path))
        if let panel {
            let size = panel.contentView?.bounds.size ?? panel.contentRect(forFrameRect: panel.frame).size
            panel.title = url.deletingPathExtension().lastPathComponent
            panel.contentView = NoteView(
                frame: NSRect(origin: .zero, size: size),
                fileURL: url,
                titleChanged: { [weak panel] title in panel?.title = title },
                newNoteRequested: { [weak self] in self?.createInternalNote() }
            )
            panel.contentView?.layoutSubtreeIfNeeded()
            panel.contentView?.displayIfNeeded()
            panel.orderFrontRegardless()
        } else {
            createPanel(fileURL: url)
        }
    }

    private func openInternalNote(id: String) {
        guard let index = internalNotes.firstIndex(where: { $0.id == id }) else {
            openDefaultInternalNote()
            return
        }
        pendingDefaultPanel?.cancel()
        pendingDefaultPanel = nil
        currentFileURL = nil
        currentNoteID = id
        internalNotes[index].lastOpened = Date()
        saveInternalNotes()
        saveLastOpenedItem(LastOpenedItem(kind: .internalNote, value: id))

        let note = internalNotes[index]
        if let panel {
            let size = panel.contentView?.bounds.size ?? panel.contentRect(forFrameRect: panel.frame).size
            panel.title = note.title
            panel.contentView = makeNoteView(frame: NSRect(origin: .zero, size: size), note: note, panel: panel)
            panel.contentView?.layoutSubtreeIfNeeded()
            panel.contentView?.displayIfNeeded()
            panel.orderFrontRegardless()
        } else {
            createPanel(fileURL: nil, note: note)
        }
    }

    @objc private func createInternalNote() {
        let now = Date()
        let note = InternalNote(id: UUID().uuidString, text: "", createdAt: now, updatedAt: now, lastOpened: now)
        internalNotes.append(note)
        saveInternalNotes()
        openInternalNote(id: note.id)
        focusNote()
    }

    private func openInitialNote() {
        if AppPreferences.reopenLastNote,
           let item = loadLastOpenedItem() {
            switch item.kind {
            case .internalNote where internalNotes.contains(where: { $0.id == item.value }):
                openInternalNote(id: item.value)
                return
            case .file where FileManager.default.fileExists(atPath: item.value):
                openFile(URL(fileURLWithPath: item.value).standardizedFileURL)
                return
            default:
                break
            }
        }
        openDefaultInternalNote()
    }

    private func openDefaultInternalNote() {
        if let note = internalNotes.min(by: { $0.createdAt < $1.createdAt }) {
            openInternalNote(id: note.id)
        } else {
            createInternalNote()
        }
    }

    private func createStatusMenu() {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = sealIcon(size: 18, template: true)
        statusItem.button?.imagePosition = .imageOnly
        statusItem.button?.toolTip = "Focnotes"
        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu
        self.statusItem = statusItem
    }

    private func createMainMenu() {
        let mainMenu = NSMenu()
        let applicationItem = NSMenuItem(title: "Focnotes", action: nil, keyEquivalent: "")
        let applicationMenu = NSMenu()

        let settingsItem = NSMenuItem(
            title: "Configuración…",
            action: #selector(openSettings(_:)),
            keyEquivalent: ","
        )
        settingsItem.target = self
        applicationMenu.addItem(settingsItem)
        applicationMenu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Salir de Focnotes",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        quitItem.target = NSApp
        applicationMenu.addItem(quitItem)
        applicationItem.submenu = applicationMenu
        mainMenu.addItem(applicationItem)

        let fileItem = NSMenuItem(title: "Archivo", action: nil, keyEquivalent: "")
        let fileMenu = NSMenu(title: "Archivo")
        let newNoteItem = NSMenuItem(
            title: "Nueva nota",
            action: #selector(createInternalNote),
            keyEquivalent: "n"
        )
        newNoteItem.target = self
        fileMenu.addItem(newNoteItem)
        fileMenu.addItem(.separator())
        fileMenu.addItem(NSMenuItem(
            title: "Cerrar",
            action: #selector(NSWindow.performClose(_:)),
            keyEquivalent: "w"
        ))
        fileItem.submenu = fileMenu
        mainMenu.addItem(fileItem)

        let editItem = NSMenuItem(title: "Edición", action: nil, keyEquivalent: "")
        let editMenu = NSMenu(title: "Edición")
        editMenu.addItem(NSMenuItem(title: "Deshacer", action: Selector(("undo:")), keyEquivalent: "z"))
        let redoItem = NSMenuItem(title: "Rehacer", action: Selector(("redo:")), keyEquivalent: "z")
        redoItem.keyEquivalentModifierMask = [.command, .shift]
        editMenu.addItem(redoItem)
        editMenu.addItem(.separator())
        editMenu.addItem(NSMenuItem(title: "Cortar", action: #selector(NSText.cut(_:)), keyEquivalent: "x"))
        editMenu.addItem(NSMenuItem(title: "Copiar", action: #selector(NSText.copy(_:)), keyEquivalent: "c"))
        editMenu.addItem(NSMenuItem(title: "Pegar", action: #selector(NSText.paste(_:)), keyEquivalent: "v"))
        editMenu.addItem(NSMenuItem(title: "Seleccionar todo", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))
        editItem.submenu = editMenu
        mainMenu.addItem(editItem)

        NSApp.mainMenu = mainMenu
    }

    func menuWillOpen(_ menu: NSMenu) {
        rebuildMenu(menu)
    }

    private func rebuildMenu(_ menu: NSMenu) {
        menu.removeAllItems()

        let pinnedItems: [(Date, NSMenuItem)] =
            internalNotes.filter(\.isPinned).map { ($0.lastOpened, internalNoteMenuItem(for: $0)) }
            + history.filter(\.isPinned).map { ($0.lastOpened, fileMenuItem(for: $0)) }
        if !pinnedItems.isEmpty {
            menu.addItem(menuHeader("Fijados"))
            pinnedItems.sorted { $0.0 > $1.0 }.forEach { menu.addItem($0.1) }
            menu.addItem(.separator())
        }

        let newNoteItem = NSMenuItem(title: "Nueva nota", action: #selector(createInternalNote), keyEquivalent: "n")
        newNoteItem.target = self
        menu.addItem(newNoteItem)

        let regularNotes = internalNotes.filter { !$0.isPinned }.sorted { $0.lastOpened > $1.lastOpened }
        if !regularNotes.isEmpty {
            menu.addItem(.separator())
            menu.addItem(menuHeader("Notas sin archivo"))
            regularNotes.forEach { menu.addItem(internalNoteMenuItem(for: $0)) }
        }

        let recent = history.filter { !$0.isPinned }.sorted { $0.lastOpened > $1.lastOpened }
        if !recent.isEmpty {
            menu.addItem(.separator())
            menu.addItem(menuHeader("Archivos recientes"))
            recent.prefix(10).forEach { menu.addItem(fileMenuItem(for: $0)) }
        }
        if !history.isEmpty {
            menu.addItem(.separator())
            let clearItem = NSMenuItem(title: "Limpiar historial de archivos", action: #selector(clearHistory), keyEquivalent: "")
            clearItem.target = self
            menu.addItem(clearItem)
        }

        menu.addItem(.separator())
        let settingsItem = NSMenuItem(
            title: "Configuración…",
            action: #selector(openSettings(_:)),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())
        let quitItem = NSMenuItem(title: "Salir de Focnotes", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quitItem.target = NSApp
        menu.addItem(quitItem)
    }

    private func menuHeader(_ title: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }

    private func fileMenuItem(for item: HistoryItem) -> NSMenuItem {
        let fileItem = NSMenuItem(title: URL(fileURLWithPath: item.path).lastPathComponent, action: nil, keyEquivalent: "")
        fileItem.toolTip = item.path
        fileItem.state = currentFileURL?.path == item.path ? .on : .off
        let submenu = NSMenu()

        let openItem = NSMenuItem(title: "Abrir", action: #selector(openHistoryFile(_:)), keyEquivalent: "")
        openItem.target = self
        openItem.representedObject = item.path
        submenu.addItem(openItem)

        let pinItem = NSMenuItem(
            title: item.isPinned ? "Desfijar" : "Fijar",
            action: #selector(togglePinned(_:)),
            keyEquivalent: ""
        )
        pinItem.target = self
        pinItem.representedObject = item.path
        submenu.addItem(pinItem)
        fileItem.submenu = submenu
        return fileItem
    }

    private func internalNoteMenuItem(for note: InternalNote) -> NSMenuItem {
        let noteItem = NSMenuItem(title: note.title, action: nil, keyEquivalent: "")
        noteItem.toolTip = note.text.isEmpty ? "Nota sin texto" : String(note.text.prefix(160))
        noteItem.state = currentNoteID == note.id ? .on : .off
        let submenu = NSMenu()

        let openItem = NSMenuItem(title: "Abrir", action: #selector(openHistoryNote(_:)), keyEquivalent: "")
        openItem.target = self
        openItem.representedObject = note.id
        submenu.addItem(openItem)

        let pinItem = NSMenuItem(
            title: note.isPinned ? "Desfijar" : "Fijar",
            action: #selector(toggleInternalNotePinned(_:)),
            keyEquivalent: ""
        )
        pinItem.target = self
        pinItem.representedObject = note.id
        submenu.addItem(pinItem)

        let deleteItem = NSMenuItem(title: "Eliminar", action: #selector(deleteInternalNote(_:)), keyEquivalent: "")
        deleteItem.target = self
        deleteItem.representedObject = note.id
        submenu.addItem(deleteItem)
        noteItem.submenu = submenu
        return noteItem
    }

    @objc private func openHistoryNote(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? String else { return }
        openInternalNote(id: id)
        focusNote()
    }

    @objc private func toggleInternalNotePinned(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? String,
              let index = internalNotes.firstIndex(where: { $0.id == id }) else { return }
        internalNotes[index].isPinned.toggle()
        saveInternalNotes()
    }

    @objc private func deleteInternalNote(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? String,
              let index = internalNotes.firstIndex(where: { $0.id == id }) else { return }
        internalNotes.remove(at: index)
        saveInternalNotes()
        if currentNoteID == id {
            currentNoteID = nil
            openDefaultInternalNote()
        }
    }

    @objc private func openHistoryFile(_ sender: NSMenuItem) {
        guard let path = sender.representedObject as? String else { return }
        openFile(URL(fileURLWithPath: path))
        focusNote()
    }

    @objc private func togglePinned(_ sender: NSMenuItem) {
        guard let path = sender.representedObject as? String,
              let index = history.firstIndex(where: { $0.path == path }) else { return }
        history[index].isPinned.toggle()
        saveHistory()
    }

    @objc private func clearHistory() {
        history.removeAll { !$0.isPinned }
        saveHistory()
    }

    @objc private func openSettings(_ sender: Any?) {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController { [weak self] in
                guard let self else { return }
                if FileManager.default.fileExists(atPath: "/usr/local/bin/foc") {
                    self.uninstallCommand()
                } else {
                    self.installCommand()
                }
            }
        }
        settingsWindowController?.present()
    }

    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let decoded = try? JSONDecoder().decode([HistoryItem].self, from: data) else { return }
        history = decoded
    }

    private func loadInternalNotes() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: internalNotesKey) {
            if let decoded = try? JSONDecoder().decode([InternalNote].self, from: data) {
                internalNotes = decoded
                return
            }
            defaults.set(data, forKey: internalNotesRecoveryKey)
        }

        let now = Date()
        let migratedText = defaults.string(forKey: legacyNoteTextKey) ?? ""
        internalNotes = [InternalNote(
            id: UUID().uuidString,
            text: migratedText,
            createdAt: now,
            updatedAt: now,
            lastOpened: now
        )]
        saveInternalNotes()
        defaults.removeObject(forKey: legacyNoteTextKey)
    }

    private func saveInternalNotes() {
        guard let data = try? JSONEncoder().encode(internalNotes) else { return }
        UserDefaults.standard.set(data, forKey: internalNotesKey)
    }

    private func updateInternalNote(id: String, text: String) {
        guard let index = internalNotes.firstIndex(where: { $0.id == id }) else { return }
        internalNotes[index].text = text
        internalNotes[index].updatedAt = Date()
        saveInternalNotes()
    }

    private func saveLastOpenedItem(_ item: LastOpenedItem) {
        guard let data = try? JSONEncoder().encode(item) else { return }
        UserDefaults.standard.set(data, forKey: lastOpenedItemKey)
    }

    private func loadLastOpenedItem() -> LastOpenedItem? {
        guard let data = UserDefaults.standard.data(forKey: lastOpenedItemKey) else { return nil }
        return try? JSONDecoder().decode(LastOpenedItem.self, from: data)
    }

    private func recordFile(_ url: URL) {
        let path = url.path
        if let index = history.firstIndex(where: { $0.path == path }) {
            history[index].lastOpened = Date()
        } else {
            history.append(HistoryItem(path: path, isPinned: false, lastOpened: Date()))
        }
        let pinned = history.filter(\.isPinned)
        let recent = history.filter { !$0.isPinned }.sorted { $0.lastOpened > $1.lastOpened }.prefix(50)
        history = pinned + recent
        saveHistory()
    }

    private func saveHistory() {
        guard let data = try? JSONEncoder().encode(history) else { return }
        UserDefaults.standard.set(data, forKey: historyKey)
    }

    @objc private func installCommand() {
        guard let helperURL = Bundle.main.executableURL?.deletingLastPathComponent().appendingPathComponent("foc") else {
            showInstallResult(message: "No se encontro el comando foc.", isError: true)
            return
        }

        let escapedPath = helperURL.path.replacingOccurrences(of: "'", with: "'\\''")
        runPrivilegedCommand(
            "mkdir -p /usr/local/bin && ln -sf '\(escapedPath)' /usr/local/bin/foc",
            successMessage: "El comando foc fue instalado en /usr/local/bin."
        )
    }

    @objc private func uninstallCommand() {
        runPrivilegedCommand(
            "rm -f /usr/local/bin/foc",
            successMessage: "El comando foc fue eliminado de /usr/local/bin."
        )
    }

    private func runPrivilegedCommand(_ shellCommand: String, successMessage: String) {
        let escapedCommand = shellCommand
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        let script = NSAppleScript(source: "do shell script \"\(escapedCommand)\" with administrator privileges")
        var error: NSDictionary?
        script?.executeAndReturnError(&error)

        if let error {
            let message = error[NSAppleScript.errorMessage] as? String ?? "No se pudo instalar el comando."
            showInstallResult(message: message, isError: true)
        } else {
            showInstallResult(message: successMessage, isError: false)
        }
    }

    private func showInstallResult(message: String, isError: Bool) {
        let alert = NSAlert()
        alert.alertStyle = isError ? .warning : .informational
        alert.messageText = isError ? "Error de instalacion" : "Comando instalado"
        alert.informativeText = message
        alert.runModal()
    }

    private func createPanel(fileURL: URL?, note: InternalNote? = nil) {
        if let existingPanel = panel {
            existingPanel.orderOut(nil)
            existingPanel.close()
            panel = nil
        }
        let visibleFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1200, height: 800)
        let size = NSSize(width: 360, height: 300)
        let origin = NSPoint(
            x: visibleFrame.maxX - size.width - 48,
            y: visibleFrame.maxY - size.height - 48
        )

        let panel = FloatingNotePanel(
            contentRect: NSRect(origin: origin, size: size),
            styleMask: [.borderless, .nonactivatingPanel, .resizable],
            backing: .buffered,
            defer: false
        )

        panel.title = fileURL?.deletingPathExtension().lastPathComponent ?? note?.title ?? "Nota sin título"
        if let note {
            panel.contentView = makeNoteView(frame: NSRect(origin: .zero, size: size), note: note, panel: panel)
        } else {
            panel.contentView = NoteView(
                frame: NSRect(origin: .zero, size: size),
                fileURL: fileURL,
                titleChanged: { [weak panel] title in panel?.title = title },
                newNoteRequested: { [weak self] in self?.createInternalNote() }
            )
        }
        panel.isFloatingPanel = AppPreferences.alwaysOnTop
        panel.level = AppPreferences.alwaysOnTop ? .floating : .normal
        panel.collectionBehavior = panelCollectionBehavior
        panel.hidesOnDeactivate = false
        panel.isMovableByWindowBackground = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.minSize = NSSize(width: 260, height: 180)
        panel.orderFrontRegardless()
        panel.contentView?.layoutSubtreeIfNeeded()
        panel.contentView?.displayIfNeeded()

        self.panel = panel
    }

    private func makeNoteView(frame: NSRect, note: InternalNote, panel: FloatingNotePanel) -> NoteView {
        NoteView(
            frame: frame,
            fileURL: nil,
            initialText: note.text,
            titleChanged: { [weak panel] title in
                panel?.title = title
            },
            textChanged: { [weak self] text in
                self?.updateInternalNote(id: note.id, text: text)
            },
            newNoteRequested: { [weak self] in self?.createInternalNote() }
        )
    }

    private var panelCollectionBehavior: NSWindow.CollectionBehavior {
        var behavior: NSWindow.CollectionBehavior = [.fullScreenAuxiliary, .stationary]
        if AppPreferences.showOnAllSpaces {
            behavior.insert(.canJoinAllSpaces)
        }
        return behavior
    }

    private func applyPanelPreferences() {
        guard let panel else { return }
        panel.isFloatingPanel = AppPreferences.alwaysOnTop
        panel.level = AppPreferences.alwaysOnTop ? .floating : .normal
        panel.collectionBehavior = panelCollectionBehavior
    }
}

if let exportIndex = CommandLine.arguments.firstIndex(of: "--export-icon-dir"),
   CommandLine.arguments.indices.contains(exportIndex + 1) {
    exportSealIcons(to: CommandLine.arguments[exportIndex + 1])
    exit(0)
}

UserDefaults.standard.set(100, forKey: "NSInitialToolTipDelay")
let app = NSApplication.shared
app.applicationIconImage = sealIcon(size: 512, template: false)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
