import AppKit

final class ThoughtBubbleView: NSView {
    var onTap: (() -> Void)?
    private let textField = NSTextField(labelWithString: "")

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        alphaValue = 0
        isHidden = true

        textField.font = .systemFont(ofSize: 14.5, weight: .medium)
        textField.textColor = NSColor(calibratedWhite: 0.16, alpha: 1)
        textField.alignment = .left
        textField.lineBreakMode = .byCharWrapping
        textField.maximumNumberOfLines = 3
        textField.drawsBackground = false
        textField.isBordered = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.cell?.wraps = true
        textField.cell?.isScrollable = false
        textField.cell?.truncatesLastVisibleLine = true
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(textField)

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 38),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -64),
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 39),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -21)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.18)
        shadow.shadowBlurRadius = 9
        shadow.shadowOffset = NSSize(width: 0, height: -2)
        shadow.set()

        let gradient = NSGradient(colors: [
            NSColor.white.withAlphaComponent(0.86),
            NSColor(calibratedRed: 0.96, green: 0.97, blue: 0.99, alpha: 0.76)
        ])

        let card = NSBezierPath(roundedRect: NSRect(x: 8, y: 22, width: 228, height: 68),
                                xRadius: 30, yRadius: 30)
        NSColor.white.withAlphaComponent(0.80).setFill()
        card.fill()
        gradient?.draw(in: card, angle: -90)

        NSShadow().set()
        NSColor(calibratedRed: 0.80, green: 0.83, blue: 0.88, alpha: 0.52).setStroke()
        card.lineWidth = 1
        card.stroke()

        // Small-to-large beads lead the thought card back toward Monkin.
        let beads = [
            NSRect(x: 269, y: 8, width: 8, height: 8),
            NSRect(x: 253, y: 5, width: 12, height: 12),
            NSRect(x: 231, y: 0, width: 17, height: 17)
        ]
        for rect in beads {
            let bead = NSBezierPath(ovalIn: rect)
            NSColor.white.withAlphaComponent(0.80).setFill()
            bead.fill()
            NSColor(calibratedRed: 0.80, green: 0.83, blue: 0.88, alpha: 0.52).setStroke()
            bead.lineWidth = 1
            bead.stroke()
        }

    }

    override func mouseDown(with event: NSEvent) {
        onTap?()
    }

    func show(text: String, for duration: TimeInterval) {
        let compactText = text.replacingOccurrences(of: "\n", with: " ")
        let fontSize: CGFloat = compactText.count > 38 ? 10.5 : (compactText.count > 28 ? 12 : 13.5)
        textField.stringValue = compactText
        textField.font = .systemFont(ofSize: fontSize, weight: .medium)
        isHidden = false
        alphaValue = 0
        needsDisplay = true

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            animator().alphaValue = 1
        }

        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hide), object: nil)
        perform(#selector(hide), with: nil, afterDelay: duration)
    }

    @objc private func hide() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.35
            animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            self?.isHidden = true
        })
    }
}
