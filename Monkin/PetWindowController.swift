import AppKit

final class PetWindowController: NSWindowController {
    let petView: PetView
    private let thoughtBubble: ThoughtBubbleView
    private let thoughtProvider: MonkinThoughtProvider = CodexThoughtProvider()
    private var thoughtTimer: Timer?
    private var roamTimer: Timer?
    private var actionTimer: Timer?
    private var roamDirection: CGFloat = 1
    private var roamTime: CGFloat = 0
    private var jumpTime: CGFloat = 0
    private var motionIndex = 0
    private var roamTarget = NSPoint.zero
    private var hasRoamTarget = false

    init() {
        petView = PetView(frame: NSRect(x: 270, y: 10, width: 152, height: 152))
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
            self?.scheduleRandomMotion()
        }
    }

    func setFigure(_ spec: MonkinFigureSpec) {
        petView.setFigure(spec)
    }

    private func speak() {
        thoughtProvider.nextThought { [weak self] thought in
            guard let self, let thought else { return }
            self.petView.setFigure(thought.figure)
            self.petView.setMotionStyle(thought.motionStyle)
            self.thoughtBubble.show(text: thought.text, for: thought.visibleDuration)
        }
    }

    private func scheduleNextThought() {
        thoughtTimer?.invalidate()
        let interval = TimeInterval.random(in: 45...90)
        thoughtTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            guard let self else { return }
            self.speak()
            self.scheduleNextThought()
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
        hasRoamTarget = false
        roamTimer?.invalidate()
        roamTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            self?.advanceRoaming()
        }
    }

    func stopRoaming() {
        roamTimer?.invalidate()
        roamTimer = nil
        actionTimer?.invalidate()
        actionTimer = nil
        petView.setMotionStyle("idle")
    }

    private func scheduleRandomMotion() {
        actionTimer?.invalidate()
        actionTimer = Timer.scheduledTimer(withTimeInterval: 6, repeats: false) { [weak self] _ in
            self?.performNextMotion()
            self?.scheduleRandomMotion()
        }
    }

    private func performNextMotion() {
        guard jumpTime <= 0 else { return }
        let styles = MonkinMotion.expressive
        motionIndex = (motionIndex + 1) % styles.count
        petView.setMotionStyle(styles[motionIndex])
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            guard let self, self.jumpTime <= 0 else { return }
            self.petView.setMotionStyle("wriggle")
        }
    }

    private func advanceRoaming() {
        guard let window, let screen = window.screen ?? NSScreen.main else { return }
        roamTime += 1.0 / 30.0
        let visible = screen.visibleFrame
        let frame = window.frame
        let minX = visible.minX + 12
        let maxX = visible.maxX - frame.width - 12
        let minY = visible.minY + 18
        let maxY = max(minY, visible.maxY - frame.height - 18)

        if !hasRoamTarget {
            roamTarget = NSPoint(x: CGFloat.random(in: minX...maxX),
                                 y: CGFloat.random(in: minY...maxY))
            hasRoamTarget = true
        }

        if jumpTime > 0 {
            jumpTime -= 1.0 / 30.0
            petView.setMotionStyle("jump")
        } else if roamTime > 4.5 {
            roamTime = 0
            jumpTime = 1.05
            roamTarget = NSPoint(x: CGFloat.random(in: minX...maxX),
                                 y: CGFloat.random(in: minY...maxY))
            petView.setMotionStyle("jump")
        }

        let speed: CGFloat = jumpTime > 0 ? 5.5 : 1.25
        let dx = roamTarget.x - frame.origin.x
        let dy = roamTarget.y - frame.origin.y
        let distance = max(1, hypot(dx, dy))
        let nextX = frame.origin.x + dx / distance * min(speed, abs(dx) + abs(dy) > 0 ? speed : 0)
        let nextY = frame.origin.y + dy / distance * min(speed, abs(dx) + abs(dy) > 0 ? speed : 0)
        let jumpProgress = jumpTime > 0 ? (1.05 - jumpTime) / 1.05 : 0
        let jumpArc = sin(jumpProgress * .pi) * 92
        let clampedX = min(max(nextX, minX), maxX)
        let clampedY = min(max(nextY + jumpArc, minY), maxY)
        window.setFrameOrigin(NSPoint(x: clampedX, y: clampedY))

        if distance < 8 && jumpTime <= 0 {
            hasRoamTarget = false
        }
    }

    deinit {
        thoughtTimer?.invalidate()
        roamTimer?.invalidate()
        actionTimer?.invalidate()
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
