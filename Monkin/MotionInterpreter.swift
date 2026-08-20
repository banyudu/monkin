import Foundation

enum MotionInterpreter {
    private static let scaleChannels: Set<String> = [
        "bodyScaleX", "bodyScaleY", "headScaleX", "headScaleY"
    ]

    static let allChannels: Set<String> = [
        "bodyBob", "bodyScaleX", "bodyScaleY",
        "headRotation", "headOffsetY", "headScaleX", "headScaleY",
        "leftArmRotation", "rightArmRotation",
        "leftArmOffsetY", "rightArmOffsetY",
        "leftLegRotation", "rightLegRotation",
        "tailRotation"
    ]

    private static let validWaveforms: Set<String> = [
        "sine", "absSine", "halfSine", "pulse", "constant"
    ]

    private static let channelBounds: [String: ClosedRange<Double>] = [
        "bodyBob": -15...15,
        "bodyScaleX": 0.5...1.5,
        "bodyScaleY": 0.5...1.5,
        "headRotation": -45...45,
        "headOffsetY": -25...25,
        "headScaleX": 0.5...1.5,
        "headScaleY": 0.5...1.5,
        "leftArmRotation": -120...120,
        "rightArmRotation": -120...120,
        "leftArmOffsetY": -20...20,
        "rightArmOffsetY": -20...20,
        "leftLegRotation": -75...75,
        "rightLegRotation": -75...75,
        "tailRotation": -50...50,
    ]

    // MARK: - Validation

    struct ValidationResult {
        var isValid: Bool
        var issues: [String]
        var program: MotionProgram
    }

    static func validate(_ program: MotionProgram) -> ValidationResult {
        var issues: [String] = []
        var normalized = program

        if program.duration < 0.1 || program.duration > 60 {
            issues.append("duration_out_of_range")
            normalized.duration = min(60, max(0.1, program.duration))
        }

        if program.layers.count > 64 {
            issues.append("too_many_layers")
            normalized.layers = Array(program.layers.prefix(64))
        }

        normalized.layers = normalized.layers.compactMap { layer in
            var l = layer

            if !allChannels.contains(layer.channel) {
                issues.append("unknown_channel:\(layer.channel)")
                return nil
            }
            if !validWaveforms.contains(layer.waveform) {
                issues.append("unknown_waveform:\(layer.waveform)")
                return nil
            }
            if abs(layer.speed) > 30 {
                issues.append("speed_out_of_range")
                l.speed = min(30, max(-30, layer.speed))
            }
            if layer.waveform == "pulse" {
                l.pulseStart = min(1, max(0, layer.pulseStart ?? 0))
                l.pulseEnd = min(1, max(0, layer.pulseEnd ?? 1))
                if l.pulseStart! >= l.pulseEnd! {
                    issues.append("pulse_range_invalid")
                    return nil
                }
            }
            if !l.amplitude.isFinite || !l.speed.isFinite ||
                !l.phase.isFinite || !l.offset.isFinite {
                issues.append("non_finite_value")
                return nil
            }

            return l
        }

        return ValidationResult(
            isValid: issues.isEmpty,
            issues: issues,
            program: normalized
        )
    }

    // MARK: - Evaluation

    static func pose(for program: MotionProgram, at time: Double) -> MonkinPose {
        var values: [String: Double] = [:]
        for ch in scaleChannels { values[ch] = 1.0 }

        let duration = max(0.1, program.duration)

        for layer in program.layers {
            let contribution = evaluate(layer: layer, at: time, duration: duration)
            guard contribution.isFinite else { continue }
            let base = scaleChannels.contains(layer.channel) ? 1.0 : 0.0
            values[layer.channel, default: base] += contribution
        }

        for (channel, bounds) in channelBounds {
            if let value = values[channel] {
                values[channel] = min(bounds.upperBound, max(bounds.lowerBound, value))
            }
        }

        return MonkinPose(
            bodyBob: CGFloat(values["bodyBob"] ?? 0),
            bodyScaleX: CGFloat(values["bodyScaleX"] ?? 1),
            bodyScaleY: CGFloat(values["bodyScaleY"] ?? 1),
            headRotation: CGFloat(values["headRotation"] ?? 0),
            headOffsetY: CGFloat(values["headOffsetY"] ?? 0),
            headScaleX: CGFloat(values["headScaleX"] ?? 1),
            headScaleY: CGFloat(values["headScaleY"] ?? 1),
            leftArmRotation: CGFloat(values["leftArmRotation"] ?? 0),
            rightArmRotation: CGFloat(values["rightArmRotation"] ?? 0),
            leftArmOffsetY: CGFloat(values["leftArmOffsetY"] ?? 0),
            rightArmOffsetY: CGFloat(values["rightArmOffsetY"] ?? 0),
            leftLegRotation: CGFloat(values["leftLegRotation"] ?? 0),
            rightLegRotation: CGFloat(values["rightLegRotation"] ?? 0),
            tailRotation: CGFloat(values["tailRotation"] ?? 0)
        )
    }

    // MARK: - Determinism verification

    static func verifyDeterminism(_ program: MotionProgram, samples: Int = 100) -> Bool {
        let duration = program.duration
        let first = (0..<samples).map { i in
            pose(for: program, at: Double(i) / Double(samples) * duration)
        }
        let second = (0..<samples).map { i in
            pose(for: program, at: Double(i) / Double(samples) * duration)
        }
        return first == second
    }

    // MARK: - Private

    private static func evaluate(layer: MotionLayer, at time: Double, duration: Double) -> Double {
        let value: Double
        let phase = time * layer.speed + layer.phase

        switch layer.waveform {
        case "sine":
            value = sin(phase)
        case "absSine":
            value = abs(sin(phase))
        case "halfSine":
            value = max(0, sin(phase))
        case "pulse":
            let t = fmod(time, duration) / duration
            value = smoothstep(t, start: layer.pulseStart ?? 0, end: layer.pulseEnd ?? 1)
        case "constant":
            value = 1.0
        default:
            return 0
        }

        return value * layer.amplitude + layer.offset
    }

    private static func smoothstep(_ x: Double, start: Double, end: Double) -> Double {
        let t = min(1, max(0, (x - start) / max(0.001, end - start)))
        return t * t * (3 - 2 * t)
    }
}
