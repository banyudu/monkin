import AppKit

final class PetWindowController: NSWindowController {
    let petView: PetView

    init() {
        petView = PetView(frame: NSRect(x: 0, y: 0, width: 150, height: 125))
        let window = PetWindow(contentRect: petView.frame,
                               styleMask: [.borderless],
                               backing: .buffered,
                               defer: false)
        window.contentView = petView
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isMovableByWindowBackground = true
        window.title = "Monkin"
        window.setFrameOrigin(Self.initialOrigin(for: petView.frame.size))
        super.init(window: window)
    }

    func setFigure(_ spec: MonkinFigureSpec) {
        petView.setFigure(spec)
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
