import AppKit

final class PetWindowController: NSWindowController {
    let petView: PetView
    private let thoughtBubble: ThoughtBubbleView
    private let thoughtProvider: MonkinThoughtProvider = LocalThoughtProvider()
    private var thoughtTimer: Timer?
    private var roamTimer: Timer?
    private var roamDirection: CGFloat = 1
    private var roamTime: CGFloat = 0
    private var jumpTime: CGFloat = 0

    init() {
        petView = PetView(frame: NSRect(x: 230, y: 10, width: 190, height: 190))
        thoughtBubble = ThoughtBubbleView(frame: NSRect(x: 0, y: 126, width: 270, height: 90))
        let rootView = NSView(frame: NSRect(x: 0, y: 0, width: 440, height: 230))
        rootView.addSubview(thoughtBubble)
        rootView.addSubview(petView)

        let window = PetWindow(contentRect: rootView.frame,
                               styleMask: [.borderless],
                               backing: .buffered,
                               defer: false)
        window.contentView = rootView
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isMovableByWindowBackground = true
        window.title = "Monkin"
        window.setFrameOrigin(Self.initialOrigin(for: rootView.frame.size))
        super.init(window: window)

        petView.onTap = { [weak self] in self?.speak() }
        thoughtBubble.onTap = { [weak self] in self?.speak() }

        DispatchQueue.main.async { [weak self] in
            self?.speak()
            self?.scheduleNextThought()
            self?.scheduleRoaming()
        }
    }

    func setFigure(_ spec: MonkinFigureSpec) {
        petView.setFigure(spec)
    }

    private func speak() {
        guard let thought = thoughtProvider.nextThought() else { return }
        petView.setFigure(thought.figure)
        thoughtBubble.show(text: thought.text, for: thought.visibleDuration)
    }

    private func scheduleNextThought() {
        thoughtTimer?.invalidate()
        let interval = TimeInterval.random(in: 45...90)
        thoughtTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.speak()
            self?.scheduleNextThought()
        }
    }

    /// Starts the first gentle desktop stroll after launch.
    private func scheduleRoaming() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) { [weak self] in
            self?.startRoaming()
        }
    }

    /// Moves the complete transparent pet window along the bottom of its screen.
    /// This is intentionally local and deterministic; a future LLM behavior layer
    /// can decide when to call it without driving animation frames itself.
    func startRoaming() {
        petView.setMotionStyle("wriggle")
        roamTime = 0
        jumpTime = 0
        roamTimer?.invalidate()
        roamTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            self?.advanceRoaming()
        }
    }

    func stopRoaming() {
        roamTimer?.invalidate()
        roamTimer = nil
        petView.setMotionStyle("idle")
    }

    private func advanceRoaming() {
        guard let window, let screen = window.screen ?? NSScreen.main else { return }
        roamTime += 1.0 / 30.0
        if jumpTime > 0 {
            jumpTime -= 1.0 / 30.0
            petView.setMotionStyle("jump")
        } else if roamTime > 4.5 {
            roamTime = 0
            jumpTime = 1.05
            petView.setMotionStyle("jump")
        } else {
            petView.setMotionStyle("wriggle")
        }
        let visible = screen.visibleFrame
        let frame = window.frame
        // A jump carries Monkin farther than its tiny wriggle steps.
        let step: CGFloat = (jumpTime > 0 ? 5.5 : 1.25) * roamDirection
        var nextX = frame.origin.x + step
        let jumpProgress = jumpTime > 0 ? (1.05 - jumpTime) / 1.05 : 0
        let jumpArc = sin(jumpProgress * .pi) * 92
        let minX = visible.minX + 12
        let maxX = visible.maxX - frame.width - 12

        if nextX <= minX {
            nextX = minX
            roamDirection = 1
        } else if nextX >= maxX {
            nextX = maxX
            roamDirection = -1
        }

        window.setFrameOrigin(NSPoint(x: nextX, y: visible.minY + 18 + jumpArc))
    }

    deinit {
        thoughtTimer?.invalidate()
        roamTimer?.invalidate()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func initialOrigin(for size: NSSize) -> NSPoint {
        guard let screen = NSScreen.main else { return .zero }
        let visibleFrame = screen.visibleFrame
        return NSPoint(x: visibleFrame.maxX - size.width - 32,
                       y: visibleFrame.minY + 24)
    }
}

final class PetWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
