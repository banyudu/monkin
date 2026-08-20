import AppKit
import ScreenSaver

/// The actual macOS Screen Saver host. This target is packaged as a `.saver`
/// bundle and is therefore selectable in System Settings > Screen Saver.
@objc(MonkinScreenSaverView)
final class MonkinScreenSaverView: ScreenSaverView {
    private let petView = PetView(frame: NSRect(x: 0, y: 0, width: 220, height: 220))
    private let sportsPropView = SportsPropView(frame: .zero)
    private var actionTimer: Timer?
    private var propTimer: Timer?

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        animationTimeInterval = 1.0 / 30.0
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor

        addSubview(sportsPropView)
        addSubview(petView)
        petView.onMotionStyleChange = { [weak self] style in
            self?.sportsPropView.setStyle(style)
        }
        scheduleNextAction()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func startAnimation() {
        super.startAnimation()
        scheduleNextAction()
    }

    override func stopAnimation() {
        super.stopAnimation()
        actionTimer?.invalidate()
        propTimer?.invalidate()
        actionTimer = nil
        propTimer = nil
    }

    override func animateOneFrame() {
        // PetView owns its pose timer; this callback keeps the Screen Saver
        // host's lifecycle connected to AppKit's animation scheduler.
        needsDisplay = true
    }

    override func layout() {
        super.layout()
        let size = min(bounds.width, bounds.height) * 0.32
        let petSize = max(128, min(260, size))
        let petRect = NSRect(x: bounds.midX - petSize / 2,
                             y: bounds.midY - petSize / 2,
                             width: petSize,
                             height: petSize)
        petView.frame = petRect
        sportsPropView.frame = NSRect(x: bounds.midX - 220,
                                      y: petRect.minY - 18,
                                      width: 440,
                                      height: 230)
    }

    private func scheduleNextAction() {
        actionTimer?.invalidate()
        actionTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval.random(in: 4...9),
                                           repeats: false) { [weak self] _ in
            guard let self else { return }
            let style = MonkinMotion.randomExpressive()
            self.petView.setMotionStyle(style)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                self?.petView.setMotionStyle("idle")
            }
            self.scheduleNextAction()
        }
    }
}
