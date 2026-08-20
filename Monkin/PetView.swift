import AppKit
#if canImport(RiveRuntime)
import RiveRuntime
#endif

final class PetView: NSView {
    var onTap: (() -> Void)?
    var onMotionStyleChange: ((String) -> Void)?
    private let furColor = NSColor(calibratedRed: 0.58, green: 0.30, blue: 0.13, alpha: 1)
    private let bellyColor = NSColor(calibratedRed: 0.94, green: 0.72, blue: 0.43, alpha: 1)
    private let accentColor = NSColor(calibratedRed: 0.45, green: 0.34, blue: 0.82, alpha: 1)
    private let renderer = MonkinSVGRenderer()
    private var figureSpec = MonkinFigureSpec.default
    private var renderedImage: NSImage?
    private var pose = MonkinPose.neutral
    private var motionPhase: CGFloat = 0
    private var motionStyle = "idle"
    private var blinkTimer: Timer?
    private var motionTimer: Timer?
    private var isBlinking = false
#if canImport(RiveRuntime)
    private var riveRenderer: RivePetRenderer?
#endif

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        renderedImage = renderer.image(for: figureSpec)
#if canImport(RiveRuntime)
        if let riveRenderer = RivePetRenderer.make(frame: bounds) {
            self.riveRenderer = riveRenderer
            addSubview(riveRenderer)
        }
#endif
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 3.8, repeats: true) { [weak self] _ in
            self?.blink()
        }
        motionTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 12.0, repeats: true) { [weak self] _ in
            self?.advanceMotion()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        blinkTimer?.invalidate()
        motionTimer?.invalidate()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

#if canImport(RiveRuntime)
        // The subview is the desktop-app Rive path. Keep the procedural
        // renderer below as a migration and asset-load fallback.
        if riveRenderer?.isHidden == false { return }
#endif

        if let renderedImage {
            renderedImage.draw(in: bounds, from: .zero, operation: .sourceOver, fraction: 1)
            return
        }

        let context = NSGraphicsContext.current?.cgContext
        context?.saveGState()
        let scale = bounds.width / 220
        context?.scaleBy(x: scale, y: scale)
        context?.translateBy(x: 0, y: -48)

        drawAccessories()
        drawEars()
        drawHead()
        drawFace()

        context?.restoreGState()
    }

    override func mouseDown(with event: NSEvent) {
        onTap?()
    }

    override func layout() {
        super.layout()
#if canImport(RiveRuntime)
        riveRenderer?.frame = bounds
#endif
    }

    /// Rebuilds the SVG immediately from a dynamic material specification.
    /// A future conversation/LLM layer can call this with decoded JSON.
    func setFigure(_ spec: MonkinFigureSpec) {
        figureSpec = spec
        renderedImage = renderer.image(for: spec, pose: pose)
#if canImport(RiveRuntime)
        riveRenderer?.setFigure(spec)
#endif
        needsDisplay = true
    }

    func setPose(_ pose: MonkinPose) {
        self.pose = pose
        renderedImage = renderer.image(for: figureSpec, pose: pose)
        needsDisplay = true
    }

    func setMotionStyle(_ style: String) {
        let validatedStyle = MonkinMotion.validatedStyle(style)
        motionStyle = validatedStyle
#if canImport(RiveRuntime)
        riveRenderer?.setMotion(validatedStyle)
#endif
        onMotionStyleChange?(validatedStyle)
    }

    /// Stops the live animation timers so this view can be driven by a
    /// deterministic benchmark timeline.
    func prepareForBenchmark() {
        motionTimer?.invalidate()
        motionTimer = nil
        blinkTimer?.invalidate()
        blinkTimer = nil
#if canImport(RiveRuntime)
        // The benchmark compares deterministic procedural motion graphs, so
        // retain its established rendering path even in the app target.
        riveRenderer?.isHidden = true
#endif
    }

    /// Applies one frame from a benchmark motion graph.
    func setBenchmarkPose(_ pose: MonkinPose) {
        setPose(pose)
    }

    private func advanceMotion() {
#if canImport(RiveRuntime)
        // Rive owns its CADisplayLink. Avoid rebuilding SVG frames while it is
        // visible; this keeps idle CPU comparable to the pre-Rive app.
        if riveRenderer?.isHidden == false { return }
#endif
        motionPhase += 0.12
        if motionStyle == "jump" {
            advanceJump()
            return
        }
        if motionStyle == "wave" {
            advanceWave()
            return
        }
        if motionStyle == "celebrate" {
            advanceCelebrate()
            return
        }
        if motionStyle == "peek" {
            advancePeek()
            return
        }
        if motionStyle == "sleepy" {
            advanceSleepy()
            return
        }
        if motionStyle == "scratch" {
            advanceScratch()
            return
        }
        if motionStyle == "tiptoe" {
            advanceTiptoe()
            return
        }
        if motionStyle == "spin" {
            advanceSpin()
            return
        }
        if motionStyle == "stumble" {
            advanceStumble()
            return
        }
        if motionStyle == "hide" {
            advanceHide()
            return
        }
        if motionStyle == "stretch" {
            advanceStretch()
            return
        }
        if motionStyle == "wriggle" {
            advanceWriggle()
            return
        }
        if motionStyle == "escape" {
            advanceEscape()
            return
        }
        if motionStyle == "dive" {
            advanceDive()
            return
        }
        if motionStyle == "swim" {
            advanceSwim()
            return
        }
        if motionStyle == "soccer" {
            advanceSoccer()
            return
        }
        if motionStyle == "tennis" {
            advanceTennis()
            return
        }
        if motionStyle == "skate" {
            advanceSkate()
            return
        }
        if motionStyle == "basketball" {
            advanceBasketball()
            return
        }
        if motionStyle == "weightlifting" {
            advanceWeightlifting()
            return
        }
        if motionStyle == "jump-rope" {
            advanceJumpRope()
            return
        }
        if motionStyle == "clap" {
            advanceClap()
            return
        }
        if motionStyle == "dance" {
            advanceDance()
            return
        }
        if motionStyle == "laugh" {
            advanceLaugh()
            return
        }
        if motionStyle == "look-around" {
            advanceLookAround()
            return
        }
        if motionStyle == "yawn" {
            advanceYawn()
            return
        }
        if motionStyle == "bow" {
            advanceBow()
            return
        }

        let sway = sin(motionPhase * 2.0)
        let walk = sin(motionPhase * 3.0)
        var nextPose = MonkinPose(
            bodyBob: sin(motionPhase * 2.0) * 2.0,
            headRotation: sway * 2.5,
            leftArmRotation: sway * 3.0,
            rightArmRotation: -sway * 3.0,
            leftLegRotation: walk * 4.0,
            rightLegRotation: -walk * 4.0,
            tailRotation: sway * 5.0
        )

        let waveCycle = motionPhase.truncatingRemainder(dividingBy: 18)
        if waveCycle > 10 && waveCycle < 13 {
            nextPose.rightArmRotation = -35 + sin(motionPhase * 8) * 22
        }
        setPose(nextPose)
    }

    private func advanceWriggle() {
        let cycle = motionPhase * 2.4
        let push = sin(cycle)
        let crunch = abs(sin(cycle))
        let reach = max(0, sin(cycle + .pi / 2))
        let pose = MonkinPose(
            bodyBob: crunch * 3.5,
            bodyScaleX: 1.0 + crunch * 0.10,
            bodyScaleY: 0.88 - crunch * 0.08,
            headRotation: push * 7,
            headOffsetY: 4 + crunch * 4,
            headScaleX: 1.0 + crunch * 0.06,
            headScaleY: 1.0 - crunch * 0.08,
            leftArmRotation: 18 + reach * 34,
            rightArmRotation: -18 - max(0, sin(cycle - 0.9)) * 34,
            leftArmOffsetY: -reach * 5,
            rightArmOffsetY: -max(0, sin(cycle - 0.9)) * 5,
            leftLegRotation: -push * 12,
            rightLegRotation: push * 12,
            tailRotation: push * 14
        )
        setPose(pose)
    }

    private func advanceWave() {
        let wave = sin(motionPhase * 5.0)
        setPose(MonkinPose(
            bodyBob: sin(motionPhase * 2) * 2,
            headRotation: sin(motionPhase * 2) * 3,
            leftArmRotation: -8,
            rightArmRotation: -48 + wave * 28,
            rightArmOffsetY: 4 + abs(wave) * 3,
            leftLegRotation: sin(motionPhase * 2) * 3,
            rightLegRotation: -sin(motionPhase * 2) * 3,
            tailRotation: sin(motionPhase * 2) * 8
        ))
    }

    private func advanceCelebrate() {
        let bounce = abs(sin(motionPhase * 3.4))
        let sway = sin(motionPhase * 3.4)
        setPose(MonkinPose(
            bodyBob: bounce * 6,
            bodyScaleX: 1.0 + bounce * 0.12,
            bodyScaleY: 0.91 - bounce * 0.10,
            headRotation: sway * 5,
            headOffsetY: bounce * 5,
            leftArmRotation: -55 - sway * 12,
            rightArmRotation: 55 - sway * 12,
            leftArmOffsetY: bounce * 4,
            rightArmOffsetY: bounce * 4,
            leftLegRotation: sway * 10,
            rightLegRotation: -sway * 10,
            tailRotation: sway * 24
        ))
    }

    private func advancePeek() {
        let peek = (sin(motionPhase * 2.2) + 1) / 2
        setPose(MonkinPose(
            bodyBob: -peek * 6,
            bodyScaleX: 0.94 + peek * 0.06,
            bodyScaleY: 0.94 + peek * 0.06,
            headRotation: -4 + peek * 8,
            headOffsetY: -10 + peek * 12,
            headScaleX: 0.94 + peek * 0.06,
            headScaleY: 0.94 + peek * 0.06,
            leftArmRotation: 22 - peek * 20,
            rightArmRotation: -22 + peek * 20,
            leftArmOffsetY: -peek * 6,
            rightArmOffsetY: -peek * 6,
            tailRotation: -18 + peek * 30
        ))
    }

    private func advanceSleepy() {
        let nod = sin(motionPhase * 1.25)
        setPose(MonkinPose(
            bodyBob: abs(nod) * 1.5,
            headRotation: nod * 5,
            headOffsetY: -abs(nod) * 2,
            leftArmRotation: 8 + nod * 3,
            rightArmRotation: -8 + nod * 3,
            leftLegRotation: -2,
            rightLegRotation: 2,
            tailRotation: -8 + nod * 4
        ))
    }

    private func advanceScratch() {
        let scratch = sin(motionPhase * 9)
        setPose(MonkinPose(
            bodyBob: abs(scratch) * 2,
            headRotation: sin(motionPhase * 2) * 4,
            leftArmRotation: 50 + max(0, scratch) * 20,
            rightArmRotation: -50 + min(0, scratch) * 20,
            leftArmOffsetY: abs(scratch) * 8,
            rightArmOffsetY: abs(scratch) * 8,
            tailRotation: sin(motionPhase * 3) * 12
        ))
    }

    private func advanceTiptoe() {
        let step = sin(motionPhase * 4)
        setPose(MonkinPose(
            bodyBob: abs(step) * 3,
            bodyScaleX: 0.96,
            bodyScaleY: 1.04,
            headRotation: step * 3,
            headOffsetY: abs(step) * 3,
            leftArmRotation: -12 + step * 8,
            rightArmRotation: 12 + step * 8,
            leftLegRotation: step * 16,
            rightLegRotation: -step * 16,
            tailRotation: step * 15
        ))
    }

    private func advanceSpin() {
        let spin = sin(motionPhase * 3)
        setPose(MonkinPose(
            bodyBob: abs(spin) * 4,
            bodyScaleX: 0.92 + abs(spin) * 0.08,
            bodyScaleY: 1.0,
            headRotation: spin * 15,
            headOffsetY: abs(spin) * 4,
            leftArmRotation: spin * 35,
            rightArmRotation: -spin * 35,
            leftLegRotation: -spin * 18,
            rightLegRotation: spin * 18,
            tailRotation: spin * 35
        ))
    }

    private func advanceStumble() {
        let stumble = sin(motionPhase * 2.7)
        setPose(MonkinPose(
            bodyBob: abs(stumble) * 4,
            bodyScaleX: 1.0 + abs(stumble) * 0.08,
            bodyScaleY: 0.94 - abs(stumble) * 0.06,
            headRotation: stumble * 18,
            headOffsetY: -abs(stumble) * 4,
            leftArmRotation: -20 - stumble * 35,
            rightArmRotation: 20 - stumble * 35,
            leftArmOffsetY: -stumble * 5,
            rightArmOffsetY: stumble * 5,
            leftLegRotation: stumble * 22,
            rightLegRotation: stumble * 8,
            tailRotation: -stumble * 30
        ))
    }

    private func advanceHide() {
        let hide = (sin(motionPhase * 2.2) + 1) / 2
        setPose(MonkinPose(
            bodyBob: -hide * 5,
            bodyScaleX: 0.72 + hide * 0.28,
            bodyScaleY: 0.72 + hide * 0.28,
            headRotation: -5 + hide * 10,
            headOffsetY: -18 + hide * 18,
            headScaleX: 0.78 + hide * 0.22,
            headScaleY: 0.78 + hide * 0.22,
            leftArmRotation: 12,
            rightArmRotation: -12,
            tailRotation: -20 + hide * 40
        ))
    }

    private func advanceStretch() {
        let stretch = sin(motionPhase * 1.8)
        setPose(MonkinPose(
            bodyBob: -stretch * 3,
            bodyScaleX: 1.0 - stretch * 0.10,
            bodyScaleY: 1.0 + stretch * 0.16,
            headRotation: stretch * 3,
            headOffsetY: stretch * 5,
            headScaleX: 1.0 - stretch * 0.04,
            headScaleY: 1.0 + stretch * 0.08,
            leftArmRotation: -18 - stretch * 16,
            rightArmRotation: 18 + stretch * 16,
            leftArmOffsetY: stretch * 7,
            rightArmOffsetY: stretch * 7,
            leftLegRotation: -stretch * 8,
            rightLegRotation: stretch * 8,
            tailRotation: stretch * 18
        ))
    }

    private func advanceJump() {
        let phase = motionPhase.truncatingRemainder(dividingBy: 2.0 * .pi)
        let lift = max(0, sin(phase))
        let tuck = max(0, sin(phase))
        setPose(MonkinPose(
            bodyBob: lift * 5,
            bodyScaleX: 1.0 + tuck * 0.12,
            bodyScaleY: 0.92 - tuck * 0.10,
            headRotation: sin(phase * 0.7) * 5,
            headOffsetY: lift * 5,
            headScaleX: 1.0 + tuck * 0.05,
            headScaleY: 1.0 - tuck * 0.06,
            leftArmRotation: -28 - lift * 32,
            rightArmRotation: 28 + lift * 32,
            leftArmOffsetY: -lift * 5,
            rightArmOffsetY: -lift * 5,
            leftLegRotation: 18 + lift * 22,
            rightLegRotation: -18 - lift * 22,
            tailRotation: sin(phase * 1.5) * 18
        ))
    }

    private func advanceEscape() {
        let run = sin(motionPhase * 5.0)
        let panic = abs(sin(motionPhase * 2.5))
        setPose(MonkinPose(
            bodyBob: panic * 4,
            bodyScaleX: 1.04,
            bodyScaleY: 0.88,
            headRotation: -run * 8,
            headOffsetY: -panic * 4,
            leftArmRotation: 42 + run * 12,
            rightArmRotation: -42 + run * 12,
            leftArmOffsetY: -panic * 5,
            rightArmOffsetY: -panic * 5,
            leftLegRotation: -run * 18,
            rightLegRotation: run * 18,
            tailRotation: -run * 28
        ))
    }

    private func advanceDive() {
        let dive = (sin(motionPhase * 2.0) + 1) / 2
        setPose(MonkinPose(
            bodyBob: dive * 6,
            bodyScaleX: 1.16,
            bodyScaleY: 0.72,
            headRotation: 18 + dive * 12,
            headOffsetY: -dive * 10,
            headScaleX: 0.92,
            headScaleY: 0.92,
            leftArmRotation: -58 - dive * 18,
            rightArmRotation: 58 + dive * 18,
            leftArmOffsetY: dive * 8,
            rightArmOffsetY: dive * 8,
            leftLegRotation: 28 + dive * 18,
            rightLegRotation: -28 - dive * 18,
            tailRotation: -30 + dive * 45
        ))
    }

    private func advanceSwim() {
        let stroke = sin(motionPhase * 3.2)
        let kick = sin(motionPhase * 6.4)
        setPose(MonkinPose(
            bodyBob: abs(stroke) * 3,
            bodyScaleX: 1.08,
            bodyScaleY: 0.82,
            headRotation: stroke * 5,
            headOffsetY: 3 + abs(stroke) * 3,
            leftArmRotation: -55 + stroke * 38,
            rightArmRotation: 55 + stroke * 38,
            leftArmOffsetY: -stroke * 5,
            rightArmOffsetY: stroke * 5,
            leftLegRotation: kick * 22,
            rightLegRotation: -kick * 22,
            tailRotation: stroke * 24
        ))
    }

    private func advanceSoccer() {
        let kick = max(0, sin(motionPhase * 2.2))
        let balance = sin(motionPhase * 2.2)
        setPose(MonkinPose(
            bodyBob: kick * 5,
            headRotation: -balance * 4,
            headOffsetY: kick * 4,
            leftArmRotation: -25 - balance * 16,
            rightArmRotation: 25 - balance * 16,
            leftArmOffsetY: kick * 5,
            rightArmOffsetY: kick * 5,
            leftLegRotation: -balance * 12,
            rightLegRotation: 12 + kick * 58,
            tailRotation: -balance * 22
        ))
    }

    private func advanceTennis() {
        let swing = sin(motionPhase * 2.8)
        let followThrough = max(0, swing)
        setPose(MonkinPose(
            bodyBob: abs(swing) * 3,
            bodyScaleX: 0.98,
            bodyScaleY: 1.03,
            headRotation: swing * 7,
            leftArmRotation: -18 + swing * 20,
            rightArmRotation: -20 - followThrough * 78,
            rightArmOffsetY: followThrough * 10,
            leftLegRotation: -swing * 14,
            rightLegRotation: swing * 14,
            tailRotation: swing * 28
        ))
    }

    private func advanceSkate() {
        let glide = sin(motionPhase * 2.0)
        let crouch = (sin(motionPhase * 2.0) + 1) / 2
        setPose(MonkinPose(
            bodyBob: crouch * 2,
            bodyScaleX: 1.08,
            bodyScaleY: 0.86,
            headRotation: glide * 9,
            headOffsetY: -crouch * 5,
            leftArmRotation: -35 + glide * 22,
            rightArmRotation: 35 + glide * 22,
            leftLegRotation: -18 - glide * 18,
            rightLegRotation: 18 - glide * 18,
            tailRotation: glide * 34
        ))
    }

    private func advanceBasketball() {
        let cycle = motionPhase * 2.4
        let dribble = abs(sin(cycle))
        let shot = max(0, sin(cycle - 1.0))
        setPose(MonkinPose(
            bodyBob: dribble * 4 + shot * 5,
            bodyScaleX: 1.02 + dribble * 0.06,
            bodyScaleY: 0.94 - dribble * 0.08,
            headRotation: sin(cycle * 0.7) * 5,
            headOffsetY: shot * 5,
            leftArmRotation: -28 - shot * 34,
            rightArmRotation: 28 + shot * 34,
            leftArmOffsetY: dribble * 4,
            rightArmOffsetY: dribble * 4,
            leftLegRotation: 12 + dribble * 12,
            rightLegRotation: -12 - dribble * 12,
            tailRotation: sin(cycle) * 18
        ))
    }

    private func advanceWeightlifting() {
        let lift = (sin(motionPhase * 1.7) + 1) / 2
        let strain = abs(sin(motionPhase * 1.7))
        setPose(MonkinPose(
            bodyBob: -lift * 4,
            bodyScaleX: 1.0 + strain * 0.08,
            bodyScaleY: 0.94 - strain * 0.08,
            headRotation: sin(motionPhase * 1.7) * 4,
            headOffsetY: lift * 4,
            leftArmRotation: -18 - lift * 48,
            rightArmRotation: 18 + lift * 48,
            leftArmOffsetY: lift * 10,
            rightArmOffsetY: lift * 10,
            leftLegRotation: 14 - lift * 12,
            rightLegRotation: -14 + lift * 12,
            tailRotation: sin(motionPhase * 1.7) * 16
        ))
    }

    private func advanceJumpRope() {
        let bounce = abs(sin(motionPhase * 3.2))
        let swing = sin(motionPhase * 3.2)
        setPose(MonkinPose(
            bodyBob: bounce * 7,
            bodyScaleX: 0.96 + bounce * 0.08,
            bodyScaleY: 1.02 - bounce * 0.10,
            headRotation: swing * 3,
            headOffsetY: bounce * 5,
            leftArmRotation: 30 + swing * 20,
            rightArmRotation: -30 + swing * 20,
            leftArmOffsetY: -bounce * 3,
            rightArmOffsetY: -bounce * 3,
            leftLegRotation: swing * 8,
            rightLegRotation: -swing * 8,
            tailRotation: swing * 20
        ))
    }

    private func advanceClap() {
        let clap = max(0, sin(motionPhase * 4.0))
        let sway = sin(motionPhase * 2.0)
        setPose(MonkinPose(
            bodyBob: clap * 2,
            headRotation: sway * 3,
            leftArmRotation: 42 - clap * 30,
            rightArmRotation: -42 + clap * 30,
            leftArmOffsetY: clap * 7,
            rightArmOffsetY: clap * 7,
            leftLegRotation: sway * 4,
            rightLegRotation: -sway * 4,
            tailRotation: sway * 10
        ))
    }

    private func advanceDance() {
        let step = sin(motionPhase * 3.0)
        let sway = sin(motionPhase * 1.5)
        setPose(MonkinPose(
            bodyBob: abs(step) * 4,
            bodyScaleX: 1.0 + abs(step) * 0.06,
            bodyScaleY: 0.94 - abs(step) * 0.06,
            headRotation: sway * 8,
            headOffsetY: abs(step) * 3,
            leftArmRotation: -35 + sway * 35,
            rightArmRotation: 35 + sway * 35,
            leftArmOffsetY: max(0, step) * 12,
            rightArmOffsetY: max(0, -step) * 12,
            leftLegRotation: step * 24,
            rightLegRotation: -step * 24,
            tailRotation: sway * 30
        ))
    }

    private func advanceLaugh() {
        let laugh = abs(sin(motionPhase * 3.8))
        let sway = sin(motionPhase * 2.2)
        setPose(MonkinPose(
            bodyBob: laugh * 6,
            bodyScaleX: 1.0 + laugh * 0.10,
            bodyScaleY: 0.91 - laugh * 0.09,
            headRotation: sway * 9,
            headOffsetY: -laugh * 3,
            leftArmRotation: 26 + laugh * 22,
            rightArmRotation: -26 - laugh * 22,
            leftArmOffsetY: laugh * 8,
            rightArmOffsetY: laugh * 8,
            leftLegRotation: sway * 8,
            rightLegRotation: -sway * 8,
            tailRotation: sway * 25
        ))
    }

    private func advanceLookAround() {
        let look = sin(motionPhase * 1.35)
        let pause = abs(look) > 0.78 ? 0.4 : 0
        setPose(MonkinPose(
            bodyBob: pause,
            headRotation: look * 14,
            headOffsetY: abs(look) * 2,
            leftArmRotation: -8 - look * 5,
            rightArmRotation: 8 - look * 5,
            leftLegRotation: -look * 3,
            rightLegRotation: look * 3,
            tailRotation: -look * 12
        ))
    }

    private func advanceYawn() {
        let yawn = (sin(motionPhase * 1.15) + 1) / 2
        setPose(MonkinPose(
            bodyBob: -yawn * 3,
            bodyScaleX: 1.0 - yawn * 0.05,
            bodyScaleY: 1.0 + yawn * 0.10,
            headRotation: sin(motionPhase * 1.15) * 5,
            headOffsetY: yawn * 4,
            headScaleX: 1.0 - yawn * 0.04,
            headScaleY: 1.0 + yawn * 0.05,
            leftArmRotation: -24 - yawn * 24,
            rightArmRotation: 24 + yawn * 24,
            leftArmOffsetY: yawn * 10,
            rightArmOffsetY: yawn * 10,
            leftLegRotation: -yawn * 5,
            rightLegRotation: yawn * 5,
            tailRotation: -8 + yawn * 16
        ))
    }

    private func advanceBow() {
        let bow = (sin(motionPhase * 1.25) + 1) / 2
        setPose(MonkinPose(
            bodyBob: -bow * 4,
            bodyScaleX: 1.0 + bow * 0.04,
            bodyScaleY: 0.96 - bow * 0.04,
            headRotation: 4 + bow * 22,
            headOffsetY: -bow * 9,
            leftArmRotation: 18 + bow * 10,
            rightArmRotation: -18 - bow * 10,
            leftArmOffsetY: -bow * 4,
            rightArmOffsetY: -bow * 4,
            leftLegRotation: -bow * 5,
            rightLegRotation: bow * 5,
            tailRotation: -bow * 18
        ))
    }

    private func drawBody() {
        let body = NSBezierPath(ovalIn: NSRect(x: 58, y: 45, width: 104, height: 130))
        fill(body, with: gradient([
            furColor.blended(withFraction: 0.28, of: .white) ?? furColor,
            furColor,
            furColor.blended(withFraction: 0.30, of: .black) ?? furColor
        ]))
        stroke(body, with: NSColor(calibratedWhite: 0.12, alpha: 0.22), width: 2)

        let belly = NSBezierPath(ovalIn: NSRect(x: 79, y: 54, width: 62, height: 84))
        fill(belly, with: gradient([
            bellyColor.blended(withFraction: 0.35, of: .white) ?? bellyColor,
            bellyColor,
            bellyColor.blended(withFraction: 0.18, of: .black) ?? bellyColor
        ]))
    }

    private func drawHead() {
        let head = NSBezierPath(ovalIn: NSRect(x: 38, y: 125, width: 144, height: 105))
        fill(head, with: gradient([
            furColor.blended(withFraction: 0.33, of: .white) ?? furColor,
            furColor,
            furColor.blended(withFraction: 0.28, of: .black) ?? furColor
        ]))
        stroke(head, with: NSColor(calibratedWhite: 0.12, alpha: 0.22), width: 2)

        let muzzle = NSBezierPath(ovalIn: NSRect(x: 67, y: 137, width: 86, height: 53))
        fill(muzzle, with: gradient([
            bellyColor.blended(withFraction: 0.30, of: .white) ?? bellyColor,
            bellyColor,
            bellyColor.blended(withFraction: 0.15, of: .black) ?? bellyColor
        ]))

        let tuft = NSBezierPath()
        tuft.move(to: NSPoint(x: 97, y: 221))
        tuft.curve(to: NSPoint(x: 103, y: 239), controlPoint1: NSPoint(x: 96, y: 231), controlPoint2: NSPoint(x: 99, y: 237))
        tuft.curve(to: NSPoint(x: 111, y: 225), controlPoint1: NSPoint(x: 107, y: 238), controlPoint2: NSPoint(x: 109, y: 229))
        tuft.curve(to: NSPoint(x: 120, y: 238), controlPoint1: NSPoint(x: 114, y: 229), controlPoint2: NSPoint(x: 117, y: 236))
        tuft.curve(to: NSPoint(x: 125, y: 222), controlPoint1: NSPoint(x: 123, y: 237), controlPoint2: NSPoint(x: 127, y: 228))
        tuft.close()
        fill(tuft, with: gradient([
            furColor.blended(withFraction: 0.32, of: .white) ?? furColor,
            furColor
        ]))

        let hairClip = NSBezierPath(ovalIn: NSRect(x: 134, y: 211, width: 15, height: 15))
        accentColor.setFill()
        hairClip.fill()
        let clipStar = star(center: NSPoint(x: 141.5, y: 218.5), outerRadius: 7, innerRadius: 3)
        NSColor.white.withAlphaComponent(0.88).setFill()
        clipStar.fill()
    }

    private func drawAccessories() {
        let halo = NSBezierPath(ovalIn: NSRect(x: 50, y: 211, width: 120, height: 50))
        accentColor.withAlphaComponent(0.55).setStroke()
        halo.lineWidth = 3
        halo.stroke()

        sparkle(center: NSPoint(x: 39, y: 218), radius: 7, color: NSColor.systemPink.withAlphaComponent(0.85))
        sparkle(center: NSPoint(x: 183, y: 205), radius: 5, color: NSColor.systemYellow.withAlphaComponent(0.9))
        sparkle(center: NSPoint(x: 178, y: 235), radius: 3.5, color: accentColor.withAlphaComponent(0.8))
    }

    private func drawEars() {
        for x in [43.0, 137.0] {
            let ear = NSBezierPath(ovalIn: NSRect(x: x, y: 188, width: 40, height: 40))
            fill(ear, with: gradient([
                furColor.blended(withFraction: 0.25, of: .white) ?? furColor,
                furColor.blended(withFraction: 0.20, of: .black) ?? furColor
            ]))
            let inner = NSBezierPath(ovalIn: NSRect(x: x + 8, y: 196, width: 24, height: 24))
            fill(inner, with: gradient([
                NSColor.systemPink.withAlphaComponent(0.82),
                NSColor.systemPink.withAlphaComponent(0.38)
            ]))
        }
    }

    private func drawFace() {
        let eyeY: CGFloat = 179

        let leftBrow = NSBezierPath()
        leftBrow.move(to: NSPoint(x: 73, y: 207))
        leftBrow.curve(to: NSPoint(x: 90, y: 211), controlPoint1: NSPoint(x: 79, y: 213), controlPoint2: NSPoint(x: 85, y: 214))
        leftBrow.lineWidth = 3
        furColor.blended(withFraction: 0.25, of: .black)?.setStroke()
        leftBrow.stroke()

        let rightBrow = NSBezierPath()
        rightBrow.move(to: NSPoint(x: 132, y: 211))
        rightBrow.curve(to: NSPoint(x: 149, y: 207), controlPoint1: NSPoint(x: 137, y: 214), controlPoint2: NSPoint(x: 143, y: 213))
        rightBrow.lineWidth = 3
        rightBrow.stroke()

        for x in [74.0, 128.0] {
            let eye = NSBezierPath(ovalIn: NSRect(x: x, y: eyeY, width: 17, height: isBlinking ? 2 : 21))
            NSColor(white: 0.08, alpha: 1).setFill()
            eye.fill()

            if !isBlinking {
                let glint = NSBezierPath(ovalIn: NSRect(x: x + 4, y: eyeY + 13, width: 5, height: 5))
                NSColor.white.withAlphaComponent(0.9).setFill()
                glint.fill()
            }
        }

        for x in [65.0, 139.0] {
            let cheek = NSBezierPath(ovalIn: NSRect(x: x, y: 151, width: 24, height: 13))
            NSColor.systemPink.withAlphaComponent(0.30).setFill()
            cheek.fill()
        }

        let nose = NSBezierPath(ovalIn: NSRect(x: 104, y: 153, width: 14, height: 10))
        NSColor(calibratedRed: 0.25, green: 0.08, blue: 0.06, alpha: 1).setFill()
        nose.fill()

        let smile = NSBezierPath(ovalIn: NSRect(x: 97, y: 140, width: 29, height: 20))
        NSColor(calibratedRed: 0.24, green: 0.07, blue: 0.06, alpha: 1).setFill()
        smile.fill()

        let tongue = NSBezierPath(ovalIn: NSRect(x: 102, y: 141, width: 19, height: 10))
        NSColor(calibratedRed: 0.96, green: 0.35, blue: 0.40, alpha: 1).setFill()
        tongue.fill()

        let tooth = NSBezierPath(roundedRect: NSRect(x: 103, y: 154, width: 17, height: 4), xRadius: 2, yRadius: 2)
        NSColor.white.withAlphaComponent(0.9).setFill()
        tooth.fill()
    }

    private func drawTail() {
        let tail = NSBezierPath()
        tail.move(to: NSPoint(x: 144, y: 73))
        tail.curve(to: NSPoint(x: 198, y: 116), controlPoint1: NSPoint(x: 193, y: 35), controlPoint2: NSPoint(x: 217, y: 95))
        tail.lineWidth = 15
        tail.lineCapStyle = .round
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.22)
        shadow.shadowBlurRadius = 5
        shadow.shadowOffset = NSSize(width: 2, height: -3)
        shadow.set()
        furColor.blended(withFraction: 0.18, of: .black)?.setStroke()
        tail.stroke()

        NSGraphicsContext.current?.saveGraphicsState()
        NSGraphicsContext.current?.restoreGraphicsState()
        tail.lineWidth = 4
        tail.move(to: NSPoint(x: 147, y: 77))
        tail.curve(to: NSPoint(x: 195, y: 114), controlPoint1: NSPoint(x: 191, y: 47), controlPoint2: NSPoint(x: 208, y: 98))
        furColor.blended(withFraction: 0.24, of: .white)?.setStroke()
        tail.stroke()
    }

    private func drawFeet() {
        for x in [66.0, 125.0] {
            let foot = NSBezierPath(ovalIn: NSRect(x: x, y: 31, width: 42, height: 27))
            fill(foot, with: gradient([
                furColor.blended(withFraction: 0.20, of: .white) ?? furColor,
                furColor.blended(withFraction: 0.25, of: .black) ?? furColor
            ]))
        }
    }

    private func drawGroundShadow() {
        let shadow = NSBezierPath(ovalIn: NSRect(x: 51, y: 25, width: 118, height: 18))
        NSColor.black.withAlphaComponent(0.18).setFill()
        shadow.fill()
    }

    private func fill(_ path: NSBezierPath, with gradient: NSGradient) {
        NSGraphicsContext.current?.saveGraphicsState()
        path.addClip()
        gradient.draw(in: NSRect(x: 20, y: 20, width: 190, height: 220), angle: 68)
        NSGraphicsContext.current?.restoreGraphicsState()
    }

    private func gradient(_ colors: [NSColor]) -> NSGradient {
        NSGradient(colors: colors)!
    }

    private func sparkle(center: NSPoint, radius: CGFloat, color: NSColor) {
        let sparkle = NSBezierPath()
        sparkle.move(to: NSPoint(x: center.x, y: center.y + radius))
        sparkle.line(to: NSPoint(x: center.x + radius * 0.34, y: center.y + radius * 0.34))
        sparkle.line(to: NSPoint(x: center.x + radius, y: center.y))
        sparkle.line(to: NSPoint(x: center.x + radius * 0.34, y: center.y - radius * 0.34))
        sparkle.line(to: NSPoint(x: center.x, y: center.y - radius))
        sparkle.line(to: NSPoint(x: center.x - radius * 0.34, y: center.y - radius * 0.34))
        sparkle.line(to: NSPoint(x: center.x - radius, y: center.y))
        sparkle.line(to: NSPoint(x: center.x - radius * 0.34, y: center.y + radius * 0.34))
        sparkle.close()
        color.setFill()
        sparkle.fill()
    }

    private func star(center: NSPoint, outerRadius: CGFloat, innerRadius: CGFloat) -> NSBezierPath {
        let star = NSBezierPath()
        for index in 0..<10 {
            let radius = index.isMultiple(of: 2) ? outerRadius : innerRadius
            let angle = CGFloat(index) * .pi / 5 - .pi / 2
            let point = NSPoint(x: center.x + cos(angle) * radius,
                                y: center.y + sin(angle) * radius)
            if index == 0 {
                star.move(to: point)
            } else {
                star.line(to: point)
            }
        }
        star.close()
        return star
    }

    private func stroke(_ path: NSBezierPath, with color: NSColor, width: CGFloat) {
        color.setStroke()
        path.lineWidth = width
        path.stroke()
    }

    private func blink() {
        isBlinking = true
        var blinkSpec = figureSpec
        blinkSpec.eyes = "blink"
        renderedImage = renderer.image(for: blinkSpec, pose: pose)
        needsDisplay = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) { [weak self] in
            self?.isBlinking = false
            guard let self else { return }
            self.renderedImage = self.renderer.image(for: self.figureSpec, pose: self.pose)
            self.needsDisplay = true
        }
    }
}
