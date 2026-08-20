import Foundation

enum MotionPresets {
    // motionPhase grows at 0.12 per frame × 12 fps = 1.44 per second.
    // speed = originalMultiplier × M converts to real-time seconds.
    private static let M = 1.44

    static let idle = program([
        s("bodyBob", k: 2, amp: 2),
        s("headRotation", k: 2, amp: 2.5),
        s("leftArmRotation", k: 2, amp: 3),
        s("rightArmRotation", k: 2, amp: -3),
        s("leftLegRotation", k: 3, amp: 4),
        s("rightLegRotation", k: 3, amp: -4),
        s("tailRotation", k: 2, amp: 5),
    ])

    static let wriggle = program([
        a("bodyBob", k: 2.4, amp: 3.5),
        a("bodyScaleX", k: 2.4, amp: 0.10),
        c("bodyScaleY", -0.12),
        a("bodyScaleY", k: 2.4, amp: -0.08),
        s("headRotation", k: 2.4, amp: 7),
        c("headOffsetY", 4),
        a("headOffsetY", k: 2.4, amp: 4),
        a("headScaleX", k: 2.4, amp: 0.06),
        a("headScaleY", k: 2.4, amp: -0.08),
        c("leftArmRotation", 18),
        h("leftArmRotation", k: 2.4, amp: 34, phase: .pi / 2),
        c("rightArmRotation", -18),
        h("rightArmRotation", k: 2.4, amp: -34, phase: -0.9),
        h("leftArmOffsetY", k: 2.4, amp: -5, phase: .pi / 2),
        h("rightArmOffsetY", k: 2.4, amp: -5, phase: -0.9),
        s("leftLegRotation", k: 2.4, amp: -12),
        s("rightLegRotation", k: 2.4, amp: 12),
        s("tailRotation", k: 2.4, amp: 14),
    ])

    static let wave = program([
        s("bodyBob", k: 2, amp: 2),
        s("headRotation", k: 2, amp: 3),
        c("leftArmRotation", -8),
        s("rightArmRotation", k: 5, amp: 28, offset: -48),
        a("rightArmOffsetY", k: 5, amp: 3, offset: 4),
        s("leftLegRotation", k: 2, amp: 3),
        s("rightLegRotation", k: 2, amp: -3),
        s("tailRotation", k: 2, amp: 8),
    ])

    static let celebrate = program([
        a("bodyBob", k: 3.4, amp: 6),
        a("bodyScaleX", k: 3.4, amp: 0.12),
        c("bodyScaleY", -0.09),
        a("bodyScaleY", k: 3.4, amp: -0.10),
        s("headRotation", k: 3.4, amp: 5),
        a("headOffsetY", k: 3.4, amp: 5),
        s("leftArmRotation", k: 3.4, amp: -12, offset: -55),
        s("rightArmRotation", k: 3.4, amp: -12, offset: 55),
        a("leftArmOffsetY", k: 3.4, amp: 4),
        a("rightArmOffsetY", k: 3.4, amp: 4),
        s("leftLegRotation", k: 3.4, amp: 10),
        s("rightLegRotation", k: 3.4, amp: -10),
        s("tailRotation", k: 3.4, amp: 24),
    ])

    // peek = (sin + 1) / 2 decomposed to sine + offset
    static let peek = program([
        s("bodyBob", k: 2.2, amp: -3, offset: -3),
        c("bodyScaleX", -0.03),
        s("bodyScaleX", k: 2.2, amp: 0.03),
        c("bodyScaleY", -0.03),
        s("bodyScaleY", k: 2.2, amp: 0.03),
        s("headRotation", k: 2.2, amp: 4),
        s("headOffsetY", k: 2.2, amp: 6, offset: -4),
        c("headScaleX", -0.03),
        s("headScaleX", k: 2.2, amp: 0.03),
        c("headScaleY", -0.03),
        s("headScaleY", k: 2.2, amp: 0.03),
        s("leftArmRotation", k: 2.2, amp: -10, offset: 12),
        s("rightArmRotation", k: 2.2, amp: 10, offset: -12),
        s("leftArmOffsetY", k: 2.2, amp: -3, offset: -3),
        s("rightArmOffsetY", k: 2.2, amp: -3, offset: -3),
        s("tailRotation", k: 2.2, amp: 15, offset: -3),
    ])

    static let sleepy = program([
        a("bodyBob", k: 1.25, amp: 1.5),
        s("headRotation", k: 1.25, amp: 5),
        a("headOffsetY", k: 1.25, amp: -2),
        s("leftArmRotation", k: 1.25, amp: 3, offset: 8),
        s("rightArmRotation", k: 1.25, amp: 3, offset: -8),
        c("leftLegRotation", -2),
        c("rightLegRotation", 2),
        s("tailRotation", k: 1.25, amp: 4, offset: -8),
    ])

    static let scratch = program([
        a("bodyBob", k: 9, amp: 2),
        s("headRotation", k: 2, amp: 4),
        c("leftArmRotation", 50),
        h("leftArmRotation", k: 9, amp: 20),
        c("rightArmRotation", -50),
        h("rightArmRotation", k: 9, amp: -20, phase: .pi),
        a("leftArmOffsetY", k: 9, amp: 8),
        a("rightArmOffsetY", k: 9, amp: 8),
        s("tailRotation", k: 3, amp: 12),
    ])

    static let tiptoe = program([
        a("bodyBob", k: 4, amp: 3),
        c("bodyScaleX", -0.04),
        c("bodyScaleY", 0.04),
        s("headRotation", k: 4, amp: 3),
        a("headOffsetY", k: 4, amp: 3),
        s("leftArmRotation", k: 4, amp: 8, offset: -12),
        s("rightArmRotation", k: 4, amp: 8, offset: 12),
        s("leftLegRotation", k: 4, amp: 16),
        s("rightLegRotation", k: 4, amp: -16),
        s("tailRotation", k: 4, amp: 15),
    ])

    static let spin = program([
        a("bodyBob", k: 3, amp: 4),
        c("bodyScaleX", -0.08),
        a("bodyScaleX", k: 3, amp: 0.08),
        s("headRotation", k: 3, amp: 15),
        a("headOffsetY", k: 3, amp: 4),
        s("leftArmRotation", k: 3, amp: 35),
        s("rightArmRotation", k: 3, amp: -35),
        s("leftLegRotation", k: 3, amp: -18),
        s("rightLegRotation", k: 3, amp: 18),
        s("tailRotation", k: 3, amp: 35),
    ])

    static let stumble = program([
        a("bodyBob", k: 2.7, amp: 4),
        a("bodyScaleX", k: 2.7, amp: 0.08),
        c("bodyScaleY", -0.06),
        a("bodyScaleY", k: 2.7, amp: -0.06),
        s("headRotation", k: 2.7, amp: 18),
        a("headOffsetY", k: 2.7, amp: -4),
        s("leftArmRotation", k: 2.7, amp: -35, offset: -20),
        s("rightArmRotation", k: 2.7, amp: -35, offset: 20),
        s("leftArmOffsetY", k: 2.7, amp: -5),
        s("rightArmOffsetY", k: 2.7, amp: 5),
        s("leftLegRotation", k: 2.7, amp: 22),
        s("rightLegRotation", k: 2.7, amp: 8),
        s("tailRotation", k: 2.7, amp: -30),
    ])

    // hide = (sin + 1) / 2 decomposed to sine + offset
    static let hide = program([
        s("bodyBob", k: 2.2, amp: -2.5, offset: -2.5),
        c("bodyScaleX", -0.14),
        s("bodyScaleX", k: 2.2, amp: 0.14),
        c("bodyScaleY", -0.14),
        s("bodyScaleY", k: 2.2, amp: 0.14),
        s("headRotation", k: 2.2, amp: 5),
        s("headOffsetY", k: 2.2, amp: 9, offset: -9),
        c("headScaleX", -0.11),
        s("headScaleX", k: 2.2, amp: 0.11),
        c("headScaleY", -0.11),
        s("headScaleY", k: 2.2, amp: 0.11),
        c("leftArmRotation", 12),
        c("rightArmRotation", -12),
        s("tailRotation", k: 2.2, amp: 20),
    ])

    static let stretch = program([
        s("bodyBob", k: 1.8, amp: -3),
        s("bodyScaleX", k: 1.8, amp: -0.10),
        s("bodyScaleY", k: 1.8, amp: 0.16),
        s("headRotation", k: 1.8, amp: 3),
        s("headOffsetY", k: 1.8, amp: 5),
        s("headScaleX", k: 1.8, amp: -0.04),
        s("headScaleY", k: 1.8, amp: 0.08),
        s("leftArmRotation", k: 1.8, amp: -16, offset: -18),
        s("rightArmRotation", k: 1.8, amp: 16, offset: 18),
        s("leftArmOffsetY", k: 1.8, amp: 7),
        s("rightArmOffsetY", k: 1.8, amp: 7),
        s("leftLegRotation", k: 1.8, amp: -8),
        s("rightLegRotation", k: 1.8, amp: 8),
        s("tailRotation", k: 1.8, amp: 18),
    ])

    static let jump = program([
        h("bodyBob", k: 1, amp: 5),
        h("bodyScaleX", k: 1, amp: 0.12),
        c("bodyScaleY", -0.08),
        h("bodyScaleY", k: 1, amp: -0.10),
        s("headRotation", k: 0.7, amp: 5),
        h("headOffsetY", k: 1, amp: 5),
        h("headScaleX", k: 1, amp: 0.05),
        h("headScaleY", k: 1, amp: -0.06),
        h("leftArmRotation", k: 1, amp: -32, offset: -28),
        h("rightArmRotation", k: 1, amp: 32, offset: 28),
        h("leftArmOffsetY", k: 1, amp: -5),
        h("rightArmOffsetY", k: 1, amp: -5),
        h("leftLegRotation", k: 1, amp: 22, offset: 18),
        h("rightLegRotation", k: 1, amp: -22, offset: -18),
        s("tailRotation", k: 1.5, amp: 18),
    ])

    static let escape = program([
        a("bodyBob", k: 2.5, amp: 4),
        c("bodyScaleX", 0.04),
        c("bodyScaleY", -0.12),
        s("headRotation", k: 5, amp: -8),
        a("headOffsetY", k: 2.5, amp: -4),
        s("leftArmRotation", k: 5, amp: 12, offset: 42),
        s("rightArmRotation", k: 5, amp: 12, offset: -42),
        a("leftArmOffsetY", k: 2.5, amp: -5),
        a("rightArmOffsetY", k: 2.5, amp: -5),
        s("leftLegRotation", k: 5, amp: -18),
        s("rightLegRotation", k: 5, amp: 18),
        s("tailRotation", k: 5, amp: -28),
    ])

    // dive = (sin + 1) / 2 decomposed to sine + offset
    static let dive = program([
        s("bodyBob", k: 2, amp: 3, offset: 3),
        c("bodyScaleX", 0.16),
        c("bodyScaleY", -0.28),
        s("headRotation", k: 2, amp: 6, offset: 24),
        s("headOffsetY", k: 2, amp: -5, offset: -5),
        c("headScaleX", -0.08),
        c("headScaleY", -0.08),
        s("leftArmRotation", k: 2, amp: -9, offset: -67),
        s("rightArmRotation", k: 2, amp: 9, offset: 67),
        s("leftArmOffsetY", k: 2, amp: 4, offset: 4),
        s("rightArmOffsetY", k: 2, amp: 4, offset: 4),
        s("leftLegRotation", k: 2, amp: 9, offset: 37),
        s("rightLegRotation", k: 2, amp: -9, offset: -37),
        s("tailRotation", k: 2, amp: 22.5, offset: -7.5),
    ])

    static let swim = program([
        a("bodyBob", k: 3.2, amp: 3),
        c("bodyScaleX", 0.08),
        c("bodyScaleY", -0.18),
        s("headRotation", k: 3.2, amp: 5),
        c("headOffsetY", 3),
        a("headOffsetY", k: 3.2, amp: 3),
        s("leftArmRotation", k: 3.2, amp: 38, offset: -55),
        s("rightArmRotation", k: 3.2, amp: 38, offset: 55),
        s("leftArmOffsetY", k: 3.2, amp: -5),
        s("rightArmOffsetY", k: 3.2, amp: 5),
        s("leftLegRotation", k: 6.4, amp: 22),
        s("rightLegRotation", k: 6.4, amp: -22),
        s("tailRotation", k: 3.2, amp: 24),
    ])

    static let soccer = program([
        h("bodyBob", k: 2.2, amp: 5),
        s("headRotation", k: 2.2, amp: -4),
        h("headOffsetY", k: 2.2, amp: 4),
        s("leftArmRotation", k: 2.2, amp: -16, offset: -25),
        s("rightArmRotation", k: 2.2, amp: -16, offset: 25),
        h("leftArmOffsetY", k: 2.2, amp: 5),
        h("rightArmOffsetY", k: 2.2, amp: 5),
        s("leftLegRotation", k: 2.2, amp: -12),
        h("rightLegRotation", k: 2.2, amp: 58, offset: 12),
        s("tailRotation", k: 2.2, amp: -22),
    ])

    static let tennis = program([
        a("bodyBob", k: 2.8, amp: 3),
        c("bodyScaleX", -0.02),
        c("bodyScaleY", 0.03),
        s("headRotation", k: 2.8, amp: 7),
        s("leftArmRotation", k: 2.8, amp: 20, offset: -18),
        h("rightArmRotation", k: 2.8, amp: -78, offset: -20),
        h("rightArmOffsetY", k: 2.8, amp: 10),
        s("leftLegRotation", k: 2.8, amp: -14),
        s("rightLegRotation", k: 2.8, amp: 14),
        s("tailRotation", k: 2.8, amp: 28),
    ])

    // skate: crouch = (sin + 1) / 2
    static let skate = program([
        s("bodyBob", k: 2, amp: 1, offset: 1),
        c("bodyScaleX", 0.08),
        c("bodyScaleY", -0.14),
        s("headRotation", k: 2, amp: 9),
        s("headOffsetY", k: 2, amp: -2.5, offset: -2.5),
        s("leftArmRotation", k: 2, amp: 22, offset: -35),
        s("rightArmRotation", k: 2, amp: 22, offset: 35),
        s("leftLegRotation", k: 2, amp: -18, offset: -18),
        s("rightLegRotation", k: 2, amp: -18, offset: 18),
        s("tailRotation", k: 2, amp: 34),
    ])

    static let basketball = program([
        a("bodyBob", k: 2.4, amp: 4),
        h("bodyBob", k: 2.4, amp: 5, phase: -1),
        c("bodyScaleX", 0.02),
        a("bodyScaleX", k: 2.4, amp: 0.06),
        c("bodyScaleY", -0.06),
        a("bodyScaleY", k: 2.4, amp: -0.08),
        s("headRotation", k: 1.68, amp: 5),
        h("headOffsetY", k: 2.4, amp: 5, phase: -1),
        h("leftArmRotation", k: 2.4, amp: -34, phase: -1, offset: -28),
        h("rightArmRotation", k: 2.4, amp: 34, phase: -1, offset: 28),
        a("leftArmOffsetY", k: 2.4, amp: 4),
        a("rightArmOffsetY", k: 2.4, amp: 4),
        a("leftLegRotation", k: 2.4, amp: 12, offset: 12),
        a("rightLegRotation", k: 2.4, amp: -12, offset: -12),
        s("tailRotation", k: 2.4, amp: 18),
    ])

    // weightlifting: lift = (sin + 1) / 2, strain = abs(sin)
    static let weightlifting = program([
        s("bodyBob", k: 1.7, amp: -2, offset: -2),
        a("bodyScaleX", k: 1.7, amp: 0.08),
        c("bodyScaleY", -0.06),
        a("bodyScaleY", k: 1.7, amp: -0.08),
        s("headRotation", k: 1.7, amp: 4),
        s("headOffsetY", k: 1.7, amp: 2, offset: 2),
        s("leftArmRotation", k: 1.7, amp: -24, offset: -42),
        s("rightArmRotation", k: 1.7, amp: 24, offset: 42),
        s("leftArmOffsetY", k: 1.7, amp: 5, offset: 5),
        s("rightArmOffsetY", k: 1.7, amp: 5, offset: 5),
        s("leftLegRotation", k: 1.7, amp: -6, offset: 8),
        s("rightLegRotation", k: 1.7, amp: 6, offset: -8),
        s("tailRotation", k: 1.7, amp: 16),
    ])

    static let jumpRope = program([
        a("bodyBob", k: 3.2, amp: 7),
        c("bodyScaleX", -0.04),
        a("bodyScaleX", k: 3.2, amp: 0.08),
        c("bodyScaleY", 0.02),
        a("bodyScaleY", k: 3.2, amp: -0.10),
        s("headRotation", k: 3.2, amp: 3),
        a("headOffsetY", k: 3.2, amp: 5),
        s("leftArmRotation", k: 3.2, amp: 20, offset: 30),
        s("rightArmRotation", k: 3.2, amp: 20, offset: -30),
        a("leftArmOffsetY", k: 3.2, amp: -3),
        a("rightArmOffsetY", k: 3.2, amp: -3),
        s("leftLegRotation", k: 3.2, amp: 8),
        s("rightLegRotation", k: 3.2, amp: -8),
        s("tailRotation", k: 3.2, amp: 20),
    ])

    static let clap = program([
        h("bodyBob", k: 4, amp: 2),
        s("headRotation", k: 2, amp: 3),
        h("leftArmRotation", k: 4, amp: -30, offset: 42),
        h("rightArmRotation", k: 4, amp: 30, offset: -42),
        h("leftArmOffsetY", k: 4, amp: 7),
        h("rightArmOffsetY", k: 4, amp: 7),
        s("leftLegRotation", k: 2, amp: 4),
        s("rightLegRotation", k: 2, amp: -4),
        s("tailRotation", k: 2, amp: 10),
    ])

    static let dance = program([
        a("bodyBob", k: 3, amp: 4),
        a("bodyScaleX", k: 3, amp: 0.06),
        c("bodyScaleY", -0.06),
        a("bodyScaleY", k: 3, amp: -0.06),
        s("headRotation", k: 1.5, amp: 8),
        a("headOffsetY", k: 3, amp: 3),
        s("leftArmRotation", k: 1.5, amp: 35, offset: -35),
        s("rightArmRotation", k: 1.5, amp: 35, offset: 35),
        h("leftArmOffsetY", k: 3, amp: 12),
        h("rightArmOffsetY", k: 3, amp: 12, phase: .pi),
        s("leftLegRotation", k: 3, amp: 24),
        s("rightLegRotation", k: 3, amp: -24),
        s("tailRotation", k: 1.5, amp: 30),
    ])

    static let laugh = program([
        a("bodyBob", k: 3.8, amp: 6),
        a("bodyScaleX", k: 3.8, amp: 0.10),
        c("bodyScaleY", -0.09),
        a("bodyScaleY", k: 3.8, amp: -0.09),
        s("headRotation", k: 2.2, amp: 9),
        a("headOffsetY", k: 3.8, amp: -3),
        a("leftArmRotation", k: 3.8, amp: 22, offset: 26),
        a("rightArmRotation", k: 3.8, amp: -22, offset: -26),
        a("leftArmOffsetY", k: 3.8, amp: 8),
        a("rightArmOffsetY", k: 3.8, amp: 8),
        s("leftLegRotation", k: 2.2, amp: 8),
        s("rightLegRotation", k: 2.2, amp: -8),
        s("tailRotation", k: 2.2, amp: 25),
    ])

    static let lookAround = program([
        s("headRotation", k: 1.35, amp: 14),
        a("headOffsetY", k: 1.35, amp: 2),
        s("leftArmRotation", k: 1.35, amp: -5, offset: -8),
        s("rightArmRotation", k: 1.35, amp: -5, offset: 8),
        s("leftLegRotation", k: 1.35, amp: -3),
        s("rightLegRotation", k: 1.35, amp: 3),
        s("tailRotation", k: 1.35, amp: -12),
    ])

    // yawn = (sin + 1) / 2 decomposed to sine + offset
    static let yawn = program([
        s("bodyBob", k: 1.15, amp: -1.5, offset: -1.5),
        c("bodyScaleX", -0.025),
        s("bodyScaleX", k: 1.15, amp: -0.025),
        c("bodyScaleY", 0.05),
        s("bodyScaleY", k: 1.15, amp: 0.05),
        s("headRotation", k: 1.15, amp: 5),
        s("headOffsetY", k: 1.15, amp: 2, offset: 2),
        c("headScaleX", -0.02),
        s("headScaleX", k: 1.15, amp: -0.02),
        c("headScaleY", 0.025),
        s("headScaleY", k: 1.15, amp: 0.025),
        s("leftArmRotation", k: 1.15, amp: -12, offset: -36),
        s("rightArmRotation", k: 1.15, amp: 12, offset: 36),
        s("leftArmOffsetY", k: 1.15, amp: 5, offset: 5),
        s("rightArmOffsetY", k: 1.15, amp: 5, offset: 5),
        s("leftLegRotation", k: 1.15, amp: -2.5, offset: -2.5),
        s("rightLegRotation", k: 1.15, amp: 2.5, offset: 2.5),
        s("tailRotation", k: 1.15, amp: 8),
    ])

    // bow = (sin + 1) / 2 decomposed to sine + offset
    static let bow = program([
        s("bodyBob", k: 1.25, amp: -2, offset: -2),
        c("bodyScaleX", 0.02),
        s("bodyScaleX", k: 1.25, amp: 0.02),
        c("bodyScaleY", -0.06),
        s("bodyScaleY", k: 1.25, amp: -0.02),
        s("headRotation", k: 1.25, amp: 11, offset: 15),
        s("headOffsetY", k: 1.25, amp: -4.5, offset: -4.5),
        s("leftArmRotation", k: 1.25, amp: 5, offset: 23),
        s("rightArmRotation", k: 1.25, amp: -5, offset: -23),
        s("leftArmOffsetY", k: 1.25, amp: -2, offset: -2),
        s("rightArmOffsetY", k: 1.25, amp: -2, offset: -2),
        s("leftLegRotation", k: 1.25, amp: -2.5, offset: -2.5),
        s("rightLegRotation", k: 1.25, amp: 2.5, offset: 2.5),
        s("tailRotation", k: 1.25, amp: -9, offset: -9),
    ])

    // MARK: - Lookup

    private static let presetsByName: [String: MotionProgram] = [
        "idle": idle, "wriggle": wriggle, "jump": jump, "wave": wave,
        "celebrate": celebrate, "peek": peek, "sleepy": sleepy,
        "scratch": scratch, "tiptoe": tiptoe, "spin": spin,
        "stumble": stumble, "hide": hide, "stretch": stretch,
        "escape": escape, "dive": dive, "swim": swim,
        "soccer": soccer, "basketball": basketball, "tennis": tennis,
        "skate": skate, "weightlifting": weightlifting,
        "jump-rope": jumpRope, "clap": clap, "dance": dance,
        "laugh": laugh, "look-around": lookAround, "yawn": yawn, "bow": bow,
    ]

    static func program(for name: String) -> MotionProgram {
        presetsByName[name] ?? idle
    }

    // MARK: - Helpers

    private static func program(_ layers: [MotionLayer]) -> MotionProgram {
        MotionProgram(seed: 0, duration: 4.0, layers: layers)
    }

    private static func s(_ ch: String, k: Double, amp: Double,
                          phase: Double = 0, offset: Double = 0) -> MotionLayer {
        MotionLayer(channel: ch, waveform: "sine", amplitude: amp,
                    speed: k * M, phase: phase, offset: offset)
    }

    private static func a(_ ch: String, k: Double, amp: Double,
                          phase: Double = 0, offset: Double = 0) -> MotionLayer {
        MotionLayer(channel: ch, waveform: "absSine", amplitude: amp,
                    speed: k * M, phase: phase, offset: offset)
    }

    private static func h(_ ch: String, k: Double, amp: Double,
                          phase: Double = 0, offset: Double = 0) -> MotionLayer {
        MotionLayer(channel: ch, waveform: "halfSine", amplitude: amp,
                    speed: k * M, phase: phase, offset: offset)
    }

    private static func c(_ ch: String, _ value: Double) -> MotionLayer {
        MotionLayer(channel: ch, waveform: "constant", amplitude: value)
    }
}
