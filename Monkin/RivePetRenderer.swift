import AppKit
import RiveRuntime

/// Desktop-only animation adapter. PetView owns input, hit testing, and the
/// AppKit window lifecycle; this type owns the Rive view and runtime inputs.
final class RivePetRenderer: NSView {
    /// The generated asset exposes a trigger for every validated expressive
    /// Monkin motion. Several aliases share an animation today, but no raw or
    /// unsupported input is passed through to the Rive runtime.
    private static let motionTriggers = Set(MonkinMotion.expressive)

    private let viewModel: RiveViewModel
    private let riveView: RiveView
    private(set) var figure = MonkinFigureSpec.default

    static func make(frame: NSRect) -> RivePetRenderer? {
        // Do not substitute a third-party character for Monkin. This path is
        // enabled only once a Monkin-owned asset is added to the app bundle.
        guard Bundle.main.url(forResource: "monkin-monkey", withExtension: "riv") != nil else {
            return nil
        }
        return RivePetRenderer(frame: frame)
    }

    override init(frame: NSRect) {
        viewModel = RiveViewModel(
            fileName: "monkin-monkey",
            stateMachineName: "Monkin Motion",
            fit: .contain,
            alignment: .center,
            autoPlay: true
        )
        riveView = viewModel.createRiveView()
        super.init(frame: frame)
        wantsLayer = true
        riveView.frame = bounds
        riveView.autoresizingMask = [.width, .height]
        addSubview(riveView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setMotion(_ style: String) {
        guard Self.motionTriggers.contains(style) else {
            viewModel.play()
            return
        }
        viewModel.triggerInput(style)
    }

    // Preserve PetView's existing click-to-speak behavior. This renderer is
    // presentation-only; later interactive Rive listeners can opt in here.
    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }

    /// The sample asset has no dynamic inputs yet. Retaining this API makes
    /// figure customization an intentional, renderer-local extension point.
    func setFigure(_ figure: MonkinFigureSpec) {
        self.figure = figure
    }
}
