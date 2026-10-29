import AppKit

/// Shared vector artwork: modern geometric "N" monogram with emerald gradients.
enum NevraArtwork {
    static let emerald = NSColor(srgbRed: 0.06, green: 0.73, blue: 0.51, alpha: 1) // #10B981
    static let deepEmerald = NSColor(srgbRed: 0.02, green: 0.48, blue: 0.35, alpha: 1) // #047857
    static let cyan = NSColor(srgbRed: 0.08, green: 0.82, blue: 0.76, alpha: 1) // #14B8A6
    static let gold = emerald // Backwards compatibility for callers
    static let ink = NSColor(srgbRed: 0.06, green: 0.12, blue: 0.10, alpha: 1)

    static func draw(in rect: NSRect, happy: Bool = false, monochrome: Bool = false) {
        guard let c = NSGraphicsContext.current?.cgContext else { return }
        c.saveGState(); defer { c.restoreGState() }
        c.translateBy(x: rect.minX, y: rect.maxY)
        c.scaleBy(x: rect.width, y: -rect.height)

        if monochrome {
            c.setFillColor(NSColor.black.cgColor)
            c.setStrokeColor(NSColor.black.cgColor)
            
            // Left column
            c.addPath(CGPath(roundedRect: CGRect(x: 0.18, y: 0.16, width: 0.16, height: 0.68), cornerWidth: 0.06, cornerHeight: 0.06, transform: nil))
            c.fillPath()
            
            // Right column
            c.addPath(CGPath(roundedRect: CGRect(x: 0.66, y: 0.16, width: 0.16, height: 0.68), cornerWidth: 0.06, cornerHeight: 0.06, transform: nil))
            c.fillPath()
            
            // Diagonal bridge
            c.setLineWidth(0.14)
            c.setLineCap(.round)
            c.move(to: CGPoint(x: 0.26, y: 0.24))
            c.addLine(to: CGPoint(x: 0.74, y: 0.76))
            c.strokePath()
        } else {
            // Modern squircle frame with dark slate
            let bgRect = CGRect(x: 0.06, y: 0.06, width: 0.88, height: 0.88)
            let squircle = CGPath(roundedRect: bgRect, cornerWidth: 0.22, cornerHeight: 0.22, transform: nil)
            c.saveGState()
            c.addPath(squircle)
            c.clip()
            
            let bgColors = [
                NSColor(srgbRed: 0.10, green: 0.13, blue: 0.16, alpha: 1).cgColor,
                NSColor(srgbRed: 0.04, green: 0.06, blue: 0.08, alpha: 1).cgColor
            ] as CFArray
            let bgGrad = CGGradient(colorsSpace: CGColorSpace(name: CGColorSpace.sRGB), colors: bgColors, locations: [0, 1])!
            c.drawLinearGradient(bgGrad, start: CGPoint(x: 0.5, y: 0.05), end: CGPoint(x: 0.5, y: 0.95), options: [])
            c.restoreGState()

            // Subtle border
            c.setStrokeColor(NSColor.white.withAlphaComponent(0.10).cgColor)
            c.setLineWidth(0.02)
            c.addPath(squircle)
            c.strokePath()

            // Emerald "N" Monogram
            c.saveGState()
            let nClip = CGMutablePath()
            nClip.addRoundedRect(in: CGRect(x: 0.22, y: 0.22, width: 0.15, height: 0.56), cornerWidth: 0.06, cornerHeight: 0.06)
            nClip.addRoundedRect(in: CGRect(x: 0.63, y: 0.22, width: 0.15, height: 0.56), cornerWidth: 0.06, cornerHeight: 0.06)
            
            let diag = CGMutablePath()
            diag.move(to: CGPoint(x: 0.29, y: 0.28))
            diag.addLine(to: CGPoint(x: 0.71, y: 0.72))
            let strokedDiag = diag.copy(strokingWithWidth: 0.13, lineCap: .round, lineJoin: .round, miterLimit: 10)
            nClip.addPath(strokedDiag)
            
            c.addPath(nClip)
            c.clip()

            let monoColors = [cyan.cgColor, emerald.cgColor, deepEmerald.cgColor] as CFArray
            let monoGrad = CGGradient(colorsSpace: CGColorSpace(name: CGColorSpace.sRGB), colors: monoColors, locations: [0, 0.45, 1.0])!
            c.drawLinearGradient(monoGrad, start: CGPoint(x: 0.2, y: 0.18), end: CGPoint(x: 0.8, y: 0.82), options: [])
            c.restoreGState()
        }
    }

    static func mark(size: CGFloat, happy: Bool = false) -> NSImage {
        NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in draw(in: rect, happy: happy); return true }
    }

    static func menuIcon(updateAvailable: Bool = false) -> NSImage {
        let image = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { rect in
            draw(in: rect, monochrome: false)
            if updateAvailable {
                emerald.setFill()
                NSBezierPath(ovalIn: NSRect(x: 13, y: 13, width: 4, height: 4)).fill()
            }
            return true
        }
        image.isTemplate = false
        image.accessibilityDescription = updateAvailable ? "Nevra update available" : "Nevra"
        return image
    }
}
