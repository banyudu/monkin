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
        textField.lineBreakMode = .byWordWrapping
        textField.maximumNumberOfLines = 3
        textField.drawsBackground = false
        textField.isBordered = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        let bubbleRect = NSRect(x: 2, y: 12, width: bounds.width - 12, height: bounds.height - 14)
        let bubble = NSBezierPath(roundedRect: bubbleRect, xRadius: 20, yRadius: 20)

        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.18)
        shadow.shadowBlurRadius = 12
        shadow.shadowOffset = NSSize(width: 0, height: -4)
        shadow.set()
        NSColor.white.withAlphaComponent(0.98).setFill()
        bubble.fill()
        NSShadow().set()

        let gradient = NSGradient(colors: [
            NSColor.white.withAlphaComponent(0.99),
            NSColor(calibratedRed: 0.96, green: 0.97, blue: 0.99, alpha: 0.98)
        ])
        gradient?.draw(in: bubble, angle: -90)
        NSColor(calibratedRed: 0.80, green: 0.83, blue: 0.88, alpha: 0.72).setStroke()
        bubble.lineWidth = 1
        bubble.stroke()

        // A tiny accent bead gives the otherwise quiet bubble a Monkin signature.
        NSColor(calibratedRed: 0.29, green: 0.47, blue: 0.45, alpha: 0.9).setFill()
        NSBezierPath(ovalIn: NSRect(x: 14, y: bubbleRect.maxY - 23, width: 6, height: 6)).fill()

        let tail = NSBezierPath()
        tail.move(to: NSPoint(x: bounds.width - 42, y: 14))
        tail.curve(to: NSPoint(x: bounds.width - 8, y: 1),
                   controlPoint1: NSPoint(x: bounds.width - 28, y: 12),
                   controlPoint2: NSPoint(x: bounds.width - 15, y: 3))
        tail.curve(to: NSPoint(x: bounds.width - 57, y: 14),
                   controlPoint1: NSPoint(x: bounds.width - 37, y: 5),
                   controlPoint2: NSPoint(x: bounds.width - 48, y: 12))
        tail.close()
        NSColor.white.withAlphaComponent(0.98).setFill()
        tail.fill()
        NSColor(calibratedRed: 0.80, green: 0.83, blue: 0.88, alpha: 0.72).setStroke()
        tail.lineWidth = 1
        tail.stroke()
    }

    override func mouseDown(with event: NSEvent) {
        onTap?()
    }

    func show(text: String, for duration: TimeInterval) {
        textField.stringValue = text
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
