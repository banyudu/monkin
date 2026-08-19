import AppKit

final class ThoughtBubbleView: NSView {
    var onTap: (() -> Void)?
    private let textField = NSTextField(labelWithString: "")

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        alphaValue = 0
        isHidden = true

        textField.font = .systemFont(ofSize: 15, weight: .medium)
        textField.textColor = NSColor(calibratedWhite: 0.12, alpha: 1)
        textField.alignment = .left
        textField.lineBreakMode = .byWordWrapping
        textField.maximumNumberOfLines = 3
        textField.drawsBackground = false
        textField.isBordered = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 13),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -13)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        let bubbleRect = NSRect(x: 0, y: 10, width: bounds.width - 8, height: bounds.height - 10)
        let bubble = NSBezierPath(roundedRect: bubbleRect, xRadius: 18, yRadius: 18)
        NSColor(calibratedWhite: 0.98, alpha: 0.96).setFill()
        bubble.fill()

        let tail = NSBezierPath()
        tail.move(to: NSPoint(x: bounds.width - 34, y: 13))
        tail.line(to: NSPoint(x: bounds.width - 7, y: 0))
        tail.line(to: NSPoint(x: bounds.width - 51, y: 13))
        tail.close()
        NSColor(calibratedWhite: 0.98, alpha: 0.96).setFill()
        tail.fill()
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
