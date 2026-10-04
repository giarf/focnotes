import AppKit
import Carbon
import Markdown

enum AppPreferences {
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
    static let visibilityShortcutKeyCodeKey = "visibilityShortcutKeyCode"
    static let visibilityShortcutModifiersKey = "visibilityShortcutModifiers"
    static let visibilityShortcutLabelKey = "visibilityShortcutLabel"
    static let reopenLastNoteKey = "reopenLastNote"
    static let dailyNotesFolderKey = "dailyNotesFolder"
    static let dailyNotesDateFormatKey = "dailyNotesDateFormat"
    static let dailyNotesTemplateKey = "dailyNotesTemplate"
    static let dailyNotesShortcutKeyCodeKey = "dailyNotesShortcutKeyCode"
    static let dailyNotesShortcutModifiersKey = "dailyNotesShortcutModifiers"
    static let dailyNotesShortcutLabelKey = "dailyNotesShortcutLabel"
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
        NSColor(hex: UserDefaults.standard.string(forKey: customNoteColorKey) ?? "#FFF1A8") ?? NoteTheme.yellow.color
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

    static var visibilityShortcut: KeyboardShortcut {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: visibilityShortcutKeyCodeKey) != nil else {
            return .defaultVisibilityShortcut
        }
        return KeyboardShortcut(
            keyCode: UInt32(defaults.integer(forKey: visibilityShortcutKeyCodeKey)),
            modifiers: UInt32(defaults.integer(forKey: visibilityShortcutModifiersKey)),
            keyLabel: defaults.string(forKey: visibilityShortcutLabelKey) ?? "D"
        )
    }

    static var dailyNotesFolder: String {
        UserDefaults.standard.string(forKey: dailyNotesFolderKey) ?? ""
    }

    static var dailyNotesDateFormat: String {
        UserDefaults.standard.string(forKey: dailyNotesDateFormatKey) ?? "YYYY-MM-DD"
    }

    static var dailyNotesTemplate: String {
        UserDefaults.standard.string(forKey: dailyNotesTemplateKey) ?? ""
    }

    static var dailyNotesShortcut: KeyboardShortcut {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: dailyNotesShortcutKeyCodeKey) != nil else {
            return .defaultDailyNotesShortcut
        }
        return KeyboardShortcut(
            keyCode: UInt32(defaults.integer(forKey: dailyNotesShortcutKeyCodeKey)),
            modifiers: UInt32(defaults.integer(forKey: dailyNotesShortcutModifiersKey)),
            keyLabel: defaults.string(forKey: dailyNotesShortcutLabelKey) ?? "D"
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

    static func setVisibilityShortcut(_ shortcut: KeyboardShortcut) {
        UserDefaults.standard.set(Int(shortcut.keyCode), forKey: visibilityShortcutKeyCodeKey)
        UserDefaults.standard.set(Int(shortcut.modifiers), forKey: visibilityShortcutModifiersKey)
        UserDefaults.standard.set(shortcut.keyLabel, forKey: visibilityShortcutLabelKey)
        NotificationCenter.default.post(name: changedNotification, object: nil)
    }

    static func setDailyNotesFolder(_ path: String) {
        UserDefaults.standard.set(path, forKey: dailyNotesFolderKey)
        NotificationCenter.default.post(name: changedNotification, object: nil)
    }

    static func setDailyNotesDateFormat(_ format: String) {
        UserDefaults.standard.set(format, forKey: dailyNotesDateFormatKey)
        NotificationCenter.default.post(name: changedNotification, object: nil)
    }

    static func setDailyNotesTemplate(_ path: String) {
        UserDefaults.standard.set(path, forKey: dailyNotesTemplateKey)
        NotificationCenter.default.post(name: changedNotification, object: nil)
    }

    static func setDailyNotesShortcut(_ shortcut: KeyboardShortcut) {
        UserDefaults.standard.set(Int(shortcut.keyCode), forKey: dailyNotesShortcutKeyCodeKey)
        UserDefaults.standard.set(Int(shortcut.modifiers), forKey: dailyNotesShortcutModifiersKey)
        UserDefaults.standard.set(shortcut.keyLabel, forKey: dailyNotesShortcutLabelKey)
        NotificationCenter.default.post(name: changedNotification, object: nil)
    }
}

struct KeyboardShortcut {
    let keyCode: UInt32
    let modifiers: UInt32
    let keyLabel: String

    static let defaultFocusShortcut = KeyboardShortcut(
        keyCode: UInt32(kVK_ANSI_N),
        modifiers: UInt32(cmdKey | shiftKey),
        keyLabel: "N"
    )

    static let defaultDailyNotesShortcut = KeyboardShortcut(
        keyCode: UInt32(kVK_ANSI_D),
        modifiers: UInt32(cmdKey | shiftKey),
        keyLabel: "D"
    )

    static let defaultVisibilityShortcut = KeyboardShortcut(
        keyCode: UInt32(kVK_ANSI_D),
        modifiers: UInt32(optionKey),
        keyLabel: "D"
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

private enum DailyNotesError: LocalizedError {
    case folderNotConfigured
    case invalidDateFormat
    case invalidVault
    case invalidObsidianConfiguration

    var errorDescription: String? {
        switch self {
        case .folderNotConfigured: return "Configura primero la carpeta de notas diarias."
        case .invalidDateFormat: return "El formato de fecha no produce un nombre de archivo válido."
        case .invalidVault: return "La carpeta seleccionada no contiene un vault de Obsidian."
        case .invalidObsidianConfiguration: return "No se pudo leer la configuración de Daily Notes de Obsidian."
        }
    }
}

private enum DailyNotes {
    private struct ObsidianConfiguration: Decodable {
        let folder: String?
        let format: String?
        let template: String?
    }

    static var folderURL: URL? {
        let path = AppPreferences.dailyNotesFolder.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !path.isEmpty else { return nil }
        return URL(fileURLWithPath: (path as NSString).expandingTildeInPath).standardizedFileURL
    }

    static func fileURL(for date: Date) throws -> URL {
        guard let folderURL else { throw DailyNotesError.folderNotConfigured }
        let relative = formatter().string(from: date)
        guard !relative.isEmpty, relative != ".", relative != "..", !relative.contains(":"), !relative.hasPrefix("/") else {
            throw DailyNotesError.invalidDateFormat
        }
        let destination = folderURL.appendingPathComponent(relative).appendingPathExtension("md").standardizedFileURL
        guard destination.path.hasPrefix(folderURL.path + "/") else { throw DailyNotesError.invalidDateFormat }
        return destination
    }

    static func ensureFile(for date: Date) throws -> URL {
        let destination = try fileURL(for: date)
        guard !FileManager.default.fileExists(atPath: destination.path) else { return destination }
        try FileManager.default.createDirectory(
            at: destination.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let templatePath = AppPreferences.dailyNotesTemplate.trimmingCharacters(in: .whitespacesAndNewlines)
        let content: String
        if !templatePath.isEmpty {
            let templateURL = URL(fileURLWithPath: (templatePath as NSString).expandingTildeInPath)
            let template = try String(contentsOf: templateURL, encoding: .utf8)
            content = evaluateTemplate(template, noteDate: date, title: destination.deletingPathExtension().lastPathComponent)
        } else {
            content = ""
        }
        try content.write(to: destination, atomically: true, encoding: .utf8)
        return destination
    }

    static func date(for url: URL) -> Date? {
        guard let folderURL else { return nil }
        let path = url.standardizedFileURL.path
        guard path.hasPrefix(folderURL.path + "/"), url.pathExtension.lowercased() == "md" else { return nil }
        let relativePath = String(path.dropFirst(folderURL.path.count + 1).dropLast(3))
        guard let date = formatter().date(from: relativePath), formatter().string(from: date) == relativePath else { return nil }
        return Calendar.current.startOfDay(for: date)
    }

    static func existingFiles() -> [(date: Date, url: URL)] {
        guard let folderURL,
              let enumerator = FileManager.default.enumerator(
                at: folderURL,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
              ) else { return [] }
        return enumerator.compactMap { item -> (Date, URL)? in
            guard let url = item as? URL,
                  (try? url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true,
                  let date = date(for: url) else { return nil }
            return (date, url.standardizedFileURL)
        }.sorted { $0.0 < $1.0 }
    }

    static func importObsidianConfiguration(from vaultURL: URL) throws {
        let configurationURL = vaultURL.appendingPathComponent(".obsidian/daily-notes.json")
        guard FileManager.default.fileExists(atPath: configurationURL.path) else { throw DailyNotesError.invalidVault }
        guard let data = try? Data(contentsOf: configurationURL),
              let configuration = try? JSONDecoder().decode(ObsidianConfiguration.self, from: data) else {
            throw DailyNotesError.invalidObsidianConfiguration
        }
        let folder = configuration.folder?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let template = configuration.template?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        AppPreferences.setDailyNotesFolder(vaultURL.appendingPathComponent(folder).standardizedFileURL.path)
        AppPreferences.setDailyNotesDateFormat(configuration.format ?? "YYYY-MM-DD")
        if template.isEmpty {
            AppPreferences.setDailyNotesTemplate("")
        } else {
            var templateURL = vaultURL.appendingPathComponent(template)
            if templateURL.pathExtension.isEmpty { templateURL.appendPathExtension("md") }
            AppPreferences.setDailyNotesTemplate(templateURL.standardizedFileURL.path)
        }
    }

    static func importDetectedObsidianConfigurationIfNeeded() {
        guard AppPreferences.dailyNotesFolder.isEmpty else { return }
        let home = FileManager.default.homeDirectoryForCurrentUser
        let candidates = [
            home.appendingPathComponent("Nextcloud/Obsidian"),
            home.appendingPathComponent("Documents/Obsidian")
        ]
        for candidate in candidates where FileManager.default.fileExists(
            atPath: candidate.appendingPathComponent(".obsidian/daily-notes.json").path
        ) {
            try? importObsidianConfiguration(from: candidate)
            return
        }
    }

    static func evaluateTemplate(_ template: String, noteDate: Date, title: String) -> String {
        var output = template.replacingOccurrences(of: "<% tp.file.title %>", with: title)
        output = output.replacingOccurrences(of: "{{title}}", with: title)

        let pattern = #"<%\s*tp\.date\.now\(\s*"([^"]+)"(?:\s*,\s*(-?\d+))?(?:\s*,\s*tp\.file\.title\s*,\s*"([^"]+)")?\s*\)\s*%>"#
        if let expression = try? NSRegularExpression(pattern: pattern) {
            let matches = expression.matches(in: output, range: NSRange(location: 0, length: (output as NSString).length))
            for match in matches.reversed() {
                let source = output as NSString
                let format = source.substring(with: match.range(at: 1))
                let offset = match.range(at: 2).location == NSNotFound
                    ? 0
                    : Int(source.substring(with: match.range(at: 2))) ?? 0
                let date = Calendar.current.date(byAdding: .day, value: offset, to: noteDate) ?? noteDate
                let replacement = makeFormatter(format: format).string(from: date)
                output = (output as NSString).replacingCharacters(in: match.range, with: replacement)
            }
        }

        let corePattern = #"\{\{date(?::([^}]+))?\}\}"#
        if let expression = try? NSRegularExpression(pattern: corePattern) {
            let matches = expression.matches(in: output, range: NSRange(location: 0, length: (output as NSString).length))
            for match in matches.reversed() {
                let source = output as NSString
                let format = match.range(at: 1).location == NSNotFound ? "YYYY-MM-DD" : source.substring(with: match.range(at: 1))
                output = (output as NSString).replacingCharacters(
                    in: match.range,
                    with: makeFormatter(format: format).string(from: noteDate)
                )
            }
        }
        output = output.replacingOccurrences(of: "{{time}}", with: makeFormatter(format: "HH:mm").string(from: noteDate))
        output = output.replacingOccurrences(of: #"<%\s*tp\.file\.cursor\([^)]*\)\s*%>"#, with: "", options: .regularExpression)
        return output
    }

    private static func formatter() -> DateFormatter {
        makeFormatter(format: AppPreferences.dailyNotesDateFormat)
    }

    private static func makeFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .current
        formatter.isLenient = false
        formatter.dateFormat = convertMomentFormat(format)
        return formatter
    }

    private static func convertMomentFormat(_ format: String) -> String {
        var result = format
        for (moment, cocoa) in [
            ("dddd", "EEEE"), ("ddd", "EEE"), ("YYYY", "yyyy"), ("YY", "yy"),
            ("DD", "dd"), ("D", "d")
        ] {
            result = result.replacingOccurrences(of: moment, with: cocoa)
        }
        return result
    }
}

final class FocusShadowView: NSView {
    private let shadowCard = NSView()
    private let margin: CGFloat = 34

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        shadowCard.wantsLayer = true
        shadowCard.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.01).cgColor
        shadowCard.layer?.cornerRadius = 10
        shadowCard.layer?.shadowColor = NSColor.black.cgColor
        shadowCard.layer?.shadowOpacity = 0.34
        shadowCard.layer?.shadowRadius = 26
        shadowCard.layer?.shadowOffset = CGSize(width: 0, height: -10)
        addSubview(shadowCard)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()
        shadowCard.frame = bounds.insetBy(dx: margin, dy: margin)
        shadowCard.layer?.shadowPath = CGPath(
            roundedRect: shadowCard.bounds,
            cornerWidth: 10,
            cornerHeight: 10,
            transform: nil
        )
    }
}

final class FocusShadowPanel: NSPanel {
    static let margin: CGFloat = 34

    init(around frame: NSRect) {
        super.init(
            contentRect: frame.insetBy(dx: -Self.margin, dy: -Self.margin),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        contentView = FocusShadowView(frame: NSRect(origin: .zero, size: self.frame.size))
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        ignoresMouseEvents = true
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
    }

    func updateFrame(around frame: NSRect) {
        setFrame(frame.insetBy(dx: -Self.margin, dy: -Self.margin), display: true)
    }
}

final class FloatingNotePanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
    private(set) var isVisuallyActive = false
    private var focusShadowPanel: FocusShadowPanel?

    func installFocusShadow() {
        guard focusShadowPanel == nil else { return }
        let shadowPanel = FocusShadowPanel(around: frame)
        shadowPanel.collectionBehavior = collectionBehavior
        addChildWindow(shadowPanel, ordered: .below)
        shadowPanel.orderOut(nil)
        focusShadowPanel = shadowPanel
    }

    func setVisualFocus(_ active: Bool) {
        guard isVisuallyActive != active else { return }
        isVisuallyActive = active
        (contentView as? NoteView)?.updateWindowFocusAppearance()
        guard let focusShadowPanel else { return }
        if active {
            focusShadowPanel.updateFrame(around: frame)
            focusShadowPanel.orderFront(nil)
        } else {
            focusShadowPanel.orderOut(nil)
        }
    }

    override func becomeKey() {
        super.becomeKey()
        setVisualFocus(true)
    }

    override func resignKey() {
        super.resignKey()
        setVisualFocus(false)
    }

    override func sendEvent(_ event: NSEvent) {
        if event.type == .leftMouseDown || event.type == .rightMouseDown {
            setVisualFocus(true)
        }
        super.sendEvent(event)
    }

    override func setFrame(_ frameRect: NSRect, display flag: Bool) {
        super.setFrame(frameRect, display: flag)
        focusShadowPanel?.updateFrame(around: frameRect)
    }

    override func close() {
        if let focusShadowPanel {
            removeChildWindow(focusShadowPanel)
            focusShadowPanel.close()
            self.focusShadowPanel = nil
        }
        super.close()
    }
}

final class TitleBarControlButton: NSButton {
    enum Glyph {
        case close
        case plus
    }

    private let activeColor: NSColor
    private let glyph: Glyph
    private var trackingArea: NSTrackingArea?
    private var windowObservers: [NSObjectProtocol] = []
    private var isPointerInside = false

    init(activeColor: NSColor, glyph: Glyph) {
        self.activeColor = activeColor
        self.glyph = glyph
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        windowObservers.forEach(NotificationCenter.default.removeObserver)
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        windowObservers.forEach(NotificationCenter.default.removeObserver)
        windowObservers.removeAll()
        guard let window else { return }

        for notification in [NSWindow.didBecomeKeyNotification, NSWindow.didResignKeyNotification] {
            windowObservers.append(NotificationCenter.default.addObserver(
                forName: notification,
                object: window,
                queue: .main
            ) { [weak self] _ in
                self?.needsDisplay = true
            })
        }
        needsDisplay = true
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea {
            removeTrackingArea(trackingArea)
        }
        let area = NSTrackingArea(
            rect: .zero,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        trackingArea = area
    }

    override func resetCursorRects() {
        super.resetCursorRects()
        addCursorRect(bounds, cursor: .pointingHand)
    }

    override func mouseEntered(with event: NSEvent) {
        isPointerInside = true
        needsDisplay = true
    }

    override func mouseExited(with event: NSEvent) {
        isPointerInside = false
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let diameter: CGFloat = 12
        let circleRect = NSRect(
            x: bounds.midX - diameter / 2,
            y: bounds.midY - diameter / 2,
            width: diameter,
            height: diameter
        )
        let isWindowActive = (window as? FloatingNotePanel)?.isVisuallyActive ?? window?.isKeyWindow == true
        let circleColor = isWindowActive || isPointerInside
            ? activeColor
            : NSColor.secondaryLabelColor.withAlphaComponent(0.38)
        circleColor.setFill()
        NSBezierPath(ovalIn: circleRect).fill()

        guard isPointerInside else { return }
        NSColor.black.withAlphaComponent(0.55).setStroke()
        let inset: CGFloat = 3.5
        let symbol = NSBezierPath()
        symbol.lineWidth = 1
        symbol.lineCapStyle = .round
        switch glyph {
        case .close:
            symbol.move(to: NSPoint(x: circleRect.minX + inset, y: circleRect.minY + inset))
            symbol.line(to: NSPoint(x: circleRect.maxX - inset, y: circleRect.maxY - inset))
            symbol.move(to: NSPoint(x: circleRect.minX + inset, y: circleRect.maxY - inset))
            symbol.line(to: NSPoint(x: circleRect.maxX - inset, y: circleRect.minY + inset))
        case .plus:
            symbol.move(to: NSPoint(x: circleRect.midX, y: circleRect.minY + inset))
            symbol.line(to: NSPoint(x: circleRect.midX, y: circleRect.maxY - inset))
            symbol.move(to: NSPoint(x: circleRect.minX + inset, y: circleRect.midY))
            symbol.line(to: NSPoint(x: circleRect.maxX - inset, y: circleRect.midY))
        }
        symbol.stroke()
    }
}

private final class TitleBarNavigationButton: NSButton {
    init(symbolName: String, toolTip: String) {
        super.init(frame: .zero)
        image = NSImage(systemSymbolName: symbolName, accessibilityDescription: toolTip)
        imagePosition = .imageOnly
        symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 9, weight: .semibold)
        contentTintColor = FocnotesPalette.mutedInk
        isBordered = false
        self.toolTip = toolTip
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func resetCursorRects() {
        super.resetCursorRects()
        addCursorRect(bounds, cursor: .pointingHand)
    }
}

enum DailyNoteNavigation: Equatable {
    case previous
    case today
    case next
}

struct DailyNavigationState {
    let hasPrevious: Bool
    let hasNext: Bool
    let isToday: Bool
}

fileprivate struct RenderedWikiLink {
    let range: NSRange
    let visibleRange: NSRange
    let target: String
}

private enum ObsidianWikiLinkResolver {
    private static let ignoredDirectories: Set<String> = [".obsidian", ".git", ".trash", "node_modules"]
    private static let pathEncodingAllowed: CharacterSet = {
        var set = CharacterSet.urlPathAllowed
        set.remove(charactersIn: "&=?#+")
        return set
    }()

    static func open(target rawTarget: String, sourceFileURL: URL?) {
        DispatchQueue.global(qos: .userInitiated).async {
            let name = linkName(from: rawTarget)
            guard !name.isEmpty else { return }
            let sourceDirectory = sourceFileURL?.deletingLastPathComponent()
            let vaultRoot = sourceDirectory.flatMap(findVaultRoot)
            let url: URL?
            if let resolved = resolvePath(name: name, sourceDirectory: sourceDirectory, vaultRoot: vaultRoot),
               let encodedPath = resolved.path.addingPercentEncoding(withAllowedCharacters: pathEncodingAllowed) {
                url = URL(string: "obsidian://open?path=\(encodedPath)")
            } else if sourceFileURL == nil,
                      let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                url = URL(string: "obsidian://open?file=\(encodedName)")
            } else {
                url = nil
            }
            guard let url else { return }
            DispatchQueue.main.async {
                NSWorkspace.shared.open(url)
            }
        }
    }

    private static func linkName(from raw: String) -> String {
        var name = raw.trimmingCharacters(in: .whitespaces)
        if let pipe = name.firstIndex(of: "|") { name = String(name[..<pipe]) }
        if let hash = name.firstIndex(of: "#") { name = String(name[..<hash]) }
        return name.trimmingCharacters(in: .whitespaces)
    }

    private static func findVaultRoot(from directory: URL) -> URL? {
        var current = directory.standardizedFileURL
        while true {
            var isDirectory: ObjCBool = false
            let marker = current.appendingPathComponent(".obsidian").path
            if FileManager.default.fileExists(atPath: marker, isDirectory: &isDirectory), isDirectory.boolValue {
                return current
            }
            let parent = current.deletingLastPathComponent()
            if parent.path == current.path { return nil }
            current = parent
        }
    }

    private static func resolvePath(name: String, sourceDirectory: URL?, vaultRoot: URL?) -> URL? {
        let relativePath = name.lowercased().hasSuffix(".md") ? name : name + ".md"
        if let sourceDirectory {
            let candidate = sourceDirectory.appendingPathComponent(relativePath).standardizedFileURL
            if FileManager.default.fileExists(atPath: candidate.path) { return candidate }
        }
        guard let vaultRoot,
              let enumerator = FileManager.default.enumerator(
                at: vaultRoot,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
              ) else { return nil }

        let target = relativePath.lowercased()
        let targetLeaf = (target as NSString).lastPathComponent
        let includesDirectory = relativePath.contains("/")
        let rootPath = vaultRoot.standardizedFileURL.path
        var bestMatch: URL?
        var shortestPathLength = Int.max

        for case let url as URL in enumerator {
            if (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true {
                if ignoredDirectories.contains(url.lastPathComponent) { enumerator.skipDescendants() }
                continue
            }
            guard url.pathExtension.lowercased() == "md" else { continue }
            let path = url.standardizedFileURL.path
            let relative = path.hasPrefix(rootPath + "/")
                ? String(path.dropFirst(rootPath.count + 1)).lowercased()
                : path.lowercased()
            let matches = includesDirectory
                ? relative == target || relative.hasSuffix("/" + target)
                : (relative as NSString).lastPathComponent == targetLeaf
            if matches, relative.count < shortestPathLength {
                shortestPathLength = relative.count
                bestMatch = url.standardizedFileURL
            }
        }
        return bestMatch
    }
}

struct VaultTask {
    let sourceLine: String
    let description: String
    let isDone: Bool
    let fileURL: URL
    let relativePath: String
    let line: Int
    let due: Date?
    let scheduled: Date?
    let start: Date?
    let priority: Int

    var happens: Date? {
        [start, scheduled, due].compactMap { $0 }.min()
    }
}

private struct RenderedTaskHit {
    let rect: NSRect
    let task: VaultTask
}

private final class RenderedBlockPayload {
    let image: NSImage
    let taskHits: [RenderedTaskHit]
    let locksEditing: Bool

    init(image: NSImage, taskHits: [RenderedTaskHit] = [], locksEditing: Bool = false) {
        self.image = image
        self.taskHits = taskHits
        self.locksEditing = locksEditing
    }
}

struct TasksQuery {
    enum Grouping: Equatable { case filename, happens }
    enum Sorting { case priority, happens, due }

    var requireDone: Bool?
    var pathIncludes: [String] = []
    var dueRequired = true
    var scheduledRequired = true
    var dateFilters: [(VaultTask, Date) -> Bool] = []
    var textAlternatives: [(VaultTask) -> Bool] = []
    var sorting: [Sorting] = []
    var grouping: Grouping?
    var hideBacklink = false
}

enum TasksQueryEngine {
    // Cache state is owned by the main thread. Only file scanning/parsing runs on indexingQueue.
    static let indexDidChange = Notification.Name("FocnotesTaskIndexChanged")
    private static let indexingQueue = DispatchQueue(label: "com.local.focnotes.task-index", qos: .utility)
    private struct PendingIndex {
        let id = UUID()
        var editedFiles: [URL: String] = [:]
    }
    private static var pendingIndex: PendingIndex?
    private static var cachedRoot: String?
    private static var cachedAt = Date.distantPast
    private static var cachedTasks: [VaultTask] = []
    private static let taskExpression = try! NSRegularExpression(pattern: #"^[ \t]*[-*+] \[([ xX-])\] (.*)$"#)

    static var isIndexing: Bool { pendingIndex != nil }

    private enum ToggleError: LocalizedError {
        case taskChanged

        var errorDescription: String? { "La tarea cambió en el archivo. Actualiza la consulta antes de marcarla." }
    }

    static func results(query source: String, sourceFileURL: URL?) -> (TasksQuery, [VaultTask])? {
        guard let sourceFileURL, let vault = findVault(from: sourceFileURL.deletingLastPathComponent()) else { return nil }
        let query = parseQuery(source)
        var tasks = indexedTasks(in: vault)
        if let requireDone = query.requireDone {
            tasks = tasks.filter { $0.isDone == requireDone }
        }
        for path in query.pathIncludes {
            tasks = tasks.filter { $0.relativePath.localizedCaseInsensitiveContains(path) }
        }
        if !query.dueRequired { tasks = tasks.filter { $0.due == nil } }
        if !query.scheduledRequired { tasks = tasks.filter { $0.scheduled == nil } }
        let now = Calendar.current.startOfDay(for: Date())
        for filter in query.dateFilters { tasks = tasks.filter { filter($0, now) } }
        if !query.textAlternatives.isEmpty {
            tasks = tasks.filter { task in query.textAlternatives.contains(where: { $0(task) }) }
        }
        tasks.sort { lhs, rhs in
            for sorting in query.sorting {
                let comparison: ComparisonResult
                switch sorting {
                case .priority:
                    comparison = compare(lhs.priority, rhs.priority)
                case .happens:
                    comparison = compare(lhs.happens, rhs.happens)
                case .due:
                    comparison = compare(lhs.due, rhs.due)
                }
                if comparison != .orderedSame { return comparison == .orderedAscending }
            }
            if lhs.relativePath != rhs.relativePath { return lhs.relativePath < rhs.relativePath }
            return lhs.line < rhs.line
        }
        return (query, tasks)
    }

    static func toggle(_ task: VaultTask) throws -> String {
        let content = try String(contentsOf: task.fileURL, encoding: .utf8)
        var lines = content.components(separatedBy: "\n")
        guard lines.indices.contains(task.line - 1),
              lines[task.line - 1].trimmingCharacters(in: .newlines).utf8.elementsEqual(task.sourceLine.utf8),
              task.sourceLine.range(of: #"^[ \t]*[-*+] \[[ xX]\] "#, options: .regularExpression) != nil else {
            cachedAt = .distantPast
            throw ToggleError.taskChanged
        }
        let hasCarriageReturn = lines[task.line - 1].hasSuffix("\r")
        var line = task.sourceLine
        if task.isDone {
            line = line.replacingOccurrences(
                of: #"^(\s*[-*+] )\[[xX]\]"#,
                with: "$1[ ]",
                options: .regularExpression
            )
            line = line.replacingOccurrences(
                of: #"\s*✅\s*\d{4}-\d{2}-\d{2}"#,
                with: "",
                options: .regularExpression
            )
        } else {
            line = line.replacingOccurrences(
                of: #"^(\s*[-*+] )\[ \]"#,
                with: "$1[x]",
                options: .regularExpression
            )
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd"
            line += " ✅ " + formatter.string(from: Date())
        }
        lines[task.line - 1] = line + (hasCarriageReturn ? "\r" : "")
        let updated = lines.joined(separator: "\n")
        try updated.write(to: task.fileURL, atomically: true, encoding: .utf8)
        updateFile(at: task.fileURL, content: updated)
        return updated
    }

    /// Keep edits visible immediately, including edits made while a disk scan is in flight.
    static func updateFile(at fileURL: URL, content: String) {
        guard let cachedRoot else { return }
        let url = fileURL.standardizedFileURL
        guard url.path.hasPrefix(cachedRoot + "/") else { return }
        let vault = URL(fileURLWithPath: cachedRoot)
        replaceTasks(in: &cachedTasks, fileURL: url, content: content, vault: vault)
        pendingIndex?.editedFiles[url] = content
    }

    private static func replaceTasks(in tasks: inout [VaultTask], fileURL: URL, content: String, vault: URL) {
        tasks.removeAll { $0.fileURL.standardizedFileURL == fileURL }
        let formatter = taskDateFormatter()
        for (index, line) in content.components(separatedBy: "\n").enumerated() {
            if let task = parseTask(line, fileURL: fileURL, line: index + 1, vault: vault, formatter: formatter) {
                tasks.append(task)
            }
        }
    }

    private static func compare<T: Comparable>(_ lhs: T, _ rhs: T) -> ComparisonResult {
        lhs < rhs ? .orderedAscending : (lhs > rhs ? .orderedDescending : .orderedSame)
    }

    private static func compare(_ lhs: Date?, _ rhs: Date?) -> ComparisonResult {
        switch (lhs, rhs) {
        case let (lhs?, rhs?): return lhs.compare(rhs)
        case (_?, nil): return .orderedAscending
        case (nil, _?): return .orderedDescending
        case (nil, nil): return .orderedSame
        }
    }

    private static func parseQuery(_ source: String) -> TasksQuery {
        var query = TasksQuery()
        for rawLine in source.split(whereSeparator: \Character.isNewline) {
            var line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            if line.hasPrefix("("), line.hasSuffix(")") { line = String(line.dropFirst().dropLast()) }
            let lower = line.lowercased()
            if lower == "not done" { query.requireDone = false; continue }
            if lower == "done" { query.requireDone = true; continue }
            if lower == "hide backlink" { query.hideBacklink = true; continue }
            if lower == "no due date" { query.dueRequired = false; continue }
            if lower == "no scheduled date" { query.scheduledRequired = false; continue }
            if lower.hasPrefix("path includes ") {
                query.pathIncludes.append(String(line.dropFirst("path includes ".count)))
                continue
            }
            if lower == "sort by priority" { query.sorting.append(.priority); continue }
            if lower == "sort by happens" { query.sorting.append(.happens); continue }
            if lower == "sort by due" { query.sorting.append(.due); continue }
            if lower == "group by filename" { query.grouping = .filename; continue }
            if lower == "group by happens" { query.grouping = .happens; continue }
            if let filter = dateFilter(from: lower) { query.dateFilters.append(filter); continue }
            if lower.contains(" or ") {
                query.textAlternatives = lower
                    .replacingOccurrences(of: ") or (", with: "|")
                    .trimmingCharacters(in: CharacterSet(charactersIn: "()"))
                    .split(separator: "|")
                    .compactMap(textFilter)
            } else if let filter = textFilter(Substring(lower)) {
                query.textAlternatives.append(filter)
            }
        }
        return query
    }

    private static func textFilter(_ expression: Substring) -> ((VaultTask) -> Bool)? {
        let value = expression.trimmingCharacters(in: CharacterSet(charactersIn: "() "))
        if value.hasPrefix("description includes ") {
            let needle = String(value.dropFirst("description includes ".count))
            return { $0.description.localizedCaseInsensitiveContains(needle) }
        }
        if value.hasPrefix("tags include ") {
            let needle = String(value.dropFirst("tags include ".count))
            return { $0.description.localizedCaseInsensitiveContains(needle) }
        }
        return nil
    }

    private static func dateFilter(from line: String) -> ((VaultTask, Date) -> Bool)? {
        let fields: [(String, (VaultTask) -> Date?)] = [
            ("happens", { $0.happens }), ("due", { $0.due }),
            ("scheduled", { $0.scheduled }), ("start", { $0.start })
        ]
        guard let (name, dateValue) = fields.first(where: { line.hasPrefix($0.0 + " ") }) else { return nil }
        let condition = String(line.dropFirst(name.count + 1))
        let operators = ["before ", "after ", "on "]
        let operation = operators.first(where: condition.hasPrefix)
        let dateText = operation.map { String(condition.dropFirst($0.count)) } ?? condition
        return { task, today in
            guard let taskDate = dateValue(task), let target = relativeDate(dateText, today: today) else { return false }
            let calendar = Calendar.current
            if operation == "before " { return taskDate < target }
            if operation == "after " { return taskDate > target }
            return calendar.isDate(taskDate, inSameDayAs: target)
        }
    }

    private static func relativeDate(_ value: String, today: Date) -> Date? {
        switch value {
        case "today": return today
        case "yesterday": return Calendar.current.date(byAdding: .day, value: -1, to: today)
        case "tomorrow": return Calendar.current.date(byAdding: .day, value: 1, to: today)
        default:
            if let match = value.range(of: #"^in (\d+) days?$"#, options: .regularExpression),
               let days = Int(value[match].split(separator: " ")[1]) {
                return Calendar.current.date(byAdding: .day, value: days, to: today)
            }
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.date(from: value)
        }
    }

    private static func indexedTasks(in vault: URL) -> [VaultTask] {
        if cachedRoot != vault.path {
            cachedRoot = vault.path
            cachedAt = .distantPast
            cachedTasks = []
            pendingIndex = nil
        }
        if pendingIndex == nil, Date().timeIntervalSince(cachedAt) >= 3 {
            let pending = PendingIndex()
            pendingIndex = pending
            indexingQueue.async {
                let indexed = ripgrepTasks(in: vault) ?? nativeTasks(in: vault)
                DispatchQueue.main.async {
                    guard cachedRoot == vault.path, let current = pendingIndex, current.id == pending.id else { return }
                    var tasks = indexed
                    for (url, content) in current.editedFiles {
                        replaceTasks(in: &tasks, fileURL: url, content: content, vault: vault)
                    }
                    cachedTasks = tasks
                    cachedAt = Date()
                    pendingIndex = nil
                    NotificationCenter.default.post(name: indexDidChange, object: vault)
                }
            }
        }
        return cachedTasks
    }

    private static func ripgrepTasks(in vault: URL) -> [VaultTask]? {
        let executable = ["/opt/homebrew/bin/rg", "/usr/local/bin/rg"].first {
            FileManager.default.isExecutableFile(atPath: $0)
        }
        guard let executable else { return nil }
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = ["--json", "--glob", "*.md", #"^[ \t]*[-*+] \[[ xX-]\] "#, vault.path]
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        do { try process.run() } catch { return nil }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        guard process.terminationStatus == 0 || process.terminationStatus == 1 else { return nil }
        let output = String(data: data, encoding: .utf8) ?? ""
        let decoder = JSONDecoder()
        let formatter = taskDateFormatter()
        return output.split(whereSeparator: \Character.isNewline).compactMap { line in
            guard let event = try? decoder.decode(RipgrepEvent.self, from: Data(line.utf8)),
                  event.type == "match", let match = event.data,
                  let path = match.path.text, let text = match.lines.text else { return nil }
            return parseTask(text, fileURL: URL(fileURLWithPath: path), line: match.line_number, vault: vault, formatter: formatter)
        }
    }

    private struct RipgrepEvent: Decodable {
        struct Text: Decodable { let text: String? }
        struct Match: Decodable {
            let path: Text
            let lines: Text
            let line_number: Int
        }
        let type: String
        let data: Match?

        private enum CodingKeys: String, CodingKey { case type, data }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(String.self, forKey: .type)
            data = type == "match" ? try container.decode(Match.self, forKey: .data) : nil
        }
    }

    private static func nativeTasks(in vault: URL) -> [VaultTask] {
        guard let enumerator = FileManager.default.enumerator(
            at: vault,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }
        var tasks: [VaultTask] = []
        let formatter = taskDateFormatter()
        for case let url as URL in enumerator where url.pathExtension.lowercased() == "md" {
            guard let content = try? String(contentsOf: url, encoding: .utf8) else { continue }
            for (index, line) in content.components(separatedBy: "\n").enumerated() {
                if let task = parseTask(line, fileURL: url, line: index + 1, vault: vault, formatter: formatter) { tasks.append(task) }
            }
        }
        return tasks
    }

    private static func parseTask(_ rawLine: String, fileURL: URL, line lineNumber: Int, vault: URL, formatter: DateFormatter) -> VaultTask? {
        let line = rawLine.trimmingCharacters(in: .newlines)
        guard let match = taskExpression.firstMatch(in: line, range: NSRange(location: 0, length: (line as NSString).length)) else {
            return nil
        }
        let source = line as NSString
        let status = source.substring(with: match.range(at: 1))
        let description = source.substring(with: match.range(at: 2))
        let relative = fileURL.path.hasPrefix(vault.path + "/")
            ? String(fileURL.path.dropFirst(vault.path.count + 1))
            : fileURL.lastPathComponent
        return VaultTask(
            sourceLine: line,
            description: description,
            isDone: status.lowercased() == "x",
            fileURL: fileURL,
            relativePath: relative,
            line: lineNumber,
            due: metadataDate("📅", in: description, formatter: formatter),
            scheduled: metadataDate("⏳", in: description, formatter: formatter),
            start: metadataDate("🛫", in: description, formatter: formatter),
            priority: priority(in: description)
        )
    }

    private static func metadataDate(_ marker: String, in text: String, formatter: DateFormatter) -> Date? {
        guard let range = text.range(of: marker + #"\s*\{?(\d{4}-\d{2}-\d{2})\}?"#, options: .regularExpression),
              let dateRange = text[range].range(of: #"\d{4}-\d{2}-\d{2}"#, options: .regularExpression) else { return nil }
        return formatter.date(from: String(text[range][dateRange]))
    }

    private static func taskDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    private static func priority(in text: String) -> Int {
        if text.contains("🔺") { return 0 }
        if text.contains("⏫") { return 1 }
        if text.contains("🔼") { return 2 }
        if text.contains("🔽") { return 4 }
        if text.contains("⏬") { return 5 }
        return 3
    }

    private static func findVault(from directory: URL) -> URL? {
        var current = directory.standardizedFileURL
        while true {
            if FileManager.default.fileExists(atPath: current.appendingPathComponent(".obsidian").path) { return current }
            let parent = current.deletingLastPathComponent()
            if parent.path == current.path { return nil }
            current = parent
        }
    }
}

final class MarkdownTextView: NSTextView, NSViewToolTipOwner {
    private typealias FencedCodeBlock = MarkdownAnalysis.FencedCodeBlock
    private let analysisCache = MarkdownAnalysisCache()
    var markdownAnalysis: MarkdownAnalysis { analysisCache.analysis(for: string) }

    var activeEditorSelections: [NSRange] {
        let isWindowActive = (window as? FloatingNotePanel)?.isVisuallyActive ?? window?.isKeyWindow == true
        guard isWindowActive, window?.firstResponder === self else { return [] }
        return selectedRanges.map(\.rangeValue)
    }

    var checkboxClicked: ((NSRange) -> Void)?
    var wikiLinkClicked: ((String) -> Void)?
    var editingFocusChanged: (() -> Void)?
    fileprivate var renderedTaskClicked: ((VaultTask) -> Void)?
    fileprivate var renderedWikiLinks: [RenderedWikiLink] = []
    var isUpdatingPresentation = false
    private var linkToolTips: [NSView.ToolTipTag: String] = [:]
    private var hoverTrackingArea: NSTrackingArea?
    private var cachedRenderedBlocks: [(RenderedBlockPayload, NSRect)] = []
    private var cachedCheckboxHits: [(NSRange, NSRect)] = []

    override func becomeFirstResponder() -> Bool {
        let becameFirstResponder = super.becomeFirstResponder()
        if becameFirstResponder {
            DispatchQueue.main.async { [weak self] in
                self?.editingFocusChanged?()
            }
        }
        return becameFirstResponder
    }

    override func resignFirstResponder() -> Bool {
        let resignedFirstResponder = super.resignFirstResponder()
        if resignedFirstResponder {
            DispatchQueue.main.async { [weak self] in
                self?.editingFocusChanged?()
            }
        }
        return resignedFirstResponder
    }

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
        activeEditorSelections.contains { selection in
            if selection.length > 0 {
                return NSIntersectionRange(selection, range).length > 0
            }
            return selection.location >= range.location && selection.location < NSMaxRange(range)
        }
    }

    private func selectionTouchesLink(_ range: NSRange) -> Bool {
        activeEditorSelections.contains { selection in
            if selection.length > 0 {
                return NSIntersectionRange(selection, range).length > 0
            }
            return selection.location >= range.location && selection.location <= NSMaxRange(range)
        }
    }

    private func isProtectedMarkdownRange(_ range: NSRange) -> Bool {
        guard let textStorage, range.location < textStorage.length else { return false }
        return textStorage.attribute(.focnotesInlineCode, at: range.location, effectiveRange: nil) != nil
            || textStorage.attribute(.focnotesCodeBlock, at: range.location, effectiveRange: nil) != nil
            || textStorage.attribute(.focnotesThematicBreak, at: range.location, effectiveRange: nil) != nil
    }

    private func fencedCodeBlocks(in source: NSString) -> [FencedCodeBlock] {
        analysisCache.analysis(for: source as String).fencedCodeBlocks
    }

    var hasClosedTasksQuery: Bool {
        fencedCodeBlocks(in: string as NSString).contains { $0.isTasksQuery && $0.isClosed }
    }

    var activeClosedTasksQueryRange: NSRange? {
        let selections = selectedRanges.map(\.rangeValue)
        return fencedCodeBlocks(in: string as NSString).first { block in
            guard block.isTasksQuery, block.isClosed else { return false }
            return selections.contains { selection in
                if selection.length > 0 {
                    return NSIntersectionRange(selection, block.range).length > 0
                }
                return selection.location >= block.range.location && selection.location <= NSMaxRange(block.range)
            }
        }?.range
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
            height: max(21, glyphRect.height + 3)
        )
    }

    private func copyButtonRect(for blockRect: NSRect) -> NSRect {
        NSRect(x: blockRect.maxX - 25, y: blockRect.minY + 3, width: 20, height: 18)
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command else {
            return super.performKeyEquivalent(with: event)
        }
        if event.keyCode == 36,
           let link = renderedWikiLinks.first(where: { link in
               selectedRanges.map(\.rangeValue).contains { selection in
                   selection.location >= link.range.location && selection.location <= NSMaxRange(link.range)
               }
           }) {
            wikiLinkClicked?(link.target)
            return true
        }
        guard
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
            guard !block.isTasksQuery else { continue }
            let blockRect = codeBlockRect(for: block, layoutManager: layoutManager, textContainer: textContainer)
            if copyButtonRect(for: blockRect).contains(point) {
                NSCursor.pointingHand.set()
                return true
            }
        }
        return false
    }

    private func updateCheckboxCursor(for event: NSEvent) -> Bool {
        let point = convert(event.locationInWindow, from: nil)
        guard cachedCheckboxHits.contains(where: { $0.1.contains(point) }) else { return false }
        NSCursor.pointingHand.set()
        return true
    }

    override func resetCursorRects() {
        super.resetCursorRects()
        removeAllToolTips()
        linkToolTips.removeAll()
        guard !isUpdatingPresentation else { return }
        for (_, rect) in cachedCheckboxHits {
            addCursorRect(rect, cursor: .pointingHand)
        }
        guard let layoutManager, let textContainer else { return }
        let source = string as NSString
        let fullRange = NSRange(location: 0, length: source.length)
        guard let expression = try? NSRegularExpression(
            pattern: "(?<!\\!)\\[([^\\]\\n]+)\\]\\(([^\\n)]*)\\)"
        ) else { return }

        expression.enumerateMatches(in: string, range: fullRange) { [weak self] result, _, _ in
            guard let self, let result,
                  !selectionTouchesLink(result.range),
                  !isProtectedMarkdownRange(result.range) else { return }
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

        for link in renderedWikiLinks where !selectionTouchesLink(link.range) {
            let glyphRange = layoutManager.glyphRange(forCharacterRange: link.visibleRange, actualCharacterRange: nil)
            var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
            rect.origin.x += textContainerOrigin.x
            rect.origin.y += textContainerOrigin.y
            addCursorRect(rect, cursor: .pointingHand)
            let tag = addToolTip(rect, owner: self, userData: nil)
            linkToolTips[tag] = "Abrir en Obsidian: \(link.target)"
        }

        for block in fencedCodeBlocks(in: source) {
            guard !block.isTasksQuery else { continue }
            let blockRect = codeBlockRect(for: block, layoutManager: layoutManager, textContainer: textContainer)
            let buttonRect = copyButtonRect(for: blockRect)
            addCursorRect(buttonRect, cursor: .pointingHand)
            let tag = addToolTip(buttonRect, owner: self, userData: nil)
            linkToolTips[tag] = "Copiar código"
        }

        for (payload, rect) in cachedRenderedBlocks {
            for hit in payload.taskHits {
                addCursorRect(taskHitRect(hit.rect, in: rect), cursor: .pointingHand)
            }
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
        drawTableRows(in: dirtyRect)
        super.draw(dirtyRect)
        drawRenderedBlocks(in: dirtyRect)
        drawThematicBreaks(in: dirtyRect)
        drawBlockQuoteGuides(in: dirtyRect)
        guard let layoutManager, let textContainer else { return }
        let source = string as NSString
        cachedCheckboxHits.removeAll(keepingCapacity: true)

        markdownAnalysis.tasks.forEach { result in
            let markerSyntaxRange = result.range(at: 1)
            guard !isProtectedMarkdownRange(markerSyntaxRange) else { return }
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
            cachedCheckboxHits.append((markerRange, rect))
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

        markdownAnalysis.bullets.forEach { result in
            let markerRange = result.range(at: 1)
            guard !isProtectedMarkdownRange(markerRange) else { return }
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
            guard !block.isTasksQuery else { continue }
            let rect = codeBlockRect(for: block, layoutManager: layoutManager, textContainer: textContainer)
            guard dirtyRect.intersects(rect) else { continue }
            FocnotesPalette.softHighlight.setFill()
            NSBezierPath(roundedRect: rect, xRadius: 6, yRadius: 6).fill()
        }
    }

    private func drawInlineCodeBackgrounds(in dirtyRect: NSRect) {
        guard let layoutManager, let textContainer, let textStorage, textStorage.length > 0 else { return }
        var characterIndex = 0
        while characterIndex < textStorage.length {
            var effectiveRange = NSRange(location: 0, length: 0)
            let isInlineCode = textStorage.attribute(
                .focnotesInlineCode,
                at: characterIndex,
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
                rect = NSRect(
                    x: rect.minX - 3,
                    y: rect.minY - 1.5,
                    width: rect.width + 6,
                    height: rect.height - 1
                )
                guard dirtyRect.intersects(rect) else { return }
                FocnotesPalette.softHighlight.setFill()
                NSBezierPath(roundedRect: rect, xRadius: 4, yRadius: 4).fill()
            }
        }
    }

    private func drawTableRows(in dirtyRect: NSRect) {
        guard let layoutManager, let textContainer, let textStorage, textStorage.length > 0 else { return }
        var index = 0
        while index < textStorage.length {
            var range = NSRange(location: 0, length: 0)
            let row = textStorage.attribute(.focnotesTableRow, at: index, effectiveRange: &range)
            guard range.length > 0 else { break }
            defer { index = NSMaxRange(range) }
            guard let rowNumber = row as? NSNumber else { continue }
            let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
            rect.origin.x = textContainerOrigin.x - 5
            rect.origin.y += textContainerOrigin.y - 1
            rect.size.width = max(0, textContainer.size.width + 10)
            rect.size.height += 2
            guard dirtyRect.intersects(rect) else { continue }
            let alpha: CGFloat = rowNumber.intValue == 0 ? 0.09 : (rowNumber.intValue.isMultiple(of: 2) ? 0.035 : 0.055)
            FocnotesPalette.accentBlue.withAlphaComponent(alpha).setFill()
            NSBezierPath(roundedRect: rect, xRadius: 4, yRadius: 4).fill()
        }
    }

    private func drawRenderedBlocks(in dirtyRect: NSRect) {
        cachedRenderedBlocks.removeAll(keepingCapacity: true)
        guard let layoutManager, let textStorage, textStorage.length > 0 else { return }
        var renderedBlocks: [(RenderedBlockPayload, NSRect)] = []
        var index = 0
        while index < textStorage.length {
            var range = NSRange(location: 0, length: 0)
            let value = textStorage.attribute(.focnotesRenderedBlock, at: index, effectiveRange: &range)
            guard range.length > 0 else { break }
            defer { index = NSMaxRange(range) }
            guard let payload = value as? RenderedBlockPayload else { continue }
            let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            guard glyphRange.location < layoutManager.numberOfGlyphs else { continue }
            var rect = layoutManager.lineFragmentRect(forGlyphAt: glyphRange.location, effectiveRange: nil)
            rect.origin.x = textContainerOrigin.x
            rect.origin.y += textContainerOrigin.y
            rect.size = payload.image.size
            renderedBlocks.append((payload, rect))
            guard dirtyRect.intersects(rect) else { continue }
            payload.image.draw(
                in: rect,
                from: .zero,
                operation: .sourceOver,
                fraction: 1,
                respectFlipped: true,
                hints: nil
            )
        }
        cachedRenderedBlocks = renderedBlocks
    }

    private func drawThematicBreaks(in dirtyRect: NSRect) {
        guard let layoutManager, let textContainer, let textStorage, textStorage.length > 0 else { return }
        var index = 0
        while index < textStorage.length {
            var range = NSRange(location: 0, length: 0)
            let marker = textStorage.attribute(.focnotesThematicBreak, at: index, effectiveRange: &range)
            guard range.length > 0 else { break }
            defer { index = NSMaxRange(range) }
            guard marker != nil else { continue }
            let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
            rect.origin.y += textContainerOrigin.y
            let y = rect.midY
            let line = NSBezierPath()
            line.move(to: NSPoint(x: textContainerOrigin.x, y: y))
            line.line(to: NSPoint(x: textContainerOrigin.x + textContainer.size.width, y: y))
            guard dirtyRect.intersects(NSRect(x: textContainerOrigin.x, y: y - 1, width: textContainer.size.width, height: 2)) else { continue }
            FocnotesPalette.faintInk.setStroke()
            line.lineWidth = 1
            line.stroke()
        }
    }

    private func drawBlockQuoteGuides(in dirtyRect: NSRect) {
        guard let layoutManager, let textContainer, let textStorage, textStorage.length > 0 else { return }
        var index = 0
        while index < textStorage.length {
            var range = NSRange(location: 0, length: 0)
            let marker = textStorage.attribute(.focnotesBlockQuote, at: index, effectiveRange: &range)
            guard range.length > 0 else { break }
            defer { index = NSMaxRange(range) }
            guard marker != nil else { continue }
            let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
            rect.origin.y += textContainerOrigin.y
            let x = textContainerOrigin.x - 4
            guard dirtyRect.intersects(NSRect(x: x - 1, y: rect.minY, width: 3, height: rect.height)) else { continue }
            let guide = NSBezierPath()
            guide.move(to: NSPoint(x: x, y: rect.minY))
            guide.line(to: NSPoint(x: x, y: rect.maxY))
            FocnotesPalette.accent.withAlphaComponent(0.55).setStroke()
            guide.lineWidth = 2
            guide.lineCapStyle = .round
            guide.stroke()
        }
    }

    private func drawCodeBlockCopyButtons(in dirtyRect: NSRect) {
        guard let layoutManager, let textContainer else { return }
        let source = string as NSString
        for block in fencedCodeBlocks(in: source) {
            guard !block.isTasksQuery else { continue }
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
        let source = string as NSString
        guard source.length > 0 else {
            super.mouseDown(with: event)
            return
        }
        if handleRenderedBlockClick(at: point) {
            return
        }
        if let checkbox = cachedCheckboxHits.first(where: { $0.1.contains(point) }) {
            NSCursor.pointingHand.set()
            checkboxClicked?(checkbox.0)
            return
        }
        let index = characterIndexForInsertion(at: point)
        if copyCodeBlock(at: point, source: source) {
            return
        }
        if openRenderedWikiLink(at: index) {
            return
        }
        if event.modifierFlags.contains(.command), openRenderedLink(at: index, in: source) {
            return
        }
        super.mouseDown(with: event)
    }

    private func copyCodeBlock(at point: NSPoint, source: NSString) -> Bool {
        guard let layoutManager, let textContainer else { return false }
        guard let block = fencedCodeBlocks(in: source).first(where: { block in
            guard !block.isTasksQuery else { return false }
            let blockRect = codeBlockRect(for: block, layoutManager: layoutManager, textContainer: textContainer)
            return copyButtonRect(for: blockRect).contains(point)
        }) else { return false }

        let code = markdownAnalysis.codeToCopy(from: block)
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
            !isProtectedMarkdownRange($0.range)
                && (NSLocationInRange(index, $0.range(at: 1)) || NSLocationInRange(index, $0.range(at: 2)))
        }) else { return false }

        let destination = source.substring(with: match.range(at: 2))
        guard let url = URL(string: destination),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https" else { return false }
        return NSWorkspace.shared.open(url)
    }

    private func openRenderedWikiLink(at index: Int) -> Bool {
        guard let link = renderedWikiLinks.first(where: {
            NSLocationInRange(index, $0.range) && !selectionTouchesLink($0.range)
        }) else { return false }
        wikiLinkClicked?(link.target)
        return true
    }

    private func handleRenderedBlockClick(at point: NSPoint) -> Bool {
        for (payload, rect) in cachedRenderedBlocks {
            if let hit = payload.taskHits.first(where: { taskHitRect($0.rect, in: rect).contains(point) }) {
                let task = hit.task
                DispatchQueue.main.async { [weak self] in
                    self?.renderedTaskClicked?(task)
                }
                return true
            }
            if payload.locksEditing, rect.contains(point) { return true }
        }
        return false
    }

    private func taskHitRect(_ hitRect: NSRect, in blockRect: NSRect) -> NSRect {
        NSRect(
            x: blockRect.minX + hitRect.minX,
            y: blockRect.minY + hitRect.minY,
            width: hitRect.width,
            height: hitRect.height
        )
    }
}

final class MarkdownPresentationRenderer {
    private let analysis: MarkdownAnalysis
    private let source: String
    private let sourceNSString: NSString
    private let textStorage: NSTextStorage
    private let selections: [NSRange]
    private let baseFont: NSFont
    private let renderWidth: CGFloat
    private let sourceFileURL: URL?
    private var protectedRanges: [NSRange] = []

    init(
        analysis: MarkdownAnalysis,
        textStorage: NSTextStorage,
        selections: [NSRange],
        fontSize: CGFloat,
        renderWidth: CGFloat,
        sourceFileURL: URL?
    ) {
        self.analysis = analysis
        self.source = analysis.source
        self.sourceNSString = analysis.source as NSString
        self.textStorage = textStorage
        self.selections = selections
        self.baseFont = NSFont.systemFont(ofSize: fontSize, weight: .regular)
        self.renderWidth = renderWidth
        self.sourceFileURL = sourceFileURL
    }

    func render(_ markup: Markup) {
        if let range = characterRange(for: markup) {
            switch markup {
            case let heading as Heading:
                styleHeading(heading, range: range)
            case _ as Strong:
                styleInline(range, openingLength: 2, closingLength: 2, attributes: [
                    .font: NSFont.systemFont(ofSize: baseFont.pointSize, weight: .bold)
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
                protectedRanges.append(range)
                styleCodeSpan(range)
            case _ as Link:
                protectedRanges.append(range)
                styleLink(range)
            case _ as Image:
                protectedRanges.append(range)
                styleImage(range)
            case let codeBlock as CodeBlock:
                protectedRanges.append(range)
                styleCodeBlock(codeBlock, range: range)
                return
            case _ as InlineHTML, _ as HTMLBlock:
                protectedRanges.append(range)
                applyPresentation([
                    .font: NSFont.monospacedSystemFont(ofSize: max(11, baseFont.pointSize - 2), weight: .regular),
                    .foregroundColor: FocnotesPalette.code
                ], forCharacterRange: range)
            case _ as BlockQuote:
                styleBlockQuote(range)
            case _ as UnorderedList:
                styleLines(in: range, markerPattern: "^[ \\t]*[-*+]\\s+", color: FocnotesPalette.accent)
            case _ as OrderedList:
                styleLines(in: range, markerPattern: "^[ \\t]*\\d+[.)]\\s+", color: FocnotesPalette.accent)
            case _ as Table:
                styleTable(range)
            case _ as ThematicBreak:
                styleThematicBreak(range)
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
            guard !protectedRanges.contains(where: { NSIntersectionRange($0, result.range).length > 0 }) else { return }
            styleLink(result.range)
        }
    }

    fileprivate func renderWikiLinks() -> [RenderedWikiLink] {
        guard let expression = try? NSRegularExpression(pattern: "\\[\\[([^\\]\\r\\n]+)\\]\\]") else { return [] }
        let fullRange = NSRange(location: 0, length: sourceNSString.length)
        var links: [RenderedWikiLink] = []
        for match in expression.matches(in: source, range: fullRange) {
            guard !protectedRanges.contains(where: { NSIntersectionRange($0, match.range).length > 0 }) else { continue }
            let innerRange = match.range(at: 1)
            let rawTarget = sourceNSString.substring(with: innerRange).trimmingCharacters(in: .whitespaces)
            guard !rawTarget.isEmpty else { continue }
            let inner = sourceNSString.substring(with: innerRange) as NSString
            let pipe = inner.range(of: "|")
            let visibleRange: NSRange
            if pipe.location != NSNotFound, NSMaxRange(pipe) < inner.length {
                visibleRange = NSRange(
                    location: innerRange.location + NSMaxRange(pipe),
                    length: inner.length - NSMaxRange(pipe)
                )
            } else {
                visibleRange = innerRange
            }
            applyPresentation([
                .foregroundColor: FocnotesPalette.accentBlue,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ], forCharacterRange: selectionTouchesLink(match.range) ? innerRange : visibleRange)
            if !selectionTouchesLink(match.range) {
                hide(NSRange(location: match.range.location, length: 2))
                if pipe.location != NSNotFound {
                    hide(NSRange(location: innerRange.location, length: NSMaxRange(pipe)))
                }
                hide(NSRange(location: NSMaxRange(match.range) - 2, length: 2))
            }
            links.append(RenderedWikiLink(range: match.range, visibleRange: visibleRange, target: rawTarget))
        }
        return links
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
            .font: NSFont.systemFont(ofSize: headingSizes[min(max(heading.level, 1), 6) - 1], weight: .bold),
            .foregroundColor: FocnotesPalette.ink
        ], forCharacterRange: contentRange)
        if marker.location != NSNotFound {
            let markerRange = NSRange(location: range.location, length: marker.length)
            if isActiveLine {
                applyPresentation([
                    .font: NSFont.systemFont(ofSize: headingSizes[min(max(heading.level, 1), 6) - 1], weight: .bold),
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
            .font: NSFont.monospacedSystemFont(ofSize: baseFont.pointSize, weight: .regular),
            .foregroundColor: FocnotesPalette.code,
            .focnotesInlineCode: true
        ])
    }

    private func styleCodeBlock(_ codeBlock: CodeBlock, range: NSRange) {
        let codeAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: baseFont.pointSize, weight: .regular),
            .foregroundColor: FocnotesPalette.code,
            .focnotesCodeBlock: true
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

        if closing != nil,
           ["task", "tasks"].contains(codeBlock.language?.lowercased() ?? ""),
           !selectionTouchesIncludingEnd(range),
           renderTasksAttachment(query: codeBlock.code, range: range) {
            return
        }

        let openingRange = NSRange(location: range.location, length: opening.range.length)
        let closingRange = closing.map {
            NSRange(location: range.location + $0.range.location, length: $0.range.length)
        }
        if selectionTouchesIncludingEnd(range) {
            applyPresentation([.foregroundColor: FocnotesPalette.faintInk], forCharacterRange: openingRange)
            if let closingRange {
                applyPresentation([.foregroundColor: FocnotesPalette.faintInk], forCharacterRange: closingRange)
            }
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
        if let closingRange { hide(closingRange) }
    }

    private func renderTasksAttachment(query source: String, range: NSRange) -> Bool {
        guard let (query, allTasks) = TasksQueryEngine.results(query: source, sourceFileURL: sourceFileURL) else {
            return false
        }
        let limit = 80
        let tasks = Array(allTasks.prefix(limit))
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "es_CL")
        dateFormatter.dateFormat = "d MMM yyyy"

        let grouped: [(String?, [VaultTask])]
        switch query.grouping {
        case .filename:
            grouped = Dictionary(grouping: tasks) { $0.fileURL.deletingPathExtension().lastPathComponent }
                .sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
                .map { ($0.key, $0.value) }
        case .happens:
            grouped = Dictionary(grouping: tasks) { task in
                task.happens.map(dateFormatter.string) ?? "Sin fecha"
            }
            .sorted { $0.key < $1.key }
            .map { ($0.key, $0.value) }
        case nil:
            grouped = [(nil, tasks)]
        }

        let width = max(180, renderWidth)
        let taskHeight: CGFloat = 27
        let groupHeight: CGFloat = 25
        let emptyHeight: CGFloat = 42
        let groupCount = grouped.filter { $0.0 != nil }.count
        let overflowHeight: CGFloat = allTasks.count > limit ? 26 : 0
        let height = tasks.isEmpty
            ? emptyHeight
            : CGFloat(tasks.count) * taskHeight + CGFloat(groupCount) * groupHeight + overflowHeight + 8
        let image = NSImage(size: NSSize(width: width, height: height))
        var taskHits: [RenderedTaskHit] = []
        image.lockFocus()
        defer { image.unlockFocus() }

        FocnotesPalette.ink.withAlphaComponent(0.035).setFill()
        NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: width, height: height), xRadius: 7, yRadius: 7).fill()

        if tasks.isEmpty {
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            let message = TasksQueryEngine.isIndexing ? "Buscando tareas…" : "No hay tareas para esta consulta"
            (message as NSString).draw(
                in: NSRect(x: 8, y: (height - 16) / 2, width: width - 16, height: 18),
                withAttributes: [
                    .font: NSFont.systemFont(ofSize: 12, weight: .regular),
                    .foregroundColor: FocnotesPalette.mutedInk,
                    .paragraphStyle: paragraph
                ]
            )
        } else {
            var top = height - 5
            var visualTop: CGFloat = 5
            for (groupName, groupTasks) in grouped {
                if let groupName {
                    top -= groupHeight
                    visualTop += groupHeight
                    (groupName as NSString).draw(
                        in: NSRect(x: 11, y: top + 5, width: width - 22, height: 17),
                        withAttributes: [
                            .font: NSFont.systemFont(ofSize: 11, weight: .semibold),
                            .foregroundColor: FocnotesPalette.accentBlue
                        ]
                    )
                }
                for task in groupTasks {
                    top -= taskHeight
                    taskHits.append(RenderedTaskHit(
                        rect: NSRect(x: 7, y: visualTop + 2, width: 22, height: taskHeight - 3),
                        task: task
                    ))
                    visualTop += taskHeight
                    let rowRect = NSRect(x: 6, y: top, width: width - 12, height: taskHeight - 2)
                    if Int(top / taskHeight).isMultiple(of: 2) {
                        FocnotesPalette.ink.withAlphaComponent(0.025).setFill()
                        NSBezierPath(roundedRect: rowRect, xRadius: 4, yRadius: 4).fill()
                    }

                    let checkboxRect = NSRect(x: 12, y: top + 7, width: 12, height: 12)
                    let checkbox = NSBezierPath(roundedRect: checkboxRect, xRadius: 3, yRadius: 3)
                    FocnotesPalette.accent.setStroke()
                    checkbox.lineWidth = 1.4
                    checkbox.stroke()

                    var description = task.description
                    if !query.hideBacklink, query.grouping != .filename {
                        description += "  ·  " + task.fileURL.deletingPathExtension().lastPathComponent
                    }
                    let paragraph = NSMutableParagraphStyle()
                    paragraph.lineBreakMode = .byTruncatingTail
                    (description as NSString).draw(
                        in: NSRect(x: 31, y: top + 5, width: width - 42, height: 18),
                        withAttributes: [
                            .font: NSFont.systemFont(ofSize: max(11, baseFont.pointSize - 2), weight: .regular),
                            .foregroundColor: FocnotesPalette.ink,
                            .paragraphStyle: paragraph
                        ]
                    )
                }
            }
            if allTasks.count > limit {
                top -= overflowHeight
                ("+ \(allTasks.count - limit) tareas más" as NSString).draw(
                    in: NSRect(x: 12, y: top + 5, width: width - 24, height: 17),
                    withAttributes: [
                        .font: NSFont.systemFont(ofSize: 11),
                        .foregroundColor: FocnotesPalette.mutedInk
                    ]
                )
            }
        }

        installRenderedBlock(image, taskHits: taskHits, in: range)
        return true
    }

    private func styleTable(_ range: NSRange) {
        if !selectionTouchesIncludingEnd(range), renderTableAttachment(range) {
            return
        }
        applyPresentation([
            .font: NSFont.systemFont(ofSize: max(11, baseFont.pointSize - 1), weight: .regular),
            .foregroundColor: FocnotesPalette.ink.withAlphaComponent(0.84)
        ], forCharacterRange: range)

        let tableSource = sourceNSString.substring(with: range) as NSString
        var rowNumber = 0
        var lineLocation = 0
        while lineLocation < tableSource.length {
            let lineRange = tableSource.lineRange(for: NSRange(location: lineLocation, length: 0))
            let line = tableSource.substring(with: lineRange)
            let contentLength = line.utf16.count - (line.hasSuffix("\n") ? 1 : 0)
            let absoluteRange = NSRange(location: range.location + lineRange.location, length: max(0, contentLength))
            let isDelimiter = line.range(
                of: "^\\s*\\|?\\s*:?-{3,}:?\\s*(?:\\|\\s*:?-{3,}:?\\s*)+\\|?\\s*$",
                options: .regularExpression
            ) != nil
            if isDelimiter {
                if !selectionTouchesIncludingEnd(range) { hide(absoluteRange) }
            } else if absoluteRange.length > 0 {
                applyPresentation([.focnotesTableRow: NSNumber(value: rowNumber)], forCharacterRange: absoluteRange)
                if rowNumber == 0 {
                    applyPresentation([
                        .font: NSFont.systemFont(ofSize: max(11, baseFont.pointSize - 1), weight: .semibold),
                        .foregroundColor: FocnotesPalette.ink
                    ], forCharacterRange: absoluteRange)
                }
                rowNumber += 1
            }
            lineLocation = NSMaxRange(lineRange)
        }

        if let pipeExpression = try? NSRegularExpression(pattern: "\\|") {
            pipeExpression.enumerateMatches(in: source, range: range) { [weak self] match, _, _ in
                guard let self, let match else { return }
                applyPresentation([.foregroundColor: FocnotesPalette.faintInk], forCharacterRange: match.range)
            }
        }
    }

    private func renderTableAttachment(_ range: NSRange) -> Bool {
        let lines = sourceNSString.substring(with: range)
            .split(whereSeparator: \Character.isNewline)
            .map(String.init)
        guard lines.count >= 2 else { return false }
        let parsed = lines.map(tableCells)
        guard let delimiterIndex = parsed.indices.dropFirst().first(where: { index in
            parsed[index].allSatisfy { cell in
                cell.trimmingCharacters(in: .whitespaces).range(
                    of: "^:?-{3,}:?$",
                    options: .regularExpression
                ) != nil
            }
        }), delimiterIndex == 1 else { return false }

        let alignments: [NSTextAlignment] = parsed[delimiterIndex].map { cell in
            let value = cell.trimmingCharacters(in: .whitespaces)
            if value.hasPrefix(":"), value.hasSuffix(":") { return .center }
            if value.hasSuffix(":") { return .right }
            return .left
        }
        let rows = [parsed[0]] + parsed.dropFirst(delimiterIndex + 1)
        let columnCount = rows.map(\.count).max() ?? 0
        guard columnCount > 0, !rows.isEmpty else { return false }

        let width = max(180, renderWidth)
        let rowHeight = max(28, baseFont.pointSize + 14)
        let height = CGFloat(rows.count) * rowHeight
        let columnWidth = width / CGFloat(columnCount)
        let image = NSImage(size: NSSize(width: width, height: height))
        image.lockFocus()
        defer { image.unlockFocus() }

        for (rowIndex, row) in rows.enumerated() {
            let y = height - CGFloat(rowIndex + 1) * rowHeight
            let rowRect = NSRect(x: 0, y: y, width: width, height: rowHeight)
            let fill = rowIndex == 0
                ? FocnotesPalette.accentBlue.withAlphaComponent(0.13)
                : FocnotesPalette.ink.withAlphaComponent(rowIndex.isMultiple(of: 2) ? 0.035 : 0.055)
            fill.setFill()
            rowRect.fill()

            for column in 0..<columnCount {
                let cellRect = NSRect(x: CGFloat(column) * columnWidth, y: y, width: columnWidth, height: rowHeight)
                let paragraph = NSMutableParagraphStyle()
                paragraph.alignment = column < alignments.count ? alignments[column] : .left
                paragraph.lineBreakMode = .byTruncatingTail
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: NSFont.systemFont(
                        ofSize: max(11, baseFont.pointSize - 1),
                        weight: rowIndex == 0 ? .semibold : .regular
                    ),
                    .foregroundColor: FocnotesPalette.ink,
                    .paragraphStyle: paragraph
                ]
                let value = column < row.count ? cleanTableCell(row[column]) : ""
                (value as NSString).draw(
                    in: cellRect.insetBy(dx: 9, dy: (rowHeight - baseFont.pointSize - 3) / 2),
                    withAttributes: attributes
                )

                if column > 0 {
                    let divider = NSBezierPath()
                    divider.move(to: NSPoint(x: cellRect.minX, y: cellRect.minY + 4))
                    divider.line(to: NSPoint(x: cellRect.minX, y: cellRect.maxY - 4))
                    FocnotesPalette.ink.withAlphaComponent(0.12).setStroke()
                    divider.lineWidth = 1
                    divider.stroke()
                }
            }
            if rowIndex > 0 {
                let divider = NSBezierPath()
                divider.move(to: NSPoint(x: 0, y: rowRect.maxY))
                divider.line(to: NSPoint(x: width, y: rowRect.maxY))
                FocnotesPalette.ink.withAlphaComponent(0.1).setStroke()
                divider.lineWidth = 1
                divider.stroke()
            }
        }

        installRenderedBlock(image, in: range)
        return true
    }

    private func installRenderedBlock(
        _ image: NSImage,
        taskHits: [RenderedTaskHit] = [],
        locksEditing: Bool = false,
        in range: NSRange
    ) {
        guard range.length > 0 else { return }
        let placeholderRange = NSRange(location: range.location, length: 1)
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = image.size.height
        paragraph.maximumLineHeight = image.size.height
        paragraph.lineSpacing = 0
        textStorage.addAttribute(.paragraphStyle, value: paragraph, range: placeholderRange)
        textStorage.addAttributes([
            .foregroundColor: NSColor.clear,
            .focnotesRenderedBlock: RenderedBlockPayload(
                image: image,
                taskHits: taskHits,
                locksEditing: locksEditing
            )
        ], range: placeholderRange)
        if range.length > 1 {
            hide(NSRange(location: range.location + 1, length: range.length - 1))
        }
    }

    private func tableCells(_ line: String) -> [String] {
        var value = line.trimmingCharacters(in: .whitespaces)
        if value.hasPrefix("|") { value.removeFirst() }
        if value.hasSuffix("|") { value.removeLast() }
        var cells: [String] = []
        var current = ""
        var escaped = false
        for character in value {
            if character == "|", !escaped {
                cells.append(current.trimmingCharacters(in: .whitespaces))
                current = ""
            } else {
                current.append(character)
            }
            escaped = character == "\\" && !escaped
            if character != "\\" { escaped = false }
        }
        cells.append(current.trimmingCharacters(in: .whitespaces))
        return cells
    }

    private func cleanTableCell(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\[\\[([^\\]|]+)\\|([^\\]]+)\\]\\]", with: "$2", options: .regularExpression)
            .replacingOccurrences(of: "\\[\\[([^\\]]+)\\]\\]", with: "$1", options: .regularExpression)
            .replacingOccurrences(of: "[*_~`]", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\\\|", with: "|")
    }

    private func styleThematicBreak(_ range: NSRange) {
        applyPresentation([.focnotesThematicBreak: true], forCharacterRange: range)
        if selectionTouchesIncludingEnd(range) {
            applyPresentation([.foregroundColor: FocnotesPalette.faintInk], forCharacterRange: range)
        } else {
            hide(range)
        }
    }

    private func styleBlockQuote(_ range: NSRange) {
        applyPresentation([.focnotesBlockQuote: true], forCharacterRange: range)
        guard let expression = try? NSRegularExpression(pattern: "^[ \\t]*>\\s?", options: .anchorsMatchLines) else { return }
        expression.enumerateMatches(in: source, range: range) { [weak self] match, _, _ in
            guard let self, let match else { return }
            let lineRange = sourceNSString.lineRange(for: match.range)
            if selectionTouchesIncludingEnd(lineRange) {
                applyPresentation([.foregroundColor: FocnotesPalette.mutedInk], forCharacterRange: match.range)
            } else {
                hide(match.range)
            }
        }
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

    private func styleImage(_ range: NSRange) {
        let value = sourceNSString.substring(with: range) as NSString
        let closeLabel = value.range(of: "]")
        guard value.hasPrefix("!["), closeLabel.location != NSNotFound else {
            applyPresentation([.foregroundColor: FocnotesPalette.accentBlue], forCharacterRange: range)
            return
        }
        let altText = NSRange(location: range.location + 2, length: max(0, closeLabel.location - 2))
        applyPresentation([
            .foregroundColor: FocnotesPalette.accentBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ], forCharacterRange: altText)
        guard !selectionTouchesIncludingEnd(range) else { return }
        hide(NSRange(location: range.location, length: 2))
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
        textStorage.addAttributes(attributes, range: range)
    }

    private func characterRange(for markup: Markup) -> NSRange? {
        analysis.characterRange(for: markup)
    }
}

final class NoteView: NSView {
    private let blurView = NSVisualEffectView()
    private let paperTintView = NSView()
    private let titleBar = NSView()
    private let titleLabel = NSTextField(labelWithString: "")
    private let closeButton = TitleBarControlButton(
        activeColor: NSColor(srgbRed: 1, green: 95 / 255, blue: 87 / 255, alpha: 1),
        glyph: .close
    )
    private let newNoteButton = TitleBarControlButton(
        activeColor: NSColor(srgbRed: 40 / 255, green: 200 / 255, blue: 64 / 255, alpha: 1),
        glyph: .plus
    )
    private let previousDayButton = TitleBarNavigationButton(symbolName: "chevron.left", toolTip: "Nota diaria anterior")
    private let todayButton = TitleBarNavigationButton(symbolName: "calendar", toolTip: "Nota de hoy")
    private let nextDayButton = TitleBarNavigationButton(symbolName: "chevron.right", toolTip: "Nota diaria siguiente")
    private let textView = MarkdownTextView()
    private let textRightPadding: CGFloat = 0
    private let fileURL: URL?
    private let initialText: String?
    private let titleChanged: (String) -> Void
    private let textChanged: (String) -> Void
    private let newNoteRequested: () -> Void
    private let dailyNavigationState: DailyNavigationState?
    private let dailyNavigationRequested: ((DailyNoteNavigation) -> Void)?
    private var isUpdatingMarkdown = false
    private var isApplyingHighlighting = false
    private var preferencesObserver: NSObjectProtocol?
    private var titleBarTrackingArea: NSTrackingArea?
    private var focusPreviewWorkItem: DispatchWorkItem?
    private var taskIndexObserver: NSObjectProtocol?
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
        newNoteRequested: @escaping () -> Void = {},
        dailyNavigationState: DailyNavigationState? = nil,
        dailyNavigationRequested: ((DailyNoteNavigation) -> Void)? = nil
    ) {
        self.fileURL = fileURL
        self.initialText = initialText
        self.titleChanged = titleChanged
        self.textChanged = textChanged
        self.newNoteRequested = newNoteRequested
        self.dailyNavigationState = dailyNavigationState
        self.dailyNavigationRequested = dailyNavigationRequested
        super.init(frame: frameRect)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        focusPreviewWorkItem?.cancel()
        if let taskIndexObserver {
            NotificationCenter.default.removeObserver(taskIndexObserver)
        }
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

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let titleBarTrackingArea {
            titleBar.removeTrackingArea(titleBarTrackingArea)
        }
        let trackingArea = NSTrackingArea(
            rect: .zero,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        titleBar.addTrackingArea(trackingArea)
        titleBarTrackingArea = trackingArea
    }

    override func mouseEntered(with event: NSEvent) {
        setTitleBarControlsVisible(true)
    }

    override func mouseExited(with event: NSEvent) {
        setTitleBarControlsVisible(false)
    }

    func focusEditor() {
        window?.makeFirstResponder(textView)
    }

    func updateWindowFocusAppearance() {
        refreshTitleBarButtons()
        scheduleFocusPreviewUpdate()
    }

    private func refreshTitleBarButtons() {
        closeButton.needsDisplay = true
        newNoteButton.needsDisplay = true
        closeButton.displayIfNeeded()
        newNoteButton.displayIfNeeded()
    }

    private func setupView() {
        let windowCornerRadius: CGFloat = 10
        wantsLayer = true
        layer?.cornerRadius = windowCornerRadius
        layer?.backgroundColor = NSColor.clear.cgColor
        layer?.borderWidth = 1
        layer?.borderColor = FocnotesPalette.ink.withAlphaComponent(0.18).cgColor

        blurView.frame = bounds
        blurView.autoresizingMask = [.width, .height]
        blurView.blendingMode = .behindWindow
        blurView.material = .popover
        blurView.state = .active
        blurView.alphaValue = AppPreferences.blurIntensity / 100
        blurView.wantsLayer = true
        blurView.layer?.cornerRadius = windowCornerRadius
        blurView.layer?.masksToBounds = true

        paperTintView.frame = bounds
        paperTintView.autoresizingMask = [.width, .height]
        paperTintView.wantsLayer = true
        paperTintView.layer?.cornerRadius = windowCornerRadius
        paperTintView.layer?.masksToBounds = true
        paperTintView.layer?.backgroundColor = FocnotesPalette.paper.cgColor

        titleBar.translatesAutoresizingMaskIntoConstraints = false
        titleBar.wantsLayer = true
        titleBar.layer?.cornerRadius = windowCornerRadius
        titleBar.layer?.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        titleBar.layer?.backgroundColor = NSColor.clear.cgColor

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

        closeButton.title = ""
        closeButton.isBordered = false
        closeButton.alphaValue = 0
        closeButton.toolTip = "Cerrar"
        closeButton.target = self
        closeButton.action = #selector(closeNote)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        titleBar.addSubview(closeButton)

        newNoteButton.title = ""
        newNoteButton.isBordered = false
        newNoteButton.alphaValue = 0
        newNoteButton.toolTip = "Nueva nota (⌘N)"
        newNoteButton.target = self
        newNoteButton.action = #selector(requestNewNote)
        newNoteButton.translatesAutoresizingMaskIntoConstraints = false
        titleBar.addSubview(newNoteButton)

        for (button, action) in [
            (previousDayButton, #selector(showPreviousDailyNote)),
            (todayButton, #selector(showTodayDailyNote)),
            (nextDayButton, #selector(showNextDailyNote))
        ] {
            button.target = self
            button.action = action
            button.alphaValue = 0
            button.translatesAutoresizingMaskIntoConstraints = false
            button.isHidden = dailyNavigationState == nil
            titleBar.addSubview(button)
        }
        previousDayButton.isEnabled = dailyNavigationState?.hasPrevious ?? false
        nextDayButton.isEnabled = dailyNavigationState?.hasNext ?? false
        todayButton.isHidden = dailyNavigationState == nil || dailyNavigationState?.isToday == true

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
        textView.font = .systemFont(ofSize: AppPreferences.editorFontSize, weight: .regular)
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
        textView.textContainerInset = CGSize(width: 12, height: 4)
        textView.delegate = self
        textView.checkboxClicked = { [weak self] range in
            self?.toggleCheckbox(at: range)
        }
        textView.wikiLinkClicked = { [weak self] target in
            ObsidianWikiLinkResolver.open(target: target, sourceFileURL: self?.fileURL)
        }
        textView.editingFocusChanged = { [weak self] in
            self?.scheduleFocusPreviewUpdate()
        }
        textView.renderedTaskClicked = { [weak self] task in
            guard let self else { return }
            do {
                let updated = try TasksQueryEngine.toggle(task)
                if task.fileURL.standardizedFileURL == self.fileURL?.standardizedFileURL {
                    self.isUpdatingMarkdown = true
                    self.textView.string = updated
                    self.isUpdatingMarkdown = false
                }
                self.updateLivePreview()
            } catch {
                NSSound.beep()
                self.updateLivePreview()
            }
        }
        taskIndexObserver = NotificationCenter.default.addObserver(
            forName: TasksQueryEngine.indexDidChange,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self, let root = notification.object as? URL,
                  let fileURL = self.fileURL,
                  fileURL.standardizedFileURL.path.hasPrefix(root.path + "/"),
                  self.textView.hasClosedTasksQuery else { return }
            self.updateLivePreview()
        }
        preferencesObserver = NotificationCenter.default.addObserver(
            forName: AppPreferences.changedNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applyTheme()
        }
        scrollView.documentView = textView
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
            titleLabel.trailingAnchor.constraint(
                equalTo: titleBar.trailingAnchor,
                constant: dailyNavigationState == nil ? -30 : -88
            ),
            closeButton.centerYAnchor.constraint(equalTo: titleBar.centerYAnchor),
            closeButton.leadingAnchor.constraint(equalTo: titleBar.leadingAnchor, constant: 2),
            closeButton.widthAnchor.constraint(equalToConstant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 20),
            newNoteButton.centerYAnchor.constraint(equalTo: titleBar.centerYAnchor),
            newNoteButton.trailingAnchor.constraint(equalTo: titleBar.trailingAnchor, constant: -2),
            newNoteButton.widthAnchor.constraint(equalToConstant: 20),
            newNoteButton.heightAnchor.constraint(equalToConstant: 20),
            nextDayButton.centerYAnchor.constraint(equalTo: titleBar.centerYAnchor),
            nextDayButton.trailingAnchor.constraint(equalTo: newNoteButton.leadingAnchor, constant: -1),
            nextDayButton.widthAnchor.constraint(equalToConstant: 16),
            nextDayButton.heightAnchor.constraint(equalToConstant: 20),
            todayButton.centerYAnchor.constraint(equalTo: titleBar.centerYAnchor),
            todayButton.trailingAnchor.constraint(equalTo: nextDayButton.leadingAnchor),
            todayButton.widthAnchor.constraint(equalToConstant: 18),
            todayButton.heightAnchor.constraint(equalToConstant: 20),
            previousDayButton.centerYAnchor.constraint(equalTo: titleBar.centerYAnchor),
            previousDayButton.trailingAnchor.constraint(equalTo: todayButton.leadingAnchor),
            previousDayButton.widthAnchor.constraint(equalToConstant: 16),
            previousDayButton.heightAnchor.constraint(equalToConstant: 20),
            scrollView.topAnchor.constraint(equalTo: titleBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
        layoutSubtreeIfNeeded()
        updateTextLayoutWidth()
        applyTheme()
    }

    private func setTitleBarControlsVisible(_ visible: Bool) {
        refreshTitleBarButtons()
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            closeButton.animator().alphaValue = visible ? 1 : 0
            newNoteButton.animator().alphaValue = visible ? 1 : 0
            previousDayButton.animator().alphaValue = visible ? 1 : 0
            todayButton.animator().alphaValue = visible ? 1 : 0
            nextDayButton.animator().alphaValue = visible ? 1 : 0
        }
    }

    private func updateTextLayoutWidth() {
        guard let scrollView = textView.enclosingScrollView else { return }
        let width = max(scrollView.contentSize.width - textRightPadding, 100)
        guard textView.frame.width != width || textView.textContainer?.size.width != width else { return }
        textView.frame.size.width = width
        textView.textContainer?.containerSize = NSSize(
            width: width,
            height: CGFloat.greatestFiniteMagnitude
        )
        scheduleFocusPreviewUpdate()
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
        textView.isUpdatingPresentation = true
        window?.disableScreenUpdatesUntilFlush()
        let undoManager = textView.undoManager
        let shouldRestoreUndoRegistration = undoManager?.isUndoRegistrationEnabled == true
        if shouldRestoreUndoRegistration {
            undoManager?.disableUndoRegistration()
        }
        defer {
            if shouldRestoreUndoRegistration {
                undoManager?.enableUndoRegistration()
            }
            isApplyingHighlighting = false
            textView.isUpdatingPresentation = false
            DispatchQueue.main.async { [weak textView] in
                guard let textView, let window = textView.window else { return }
                window.invalidateCursorRects(for: textView)
            }
        }
        let scrollView = textView.enclosingScrollView
        let visibleOrigin = scrollView?.contentView.bounds.origin
        let fullRange = NSRange(location: 0, length: storage.length)
        let baseFont = NSFont.systemFont(ofSize: AppPreferences.editorFontSize, weight: .regular)
        let baseColor = FocnotesPalette.ink.withAlphaComponent(0.86)

        storage.beginEditing()
        for key: NSAttributedString.Key in [
            .font,
            .kern,
            .foregroundColor,
            .backgroundColor,
            .strikethroughStyle,
            .underlineStyle,
            .focnotesInlineCode,
            .focnotesCodeBlock,
            .focnotesTableRow,
            .focnotesThematicBreak,
            .focnotesBlockQuote,
            .focnotesRenderedBlock
        ] {
            storage.removeAttribute(key, range: fullRange)
        }

        storage.addAttribute(.font, value: baseFont, range: fullRange)
        storage.addAttribute(.foregroundColor, value: baseColor, range: fullRange)
        if let paragraphStyle = textView.defaultParagraphStyle {
            storage.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
        }
        let analysis = textView.markdownAnalysis
        let renderer = MarkdownPresentationRenderer(
            analysis: analysis,
            textStorage: storage,
            selections: activeEditorSelections,
            fontSize: AppPreferences.editorFontSize,
            renderWidth: max(180, (textView.textContainer?.size.width ?? textView.bounds.width) - 10),
            sourceFileURL: fileURL
        )
        renderer.render(analysis.document)
        renderer.renderInlineLinks()
        textView.renderedWikiLinks = renderer.renderWikiLinks()
        applyListDecorations(storage: storage)
        storage.endEditing()

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
    }

    private func applyListDecorations(storage: NSTextStorage) {
        let source = storage.string as NSString
        let selections = activeEditorSelections
        let selectionTouches: (NSRange) -> Bool = { range in
            selections.contains { selection in
                if selection.length > 0 {
                    return NSIntersectionRange(selection, range).length > 0
                }
                return selection.location >= range.location && selection.location < NSMaxRange(range)
            }
        }

        textView.markdownAnalysis.tasks.forEach { result in
            let syntaxRange = result.range(at: 1)
            guard storage.attribute(
                .focnotesCodeBlock,
                at: syntaxRange.location,
                effectiveRange: nil
            ) == nil else { return }
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
            let markerFont = NSFont.monospacedSystemFont(ofSize: 8, weight: .regular)
            storage.addAttribute(
                .font,
                value: markerFont,
                range: result.range(at: 2)
            )
            // Match the marker advance to the checkbox's right edge (3 + 14),
            // leaving the source space as the only gap before the text.
            let markerWidth = (source.substring(with: result.range(at: 2)) as NSString)
                .size(withAttributes: [.font: markerFont]).width
            storage.addAttribute(
                .kern,
                value: CGFloat(17) - markerWidth,
                range: NSRange(location: NSMaxRange(result.range(at: 2)) - 1, length: 1)
            )
            storage.addAttributes(
                [.foregroundColor: NSColor.clear],
                range: syntaxRange
            )
        }


        textView.markdownAnalysis.bullets.forEach { result in
            let markerRange = result.range(at: 1)
            guard storage.attribute(
                .focnotesCodeBlock,
                at: markerRange.location,
                effectiveRange: nil
            ) == nil,
            storage.attribute(
                .focnotesThematicBreak,
                at: markerRange.location,
                effectiveRange: nil
            ) == nil else { return }
            let syntaxRange = NSRange(location: markerRange.location, length: min(2, storage.length - markerRange.location))
            guard !selectionTouches(syntaxRange) else { return }
            storage.addAttribute(.foregroundColor, value: NSColor.clear, range: markerRange)
        }
    }

    private func updateLivePreview() {
        focusPreviewWorkItem?.cancel()
        focusPreviewWorkItem = nil
        applyMarkdownHighlighting()
    }

    private func scheduleFocusPreviewUpdate() {
        focusPreviewWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.updateLivePreview()
        }
        focusPreviewWorkItem = workItem
        DispatchQueue.main.async(execute: workItem)
    }

    private var activeEditorSelections: [NSRange] {
        textView.activeEditorSelections
    }

    private func applyTheme() {
        blurView.alphaValue = AppPreferences.blurIntensity / 100
        paperTintView.layer?.backgroundColor = FocnotesPalette.paper.cgColor
        titleBar.layer?.backgroundColor = NSColor.clear.cgColor
        layer?.borderColor = FocnotesPalette.ink.withAlphaComponent(0.18).cgColor
        titleLabel.textColor = FocnotesPalette.mutedInk.withAlphaComponent(0.24)
        [previousDayButton, todayButton, nextDayButton].forEach {
            $0.contentTintColor = FocnotesPalette.mutedInk
        }
        textView.textColor = FocnotesPalette.ink.withAlphaComponent(0.86)
        textView.insertionPointColor = FocnotesPalette.accent
        updateLivePreview()
    }

    @objc private func requestNewNote() {
        newNoteRequested()
    }

    @objc private func showPreviousDailyNote() {
        dailyNavigationRequested?(.previous)
    }

    @objc private func showTodayDailyNote() {
        dailyNavigationRequested?(.today)
    }

    @objc private func showNextDailyNote() {
        dailyNavigationRequested?(.next)
    }

    @objc private func closeNote() {
        NSApp.terminate(nil)
    }

    private func toggleCheckbox(at range: NSRange) {
        let source = textView.string as NSString
        guard range.location != NSNotFound, range.length == 3, NSMaxRange(range) <= source.length else { return }
        let current = source.substring(with: range)
        guard current == "[ ]" || current.lowercased() == "[x]" else { return }
        let valueRange = NSRange(location: range.location + 1, length: 1)
        let value = current.lowercased() == "[x]" ? " " : "x"
        guard textView.shouldChangeText(in: valueRange, replacementString: value) else { return }
        isUpdatingMarkdown = true
        textView.textStorage?.replaceCharacters(in: valueRange, with: value)
        isUpdatingMarkdown = false
        textView.didChangeText()
        NSCursor.pointingHand.set()
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
            TasksQueryEngine.updateFile(at: fileURL, content: textView.string)
        } else {
            textChanged(textView.string)
        }
        updateTitle()
    }
}

extension NoteView: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        guard !isUpdatingMarkdown else { return }
        persistText()
        updateLivePreview()
    }

    func textViewDidChangeSelection(_ notification: Notification) {
        guard !isApplyingHighlighting, !isUpdatingMarkdown else { return }
        // Typing also changes the selection. Coalesce that notification with textDidChange.
        scheduleFocusPreviewUpdate()
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
        // Custom list insertion bypasses NSTextView's normal caret scrolling.
        // Scroll after didChangeText has refreshed the Markdown layout.
        textView.scrollRangeToVisible(textView.selectedRange())
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

        configureField(hexField, width: 86, placeholder: "#FFF1A8")
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
    case dailyNotes
    case appearance
    case about

    var title: String {
        switch self {
        case .general: return "General"
        case .editor: return "Editor"
        case .dailyNotes: return "Notas diarias"
        case .appearance: return "Apariencia"
        case .about: return "Acerca de"
        }
    }

    var symbolName: String {
        switch self {
        case .general: return "seal"
        case .editor: return "textformat"
        case .dailyNotes: return "calendar"
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
    private weak var dailyFormatField: NSTextField?

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
        case .dailyNotes: sectionView = dailyNotesView()
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

        let visibilityShortcut = ShortcutRecorderButton(shortcut: AppPreferences.visibilityShortcut)
        visibilityShortcut.onShortcutChanged = { shortcut in
            AppPreferences.setVisibilityShortcut(shortcut)
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
                ),
                settingRow(
                    title: "Mostrar u ocultar la nota",
                    detail: "Hace aparecer o desvanece la nota activa.",
                    control: visibilityShortcut
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

    private func dailyNotesView() -> NSView {
        let importButton = NSButton(title: "Importar…", target: self, action: #selector(importObsidianDailyNotes))
        importButton.bezelStyle = .rounded

        let folderButton = NSButton(title: "Elegir…", target: self, action: #selector(chooseDailyNotesFolder))
        folderButton.bezelStyle = .rounded

        let templateButtons = NSStackView()
        templateButtons.orientation = .horizontal
        templateButtons.spacing = 6
        let templateButton = NSButton(title: "Elegir…", target: self, action: #selector(chooseDailyNotesTemplate))
        templateButton.bezelStyle = .rounded
        let clearTemplateButton = NSButton(title: "Quitar", target: self, action: #selector(clearDailyNotesTemplate))
        clearTemplateButton.bezelStyle = .rounded
        templateButtons.addArrangedSubview(templateButton)
        templateButtons.addArrangedSubview(clearTemplateButton)

        let formatField = NSTextField(string: AppPreferences.dailyNotesDateFormat)
        formatField.placeholderString = "YYYY-MM-DD"
        formatField.delegate = self
        formatField.target = self
        formatField.action = #selector(changeDailyNotesFormat(_:))
        formatField.translatesAutoresizingMaskIntoConstraints = false
        formatField.widthAnchor.constraint(equalToConstant: 132).isActive = true
        dailyFormatField = formatField

        let shortcut = ShortcutRecorderButton(shortcut: AppPreferences.dailyNotesShortcut)
        shortcut.onShortcutChanged = { shortcut in
            AppPreferences.setDailyNotesShortcut(shortcut)
        }

        let folderDetail = AppPreferences.dailyNotesFolder.isEmpty
            ? "Carpeta donde se crearán y buscarán las notas."
            : AppPreferences.dailyNotesFolder
        let templateDetail = AppPreferences.dailyNotesTemplate.isEmpty
            ? "Sin plantilla; las notas nuevas comenzarán vacías."
            : AppPreferences.dailyNotesTemplate

        return sectionStack(title: "Notas diarias", groups: [
            ("OBSIDIAN", [
                settingRow(
                    title: "Importar configuración",
                    detail: "Lee carpeta, formato y plantilla desde .obsidian/daily-notes.json.",
                    control: importButton
                )
            ]),
            ("ARCHIVOS", [
                settingRow(title: "Carpeta", detail: folderDetail, control: folderButton),
                settingRow(title: "Plantilla", detail: templateDetail, control: templateButtons),
                settingRow(
                    title: "Formato de fecha",
                    detail: "Acepta formatos de Obsidian/Moment, por ejemplo YYYY-MM-DD.",
                    control: formatField
                )
            ]),
            ("ATAJO", [
                settingRow(
                    title: "Abrir la nota de hoy",
                    detail: "Crea la nota con la plantilla si todavía no existe.",
                    control: shortcut
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

    @objc private func importObsidianDailyNotes() {
        let panel = NSOpenPanel()
        panel.title = "Selecciona tu vault de Obsidian"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try DailyNotes.importObsidianConfiguration(from: url)
            showSection(.dailyNotes)
        } catch {
            presentDailyNotesError(error)
        }
    }

    @objc private func chooseDailyNotesFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.directoryURL = DailyNotes.folderURL
        guard panel.runModal() == .OK, let url = panel.url else { return }
        AppPreferences.setDailyNotesFolder(url.standardizedFileURL.path)
        showSection(.dailyNotes)
    }

    @objc private func chooseDailyNotesTemplate() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        AppPreferences.setDailyNotesTemplate(url.standardizedFileURL.path)
        showSection(.dailyNotes)
    }

    @objc private func clearDailyNotesTemplate() {
        AppPreferences.setDailyNotesTemplate("")
        showSection(.dailyNotes)
    }

    @objc private func changeDailyNotesFormat(_ sender: NSTextField) {
        let value = sender.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else {
            NSSound.beep()
            sender.stringValue = AppPreferences.dailyNotesDateFormat
            return
        }
        AppPreferences.setDailyNotesDateFormat(value)
    }

    private func presentDailyNotesError(_ error: Error) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "No se pudo configurar Notas diarias"
        alert.informativeText = error.localizedDescription
        alert.runModal()
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
        } else if field === dailyFormatField {
            changeDailyNotesFormat(field)
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
            contentRect: NSRect(x: 0, y: 0, width: 760, height: 620),
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
    private var currentDailyNoteDate: Date?
    private var history: [HistoryItem] = []
    private var internalNotes: [InternalNote] = []
    private var pendingDefaultPanel: DispatchWorkItem?
    private var settingsWindowController: SettingsWindowController?
    private var preferencesObserver: NSObjectProtocol?
    private var focusHotKey: EventHotKeyRef?
    private var visibilityHotKey: EventHotKeyRef?
    private var dailyNotesHotKey: EventHotKeyRef?
    private var hotKeyHandler: EventHandlerRef?
    private var externalClickMonitor: Any?
    private var pendingOpenURL: URL?
    private var isReadyForFiles = false
    private var isNoteHidden = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        DailyNotes.importDetectedObsidianConfigurationIfNeeded()
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
        registerVisibilityHotKey()
        registerDailyNotesHotKey()
        externalClickMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] _ in
            DispatchQueue.main.async {
                self?.panel?.setVisualFocus(false)
            }
        }
        preferencesObserver = NotificationCenter.default.addObserver(
            forName: AppPreferences.changedNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applyPanelPreferences()
            self?.registerFocusHotKey()
            self?.registerVisibilityHotKey()
            self?.registerDailyNotesHotKey()
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
        if let dailyNotesHotKey {
            UnregisterEventHotKey(dailyNotesHotKey)
        }
        if let visibilityHotKey {
            UnregisterEventHotKey(visibilityHotKey)
        }
        if let hotKeyHandler {
            RemoveEventHandler(hotKeyHandler)
        }
        if let externalClickMonitor {
            NSEvent.removeMonitor(externalClickMonitor)
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
                guard status == noErr else { return noErr }
                let delegate = Unmanaged<AppDelegate>.fromOpaque(userData).takeUnretainedValue()
                DispatchQueue.main.async {
                    switch hotKeyID.id {
                    case 1: delegate.focusNote()
                    case 2: delegate.openTodayDailyNote()
                    case 3: delegate.toggleNoteVisibility()
                    default: break
                    }
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

    private func registerDailyNotesHotKey() {
        if let dailyNotesHotKey {
            UnregisterEventHotKey(dailyNotesHotKey)
            self.dailyNotesHotKey = nil
        }
        let shortcut = AppPreferences.dailyNotesShortcut
        let hotKeyID = EventHotKeyID(signature: OSType(0x464F_434E), id: 2)
        RegisterEventHotKey(
            shortcut.keyCode,
            shortcut.modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &dailyNotesHotKey
        )
    }

    private func registerVisibilityHotKey() {
        if let visibilityHotKey {
            UnregisterEventHotKey(visibilityHotKey)
            self.visibilityHotKey = nil
        }
        let shortcut = AppPreferences.visibilityShortcut
        let hotKeyID = EventHotKeyID(signature: OSType(0x464F_434E), id: 3)
        RegisterEventHotKey(
            shortcut.keyCode,
            shortcut.modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &visibilityHotKey
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
        isNoteHidden = false
        panel.alphaValue = 1
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        panel.setVisualFocus(true)
        DispatchQueue.main.async { [weak panel] in
            guard let panel else { return }
            panel.makeKey()
            (panel.contentView as? NoteView)?.focusEditor()
        }
    }

    private func toggleNoteVisibility() {
        if panel == nil {
            focusNote()
            return
        }
        guard let panel else { return }

        isNoteHidden.toggle()
        if isNoteHidden {
            panel.setVisualFocus(false)
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                panel.animator().alphaValue = 0
            } completionHandler: { [weak self, weak panel] in
                guard let self, let panel, self.isNoteHidden else { return }
                panel.orderOut(nil)
                panel.alphaValue = 1
            }
        } else {
            panel.alphaValue = 0
            panel.orderFrontRegardless()
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                panel.animator().alphaValue = 1
            }
        }
    }

    private func openFile(_ url: URL) {
        pendingDefaultPanel?.cancel()
        pendingDefaultPanel = nil
        currentFileURL = url
        currentNoteID = nil
        currentDailyNoteDate = DailyNotes.date(for: url)
        recordFile(url)
        saveLastOpenedItem(LastOpenedItem(kind: .file, value: url.path))
        if let panel {
            let size = panel.contentView?.bounds.size ?? panel.contentRect(forFrameRect: panel.frame).size
            panel.title = url.deletingPathExtension().lastPathComponent
            panel.contentView = makeFileNoteView(frame: NSRect(origin: .zero, size: size), url: url, panel: panel)
            panel.contentView?.layoutSubtreeIfNeeded()
            panel.contentView?.displayIfNeeded()
            panel.orderFrontRegardless()
        } else {
            createPanel(fileURL: url)
        }
    }

    @objc private func openTodayDailyNote() {
        do {
            let url = try DailyNotes.ensureFile(for: Date())
            openFile(url)
            focusNote()
        } catch {
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = "No se pudo abrir la nota diaria"
            alert.informativeText = error.localizedDescription
            alert.runModal()
        }
    }

    private func navigateDailyNote(_ navigation: DailyNoteNavigation) {
        guard let currentFileURL, currentDailyNoteDate != nil else { return }
        if navigation == .today {
            openTodayDailyNote()
            return
        }
        let files = DailyNotes.existingFiles()
        guard let index = files.firstIndex(where: { $0.url.standardizedFileURL == currentFileURL.standardizedFileURL }) else {
            return
        }
        let targetIndex = navigation == .previous ? index - 1 : index + 1
        guard files.indices.contains(targetIndex) else { return }
        openFile(files[targetIndex].url)
        self.currentDailyNoteDate = files[targetIndex].date
    }

    private func dailyNavigationState(for url: URL) -> DailyNavigationState? {
        guard let date = DailyNotes.date(for: url) else { return nil }
        let files = DailyNotes.existingFiles()
        guard let index = files.firstIndex(where: { $0.url.standardizedFileURL == url.standardizedFileURL }) else {
            return DailyNavigationState(hasPrevious: false, hasNext: false, isToday: Calendar.current.isDateInToday(date))
        }
        return DailyNavigationState(
            hasPrevious: index > files.startIndex,
            hasNext: index < files.index(before: files.endIndex),
            isToday: Calendar.current.isDateInToday(date)
        )
    }

    private func makeFileNoteView(
        frame: NSRect,
        url: URL,
        panel: FloatingNotePanel
    ) -> NoteView {
        let navigationState = dailyNavigationState(for: url)
        return NoteView(
            frame: frame,
            fileURL: url,
            titleChanged: { [weak panel] title in panel?.title = title },
            newNoteRequested: { [weak self] in self?.createInternalNote() },
            dailyNavigationState: navigationState,
            dailyNavigationRequested: navigationState == nil ? nil : { [weak self] navigation in
                self?.navigateDailyNote(navigation)
            }
        )
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
        currentDailyNoteDate = nil
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
        let todayItem = NSMenuItem(title: "Nota diaria de hoy", action: #selector(openTodayDailyNote), keyEquivalent: "")
        todayItem.target = self
        fileMenu.addItem(todayItem)
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
        let todayItem = NSMenuItem(title: "Nota diaria de hoy", action: #selector(openTodayDailyNote), keyEquivalent: "")
        todayItem.target = self
        menu.addItem(todayItem)

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
        } else if let fileURL {
            currentDailyNoteDate = DailyNotes.date(for: fileURL)
            panel.contentView = makeFileNoteView(frame: NSRect(origin: .zero, size: size), url: fileURL, panel: panel)
        } else {
            panel.contentView = NoteView(
                frame: NSRect(origin: .zero, size: size),
                fileURL: nil,
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
        panel.installFocusShadow()
        panel.orderFrontRegardless()
        panel.contentView?.layoutSubtreeIfNeeded()
        panel.contentView?.displayIfNeeded()
        panel.invalidateShadow()

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
