import AppKit

final class PetView: NSView {
    private let furColor = NSColor(calibratedRed: 0.58, green: 0.30, blue: 0.13, alpha: 1)
    private let bellyColor = NSColor(calibratedRed: 0.94, green: 0.72, blue: 0.43, alpha: 1)
    private var blinkTimer: Timer?
    private var isBlinking = false

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 3.8, repeats: true) { [weak self] _ in
            self?.blink()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        blinkTimer?.invalidate()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        drawTail()
        drawBody()
        drawEars()
        drawHead()
        drawFace()
        drawFeet()
    }

    private func drawBody() {
        let body = NSBezierPath(ovalIn: NSRect(x: 58, y: 45, width: 104, height: 130))
        furColor.setFill()
        body.fill()

        let belly = NSBezierPath(ovalIn: NSRect(x: 79, y: 54, width: 62, height: 84))
        bellyColor.setFill()
        belly.fill()
    }

    private func drawHead() {
        let head = NSBezierPath(ovalIn: NSRect(x: 38, y: 125, width: 144, height: 105))
        furColor.setFill()
        head.fill()

        let muzzle = NSBezierPath(ovalIn: NSRect(x: 67, y: 137, width: 86, height: 53))
        bellyColor.setFill()
        muzzle.fill()
    }

    private func drawEars() {
        for x in [43.0, 137.0] {
            let ear = NSBezierPath(ovalIn: NSRect(x: x, y: 188, width: 40, height: 40))
            furColor.setFill()
            ear.fill()
            let inner = NSBezierPath(ovalIn: NSRect(x: x + 8, y: 196, width: 24, height: 24))
            NSColor.systemPink.withAlphaComponent(0.7).setFill()
            inner.fill()
        }
    }

    private func drawFace() {
        let eyeY: CGFloat = 179
        for x in [77.0, 130.0] {
            let eye = NSBezierPath(ovalIn: NSRect(x: x, y: eyeY, width: 12, height: isBlinking ? 2 : 17))
            NSColor(white: 0.08, alpha: 1).setFill()
            eye.fill()
        }

        let nose = NSBezierPath(ovalIn: NSRect(x: 104, y: 153, width: 14, height: 10))
        NSColor(calibratedRed: 0.25, green: 0.08, blue: 0.06, alpha: 1).setFill()
        nose.fill()

        let smile = NSBezierPath()
        smile.move(to: NSPoint(x: 111, y: 153))
        smile.curve(to: NSPoint(x: 101, y: 145), controlPoint1: NSPoint(x: 109, y: 148), controlPoint2: NSPoint(x: 104, y: 145))
        smile.move(to: NSPoint(x: 111, y: 153))
        smile.curve(to: NSPoint(x: 121, y: 145), controlPoint1: NSPoint(x: 118, y: 148), controlPoint2: NSPoint(x: 119, y: 145))
        smile.lineWidth = 2
        NSColor(calibratedWhite: 0.2, alpha: 1).setStroke()
        smile.stroke()
    }

    private func drawTail() {
        let tail = NSBezierPath()
        tail.move(to: NSPoint(x: 144, y: 73))
        tail.curve(to: NSPoint(x: 198, y: 116), controlPoint1: NSPoint(x: 193, y: 35), controlPoint2: NSPoint(x: 217, y: 95))
        tail.lineWidth = 15
        tail.lineCapStyle = .round
        furColor.setStroke()
        tail.stroke()
    }

    private func drawFeet() {
        for x in [66.0, 125.0] {
            let foot = NSBezierPath(ovalIn: NSRect(x: x, y: 31, width: 42, height: 27))
            furColor.setFill()
            foot.fill()
        }
    }

    private func blink() {
        isBlinking = true
        needsDisplay = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) { [weak self] in
            self?.isBlinking = false
            self?.needsDisplay = true
        }
    }
}
