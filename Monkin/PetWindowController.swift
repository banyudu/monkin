import AppKit

final class PetWindowController: NSWindowController {
    let petView: PetView
    private let sportsPropView: SportsPropView
    private let thoughtBubble: ThoughtBubbleView
    private let thoughtProvider: MonkinThoughtProvider = CodexThoughtProvider()
    private let screenTextReader = ScreenTextReader()
    private let screenWorldReader = ScreenWorldReader()
    private let waterPoolWindow = WaterPoolWindowController()
    private var thoughtTimer: Timer?
    private var roamTimer: Timer?
    private var actionTimer: Timer?
    private var ocrTimer: Timer?
    private var eatingTimer: Timer?
    private var worldTimer: Timer?
    private var storyTimer: Timer?
    private var roamDirection: CGFloat = 1
    private var roamTime: CGFloat = 0
    private var jumpTime: CGFloat = 0
    private var jumpDuration: CGFloat = 1.05
    private var jumpHeight: CGFloat = 70
    private var nextRoamEvent: CGFloat = 6
    private var motionIndex = 0
    private var roamTarget = NSPoint.zero
    private var hasRoamTarget = false
    private var eatingTarget: NSPoint?
    private var lastEatenText: String?
    private var lastEatenAt = Date.distantPast

    init() {
        petView = PetView(frame: NSRect(x: 294, y: 10, width: 128, height: 128))
        sportsPropView = SportsPropView(frame: NSRect(x: 0, y: 0, width: 440, height: 230))
        thoughtBubble = ThoughtBubbleView(frame: NSRect(x: 0, y: 116, width: 300, height: 110))
        let rootView = NSView(frame: NSRect(x: 0, y: 0, width: 440, height: 230))
        rootView.addSubview(thoughtBubble)
        rootView.addSubview(sportsPropView)
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
        petView.onMotionStyleChange = { [weak self] style in
            self?.sportsPropView.setStyle(style)
        }

        DispatchQueue.main.async { [weak self] in
            self?.speak()
            self?.scheduleNextThought()
            self?.scheduleRoaming()
            self?.scheduleRandomMotion()
            self?.scheduleScreenReading()
            self?.scheduleWorldReading()
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
            if let program = thought.motionProgram {
                self.petView.setMotionProgram(program)
            }
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
        nextRoamEvent = CGFloat.random(in: 4...9)
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

    private func scheduleScreenReading() {
        screenTextReader.requestScreenRecordingAccess()
        ocrTimer?.invalidate()
        ocrTimer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { [weak self] _ in
            self?.readScreen()
        }
        readScreen()
    }

    private func scheduleWorldReading() {
        screenWorldReader.requestAccessibilityAccess()
        worldTimer?.invalidate()
        worldTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            self?.readWorld()
        }
        readWorld()
    }

    private func readWorld() {
        screenWorldReader.read { [weak self] items in
            guard let self, self.eatingTarget == nil else { return }
            guard let target = items.first(where: { $0.isSemanticTarget && $0.label.count >= 2 &&
                !($0.label == self.lastEatenText && Date().timeIntervalSince(self.lastEatenAt) < 600) }) else { return }
            self.startEating(ScreenText(text: target.label, confidence: 1, screenRect: target.screenRect))
        }
    }

    private func readScreen() {
        screenTextReader.readMainDisplay { [weak self] items in
            guard let self else { return }
            let candidates = items.filter {
                $0.confidence >= 0.55 && $0.text.count >= 2 && $0.text.count <= 48 &&
                !($0.text == self.lastEatenText && Date().timeIntervalSince(self.lastEatenAt) < 600)
            }
            guard let target = candidates.min(by: { self.distance(to: $0.screenRect) < self.distance(to: $1.screenRect) }) else { return }
            self.startEating(target)
        }
    }

    private func distance(to rect: CGRect) -> CGFloat {
        guard let window else { return .greatestFiniteMagnitude }
        return hypot(rect.midX - window.frame.midX, rect.midY - window.frame.midY)
    }

    private func startEating(_ text: ScreenText) {
        guard let window, eatingTarget == nil else { return }
        lastEatenText = text.text
        lastEatenAt = Date()
        let visible = (window.screen ?? NSScreen.main)?.visibleFrame ?? .zero
        let desired = NSPoint(x: text.screenRect.midX - petView.frame.midX,
                              y: text.screenRect.midY - petView.frame.midY)
        let maxX = max(visible.minX, visible.maxX - window.frame.width)
        let maxY = max(visible.minY, visible.maxY - window.frame.height)
        eatingTarget = NSPoint(x: min(max(desired.x, visible.minX), maxX),
                               y: min(max(desired.y, visible.minY), maxY))
        petView.setMotionStyle("tiptoe")
        eatingTimer?.invalidate()
        eatingTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] timer in
            guard let self, let window = self.window, let target = self.eatingTarget else { timer.invalidate(); return }
            let current = window.frame.origin
            let dx = target.x - current.x
            let dy = target.y - current.y
            let distance = hypot(dx, dy)
            if distance < 5 {
                window.setFrameOrigin(target)
                self.eatingTarget = nil
                timer.invalidate()
                self.petView.setMotionStyle("celebrate")
                self.thoughtBubble.show(text: "nom nom…", for: 2.0)
                return
            }
            let step = min(7, distance)
            window.setFrameOrigin(NSPoint(x: current.x + dx / distance * step,
                                          y: current.y + dy / distance * step))
        }
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
        let style = MonkinMotion.randomExpressive()
        MonkinTelemetry.shared.record("motion.selected", attributes: [
            "style": style,
            "is_sport": String(MonkinMotion.sports.contains(style))
        ])
        if style == "escape" || style == "dive" {
            performStoryMotion(style)
            return
        }
        petView.setMotionStyle(style)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            guard let self, self.jumpTime <= 0 else { return }
            self.petView.setMotionStyle("idle")
        }
    }

    private func performStoryMotion(_ style: String) {
        guard let window, let screen = window.screen ?? NSScreen.main else { return }
        storyTimer?.invalidate()
        roamTimer?.invalidate()
        eatingTarget = nil
        petView.setMotionStyle(style)

        let origin = window.frame.origin
        let visible = screen.visibleFrame
        let direction: CGFloat = Bool.random() ? -1 : 1
        let destination: NSPoint
        if style == "escape" {
            destination = NSPoint(x: direction < 0 ? visible.minX - window.frame.width - 30 : visible.maxX + 30,
                                  y: origin.y)
        } else {
            waterPoolWindow.show(on: screen, centeredAt: origin.x + window.frame.width / 2)
            destination = NSPoint(x: origin.x, y: visible.minY + 42)
        }

        var elapsed: CGFloat = 0
        let duration: CGFloat = style == "escape" ? 1.35 : 1.15
        storyTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] timer in
            guard let self, let window = self.window else { timer.invalidate(); return }
            elapsed += 1.0 / 30.0
            let phase = min(1, elapsed / duration)
            let landingPhase = style == "dive" ? min(1, phase / 0.68) : phase
            let eased = landingPhase * landingPhase * (3 - 2 * landingPhase)
            let sinkPhase = style == "dive" ? max(0, (phase - 0.68) / 0.32) : 0
            let current = NSPoint(x: origin.x + (destination.x - origin.x) * eased,
                                  y: origin.y + (destination.y - origin.y) * eased - sinkPhase * (window.frame.height + 45))
            window.setFrameOrigin(current)
            if phase >= 1 {
                timer.invalidate()
                self.storyTimer = nil
                self.thoughtBubble.show(text: style == "escape" ? "bye!" : "splash!", for: 1.8)
                if style == "dive" { self.waterPoolWindow.hide() }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
                    guard let self, let window = self.window else { return }
                    window.setFrameOrigin(origin)
                    self.petView.setMotionStyle("celebrate")
                    self.startRoaming()
                }
            }
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
        } else if roamTime > nextRoamEvent {
            roamTime = 0
            nextRoamEvent = CGFloat.random(in: 4...10)
            roamTarget = NSPoint(x: CGFloat.random(in: minX...maxX),
                                 y: CGFloat.random(in: minY...maxY))
            hasRoamTarget = true
            if Bool.random() {
                jumpDuration = CGFloat.random(in: 0.8...1.25)
                jumpTime = jumpDuration
                jumpHeight = CGFloat.random(in: 45...90)
                petView.setMotionStyle("jump")
            } else {
                petView.setMotionStyle("wriggle")
            }
        }

        let speed: CGFloat = jumpTime > 0 ? 5.5 : 1.25
        let dx = roamTarget.x - frame.origin.x
        let dy = roamTarget.y - frame.origin.y
        let distance = max(1, hypot(dx, dy))
        let nextX = frame.origin.x + dx / distance * min(speed, abs(dx) + abs(dy) > 0 ? speed : 0)
        let nextY = frame.origin.y + dy / distance * min(speed, abs(dx) + abs(dy) > 0 ? speed : 0)
        let jumpProgress = jumpTime > 0 ? (jumpDuration - jumpTime) / jumpDuration : 0
        let jumpArc = sin(jumpProgress * .pi) * jumpHeight
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
        ocrTimer?.invalidate()
        eatingTimer?.invalidate()
        worldTimer?.invalidate()
        storyTimer?.invalidate()
        waterPoolWindow.hide()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func initialOrigin(for size: NSSize) -> NSPoint {
        guard let screen = NSScreen.main else { return .zero }
        let visibleFrame = screen.visibleFrame
        let minX = visibleFrame.minX + 12
        let maxX = visibleFrame.maxX - size.width - 12
        let minY = visibleFrame.minY + 18
        let maxY = max(minY, visibleFrame.maxY - size.height - 18)
        return NSPoint(x: CGFloat.random(in: minX...maxX),
                       y: CGFloat.random(in: minY...maxY))
    }
}

final class PetWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
