import AppKit

final class WaterPoolWindowController: NSWindowController {
    private let poolView = WaterPoolView(frame: .zero)

    init() {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 360, height: 82),
                              styleMask: [.borderless],
                              backing: .buffered,
                              defer: false)
        window.contentView = poolView
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.orderOut(nil)
        super.init(window: window)
    }

    func show(on screen: NSScreen, centeredAt centerX: CGFloat) {
        guard let window else { return }
        let visible = screen.visibleFrame
        window.setFrameOrigin(NSPoint(x: centerX - window.frame.width / 2, y: visible.minY))
        poolView.reset()
        window.orderFrontRegardless()
    }

    func hide() {
        window?.orderOut(nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private final class WaterPoolView: NSView {
    private var phase: CGFloat = 0
    private var timer: Timer?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 12.0, repeats: true) { [weak self] _ in
            self?.phase += 0.16
            self?.needsDisplay = true
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func reset() {
        phase = 0
        needsDisplay = true
    }

    deinit { timer?.invalidate() }

    override func draw(_ dirtyRect: NSRect) {
        let pool = NSBezierPath(roundedRect: NSRect(x: 4, y: 8, width: bounds.width - 8, height: 42), xRadius: 21, yRadius: 21)
        NSColor.systemBlue.withAlphaComponent(0.34).setFill()
        pool.fill()
        NSColor.systemTeal.withAlphaComponent(0.8).setStroke()
        pool.lineWidth = 3
        pool.stroke()

        for index in 0..<5 {
            let x = 38 + CGFloat(index) * 70
            let wave = NSBezierPath()
            wave.move(to: NSPoint(x: x, y: 31))
            wave.curve(to: NSPoint(x: x + 34, y: 31),
                       controlPoint1: NSPoint(x: x + 8, y: 23 + sin(phase + CGFloat(index)) * 3),
                       controlPoint2: NSPoint(x: x + 25, y: 39 + sin(phase + CGFloat(index)) * 3))
            NSColor.white.withAlphaComponent(0.6).setStroke()
            wave.lineWidth = 2
            wave.stroke()
        }
    }
}
