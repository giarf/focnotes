import AppKit

extension NSAttributedString.Key {
    static let focnotesInlineCode = NSAttributedString.Key("FocnotesInlineCode")
    static let focnotesCodeBlock = NSAttributedString.Key("FocnotesCodeBlock")
    static let focnotesTableRow = NSAttributedString.Key("FocnotesTableRow")
    static let focnotesThematicBreak = NSAttributedString.Key("FocnotesThematicBreak")
    static let focnotesBlockQuote = NSAttributedString.Key("FocnotesBlockQuote")
    static let focnotesRenderedBlock = NSAttributedString.Key("FocnotesRenderedBlock")
}

extension NSColor {
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
        guard let rgb = usingColorSpace(.sRGB) else { return "#FFF1A8" }
        return String(
            format: "#%02X%02X%02X",
            Int(round(rgb.redComponent * 255)),
            Int(round(rgb.greenComponent * 255)),
            Int(round(rgb.blueComponent * 255))
        )
    }

    var rgbComponents255: (red: Int, green: Int, blue: Int) {
        guard let rgb = usingColorSpace(.sRGB) else { return (255, 241, 168) }
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

enum NoteTheme: String, CaseIterable {
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
        case .yellow: return NSColor(hex: "#FFF1A8")!
        case .dark: return NSColor(hex: "#202127")!
        case .cream: return NSColor(hex: "#F3E7CF")!
        case .sage: return NSColor(hex: "#CFE5D2")!
        case .sky: return NSColor(hex: "#CAE4F7")!
        case .lavender: return NSColor(hex: "#DED5F7")!
        case .coral: return NSColor(hex: "#F6D0C6")!
        }
    }
}

enum FocnotesPalette {
    static var paper: NSColor { AppPreferences.noteColor.withAlphaComponent(AppPreferences.noteOpacity / 100) }
    static var ink: NSColor { paper.isDark ? NSColor(white: 0.96, alpha: 1) : NSColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1) }
    static var mutedInk: NSColor { ink.withAlphaComponent(0.58) }
    static var faintInk: NSColor { ink.withAlphaComponent(0.36) }
    static var accent: NSColor {
        AppPreferences.accentColor ?? (paper.isDark ? NSColor(hex: "#A99BFF")! : NSColor(hex: "#5C40F2")!)
    }
    static var accentBlue: NSColor { paper.isDark ? NSColor(hex: "#77B7FF")! : NSColor(red: 0.02, green: 0.33, blue: 0.82, alpha: 1) }
    static var code: NSColor { accent }
    static var softHighlight: NSColor {
        let base = AppPreferences.noteColor
        if base.isDark {
            return base.blended(withFraction: 0.2, of: .black) ?? base
        }

        guard let rgb = base.usingColorSpace(.sRGB) else { return base }
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        rgb.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return NSColor(
            calibratedHue: hue,
            saturation: min(saturation * 1.8, 1),
            brightness: brightness,
            alpha: alpha
        )
    }
    static var highlight: NSColor { paper.isDark ? NSColor(hex: "#DCD7A0")! : NSColor(red: 1.0, green: 0.95, blue: 0.63, alpha: 1) }
}
