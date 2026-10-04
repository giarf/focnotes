import AppKit

func sealIcon(size: CGFloat, template: Bool) -> NSImage {
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

func exportSealIcons(to directory: String) {
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
