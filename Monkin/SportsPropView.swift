import AppKit

/// Lightweight animated props drawn behind Monkin. Props are intentionally
/// procedural so they stay crisp at any display scale and need no assets.
final class SportsPropView: NSView {
    private(set) var style = "idle" {
        didSet { needsDisplay = true }
    }
    private var phase: CGFloat = 0
    private var timer: Timer?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 12.0, repeats: true) { [weak self] _ in
            self?.phase += 0.18
            self?.needsDisplay = true
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit { timer?.invalidate() }

    func setStyle(_ style: String) {
        self.style = style
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        switch style {
        case "soccer": drawSoccer()
        case "basketball": drawBasketball()
        case "tennis": drawTennis()
        case "swim": drawWater()
        case "skate": drawSkateboard()
        case "weightlifting": drawWeights()
        case "jump-rope": drawJumpRope()
        default: break
        }
    }

    private func drawSoccer() {
        let x = 255 + sin(phase * 1.6) * 65
        let y = 33 + abs(sin(phase * 1.6)) * 45
        drawBall(center: NSPoint(x: x, y: y), radius: 13, color: .white, detail: .black)
        let goal = NSBezierPath(rect: NSRect(x: 22, y: 20, width: 70, height: 58))
        NSColor.white.withAlphaComponent(0.72).setStroke()
        goal.lineWidth = 3
        goal.stroke()
    }

    private func drawBasketball() {
        let x = 265 + sin(phase * 1.8) * 48
        let y = 35 + abs(sin(phase * 1.8)) * 62
        drawBall(center: NSPoint(x: x, y: y), radius: 14, color: NSColor(calibratedRed: 0.93, green: 0.35, blue: 0.08, alpha: 1), detail: .black)
        NSColor(calibratedRed: 0.92, green: 0.28, blue: 0.10, alpha: 0.9).setStroke()
        let rim = NSBezierPath(ovalIn: NSRect(x: 30, y: 112, width: 42, height: 10))
        rim.lineWidth = 4
        rim.stroke()
        NSColor.white.withAlphaComponent(0.65).setStroke()
        NSBezierPath(rect: NSRect(x: 35, y: 118, width: 32, height: 42)).stroke()
    }

    private func drawTennis() {
        let x = 250 + sin(phase * 2.0) * 72
        let y = 85 + sin(phase * 2.0) * 40
        drawBall(center: NSPoint(x: x, y: y), radius: 8, color: NSColor.systemYellow, detail: .white)
        NSColor.white.withAlphaComponent(0.52).setStroke()
        let racket = NSBezierPath(ovalIn: NSRect(x: 360, y: 115, width: 36, height: 50))
        racket.lineWidth = 4
        racket.stroke()
        NSBezierPath().stroke()
        let handle = NSBezierPath()
        handle.move(to: NSPoint(x: 378, y: 115)); handle.line(to: NSPoint(x: 370, y: 83))
        handle.lineWidth = 5; handle.stroke()
    }

    private func drawWater() {
        let water = NSBezierPath()
        water.move(to: NSPoint(x: 210, y: 16))
        water.curve(to: NSPoint(x: 438, y: 16), controlPoint1: NSPoint(x: 265, y: 28), controlPoint2: NSPoint(x: 340, y: 5))
        water.line(to: NSPoint(x: 438, y: 0)); water.line(to: NSPoint(x: 210, y: 0)); water.close()
        NSColor.systemBlue.withAlphaComponent(0.35).setFill(); water.fill()
        NSColor.systemTeal.withAlphaComponent(0.75).setStroke()
        for offset in stride(from: CGFloat(0), through: CGFloat(180), by: CGFloat(28)) {
            let wave = NSBezierPath()
            wave.move(to: NSPoint(x: 220 + offset, y: 20))
            wave.curve(to: NSPoint(x: 246 + offset, y: 20), controlPoint1: NSPoint(x: 226 + offset, y: 12 + sin(phase) * 3), controlPoint2: NSPoint(x: 239 + offset, y: 28 + sin(phase) * 3))
            wave.lineWidth = 2; wave.stroke()
        }
    }

    private func drawSkateboard() {
        let board = NSBezierPath(roundedRect: NSRect(x: 285, y: 24, width: 105, height: 10), xRadius: 5, yRadius: 5)
        NSColor.systemPink.withAlphaComponent(0.88).setFill(); board.fill()
        NSColor(calibratedWhite: 0.12, alpha: 0.9).setFill()
        for x in [302.0, 374.0] { NSBezierPath(ovalIn: NSRect(x: x, y: 16, width: 13, height: 13)).fill() }
    }

    private func drawWeights() {
        let lift = abs(sin(phase * 1.8)) * 28
        let bar = NSBezierPath()
        bar.move(to: NSPoint(x: 250, y: 150 + lift)); bar.line(to: NSPoint(x: 410, y: 150 + lift))
        NSColor(calibratedWhite: 0.75, alpha: 0.9).setStroke(); bar.lineWidth = 6; bar.stroke()
        NSColor.systemPurple.setFill()
        for x in [250.0, 266.0, 394.0, 410.0] { NSBezierPath(roundedRect: NSRect(x: x, y: 133 + lift, width: 12, height: 35), xRadius: 4, yRadius: 4).fill() }
    }

    private func drawJumpRope() {
        let rope = NSBezierPath()
        let arc = abs(sin(phase * 1.8))
        rope.move(to: NSPoint(x: 265, y: 50))
        rope.curve(to: NSPoint(x: 420, y: 50), controlPoint1: NSPoint(x: 285, y: 50 + arc * 105), controlPoint2: NSPoint(x: 400, y: 50 + arc * 105))
        NSColor.systemOrange.withAlphaComponent(0.9).setStroke(); rope.lineWidth = 3; rope.stroke()
    }

    private enum BallDetail { case black, white }

    private func drawBall(center: NSPoint, radius: CGFloat, color: NSColor, detail: BallDetail) {
        color.setFill(); NSBezierPath(ovalIn: NSRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)).fill()
        detail == .black ? NSColor.black.withAlphaComponent(0.55).setStroke() : NSColor.white.withAlphaComponent(0.8).setStroke()
        let detailPath = NSBezierPath(ovalIn: NSRect(x: center.x - radius * 0.45, y: center.y - radius * 0.45, width: radius * 0.9, height: radius * 0.9))
        detailPath.lineWidth = 2; detailPath.stroke()
    }
}
