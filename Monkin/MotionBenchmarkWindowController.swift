import AppKit

final class MotionBenchmarkWindowController: NSWindowController {
    private let cases: [MotionBenchmarkCase]
    private var index = 0
    private var elapsed = 0.0
    private var timer: Timer?
    private let leftPreview: PetView
    private let rightPreview: PetView
    private let caseLabel = NSTextField(labelWithString: "")
    private let reasonPopup = NSPopUpButton()

    init() {
        cases = MotionBenchmarkStore.shared.loadOrGenerate()
        leftPreview = PetView(frame: NSRect(x: 0, y: 0, width: 240, height: 240))
        rightPreview = PetView(frame: NSRect(x: 0, y: 0, width: 240, height: 240))

        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 900, height: 650),
                              styleMask: [.titled, .closable, .resizable],
                              backing: .buffered,
                              defer: false)
        window.title = "Monkin Motion Benchmark"
        window.center()
        window.isReleasedWhenClosed = false
        super.init(window: window)

        leftPreview.prepareForBenchmark()
        rightPreview.prepareForBenchmark()
        buildUI()
        showNextUnlabeledCase()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            self?.advancePreview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        timer?.invalidate()
    }

    private func buildUI() {
        guard let contentView = window?.contentView else { return }
        let title = NSTextField(labelWithString: "Choose the better motion. The candidate order is randomized.")
        title.font = .systemFont(ofSize: 16, weight: .medium)
        title.alignment = .center

        caseLabel.alignment = .center
        caseLabel.textColor = .secondaryLabelColor

        let cards = NSStackView(views: [previewCard(title: "Left", preview: leftPreview),
                                        previewCard(title: "Right", preview: rightPreview)])
        cards.orientation = .horizontal
        cards.distribution = .fillEqually
        cards.spacing = 24

        reasonPopup.addItems(withTitles: ["Reason (optional)", "timing", "contact", "balance", "follow-through", "readability", "transition", "visual artifact"])

        let controls = NSStackView(views: [
            actionButton("Left is better", action: #selector(selectLeft)),
            actionButton("Right is better", action: #selector(selectRight)),
            actionButton("Tie", action: #selector(selectTie)),
            actionButton("Both bad", action: #selector(selectBothBad)),
            reasonPopup,
            actionButton("Skip", action: #selector(skipCase))
        ])
        controls.orientation = .horizontal
        controls.alignment = .centerY
        controls.spacing = 8

        let stack = NSStackView(views: [title, caseLabel, cards, controls])
        stack.orientation = .vertical
        stack.alignment = .width
        stack.spacing = 14
        stack.edgeInsets = NSEdgeInsets(top: 20, left: 24, bottom: 20, right: 24)
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cards.heightAnchor.constraint(equalToConstant: 470),
            leftPreview.widthAnchor.constraint(equalToConstant: 240),
            leftPreview.heightAnchor.constraint(equalToConstant: 240),
            rightPreview.widthAnchor.constraint(equalToConstant: 240),
            rightPreview.heightAnchor.constraint(equalToConstant: 240)
        ])
    }

    private func previewCard(title: String, preview: PetView) -> NSView {
        let label = NSTextField(labelWithString: title)
        label.alignment = .center
        label.font = .systemFont(ofSize: 20, weight: .semibold)

        let card = NSView()
        card.wantsLayer = true
        card.layer?.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.65).cgColor
        card.layer?.cornerRadius = 12
        let stack = NSStackView(views: [label, preview])
        stack.orientation = .vertical
        stack.alignment = .centerX
        stack.spacing = 8
        card.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            stack.topAnchor.constraint(greaterThanOrEqualTo: card.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12)
        ])
        return card
    }

    private func actionButton(_ title: String, action: Selector) -> NSButton {
        let button = NSButton(title: title, target: self, action: action)
        button.bezelStyle = .rounded
        return button
    }

    private func showNextUnlabeledCase() {
        let labeled = MotionBenchmarkStore.shared.labeledCaseIDs()
        while index < cases.count, labeled.contains(cases[index].id) {
            index += 1
        }
        guard index < cases.count else {
            caseLabel.stringValue = "All generated cases are labeled. Close and reopen to review the dataset."
            return
        }
        elapsed = 0
        let current = cases[index]
        caseLabel.stringValue = "\(current.id)  ·  \(current.task)  ·  \(index + 1)/\(cases.count)"
        reasonPopup.selectItem(at: 0)
        leftPreview.setMotionStyle(current.task)
        rightPreview.setMotionStyle(current.task)
    }

    private func advancePreview() {
        guard index < cases.count else { return }
        elapsed += 1.0 / 30.0
        let current = cases[index]
        let duration = max(current.candidateA.duration, current.candidateB.duration)
        if elapsed > duration { elapsed = 0 }
        let leftCandidate = current.presentAOnLeft ? current.candidateA : current.candidateB
        let rightCandidate = current.presentAOnLeft ? current.candidateB : current.candidateA
        leftPreview.setBenchmarkPose(MotionGraphLibrary.pose(for: leftCandidate, at: elapsed))
        rightPreview.setBenchmarkPose(MotionGraphLibrary.pose(for: rightCandidate, at: elapsed))
    }

    private func record(_ choice: String) {
        guard index < cases.count else { return }
        let reason = reasonPopup.indexOfSelectedItem == 0 ? "" : reasonPopup.titleOfSelectedItem ?? ""
        let current = cases[index]
        let semanticChoice: String
        switch choice {
        case "left": semanticChoice = current.presentAOnLeft ? "a" : "b"
        case "right": semanticChoice = current.presentAOnLeft ? "b" : "a"
        default: semanticChoice = choice
        }
        MotionBenchmarkStore.shared.append(MotionBenchmarkLabel(
            caseID: current.id,
            choice: semanticChoice,
            reason: reason,
            timestamp: Date()
        ))
        index += 1
        showNextUnlabeledCase()
    }

    @objc private func selectLeft() { record("left") }
    @objc private func selectRight() { record("right") }
    @objc private func selectTie() { record("tie") }
    @objc private func selectBothBad() { record("both_bad") }
    @objc private func skipCase() { index += 1; showNextUnlabeledCase() }
}
