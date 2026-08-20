import Foundation

struct MotionGraphParameters: Codable {
    var amplitude: Double
    var speed: Double
    var anticipation: Double
    var followThrough: Double
    var asymmetry: Double
    var contactOffset: Double

    static let baseline = MotionGraphParameters(
        amplitude: 1.0,
        speed: 1.0,
        anticipation: 1.0,
        followThrough: 1.0,
        asymmetry: 0.0,
        contactOffset: 0.0
    )
}

struct MotionGraphCandidate: Codable, Identifiable {
    let id: String
    let task: String
    let seed: UInt64
    let variant: String
    let duration: Double
    let parameters: MotionGraphParameters
    var validationIssues: [String]
}

struct MotionBenchmarkCase: Codable, Identifiable {
    let id: String
    let task: String
    let candidateA: MotionGraphCandidate
    let candidateB: MotionGraphCandidate
    let presentAOnLeft: Bool
}

struct MotionBenchmarkLabel: Codable {
    let caseID: String
    let choice: String
    let reason: String
    let timestamp: Date
}

enum MotionGraphLibrary {
    static let tasks = ["wave", "jump", "soccer_kick", "tennis_swing", "stretch"]

    static func pose(for candidate: MotionGraphCandidate, at time: Double) -> MonkinPose {
        let phase = clamp(time / max(0.1, candidate.duration))
        let p = candidate.parameters
        let cycle = phase * 2.0 * .pi * p.speed
        let a = p.amplitude
        let asymmetry = p.asymmetry

        switch candidate.task {
        case "wave":
            let wave = sin(cycle * 2.0)
            let sway = sin(cycle)
            return MonkinPose(
                bodyBob: sin(cycle) * 2.0 * a,
                headRotation: sway * 3.0 * a,
                leftArmRotation: -8.0 * a,
                rightArmRotation: -48.0 * a + wave * 28.0 * a,
                rightArmOffsetY: 4.0 + abs(wave) * 3.0,
                leftLegRotation: sway * 3.0,
                rightLegRotation: -sway * 3.0,
                tailRotation: sway * 8.0
            )

        case "jump":
            let lift = pulse(phase, start: 0.18, end: 0.68)
            let landing = pulse(phase, start: 0.68, end: 0.98)
            let tuck = lift * p.anticipation
            return MonkinPose(
                bodyBob: (lift * 5.0 - landing * 2.0) * a,
                bodyScaleX: 1.0 + tuck * 0.12 * a,
                bodyScaleY: 0.92 - tuck * 0.10 * a,
                headRotation: sin(cycle * 0.7) * 5.0 * a,
                headOffsetY: lift * 5.0 * a,
                leftArmRotation: -28.0 - lift * 32.0 * a,
                rightArmRotation: 28.0 + lift * 32.0 * a,
                leftLegRotation: 18.0 + lift * 22.0 * a,
                rightLegRotation: -18.0 - lift * 22.0 * a,
                tailRotation: sin(cycle * 1.5) * 18.0 * a
            )

        case "soccer_kick":
            let backswing = pulse(phase, start: 0.08, end: 0.34) * p.anticipation
            let contact = pulse(phase,
                                start: 0.34 + p.contactOffset,
                                end: 0.56 + p.contactOffset)
            let recovery = pulse(phase, start: 0.56, end: 0.92) * p.followThrough
            let balance = sin(cycle) * (1.0 + asymmetry)
            return MonkinPose(
                bodyBob: (backswing * 2.0 + contact * 5.0) * a,
                headRotation: -balance * 4.0 * a,
                headOffsetY: contact * 4.0 * a,
                leftArmRotation: -25.0 - balance * 16.0 * a,
                rightArmRotation: 25.0 - balance * 16.0 * a,
                leftArmOffsetY: contact * 5.0 * a,
                rightArmOffsetY: contact * 5.0 * a,
                leftLegRotation: -balance * 12.0 * a,
                rightLegRotation: 12.0 + (contact * 58.0 + recovery * 16.0) * a,
                tailRotation: -balance * 22.0 * a
            )

        case "tennis_swing":
            let preparation = pulse(phase, start: 0.04, end: 0.34) * p.anticipation
            let swing = pulse(phase,
                              start: 0.30 + p.contactOffset,
                              end: 0.57 + p.contactOffset)
            let followThrough = pulse(phase, start: 0.52, end: 0.92) * p.followThrough
            let direction = sin(cycle) * a
            return MonkinPose(
                bodyBob: (preparation * 1.5 + swing * 3.0) * a,
                bodyScaleX: 0.98,
                bodyScaleY: 1.03,
                headRotation: direction * 7.0,
                leftArmRotation: -18.0 + direction * 20.0,
                rightArmRotation: -20.0 - (swing * 78.0 + followThrough * 20.0) * a,
                rightArmOffsetY: (swing * 10.0 + followThrough * 8.0) * a,
                leftLegRotation: -direction * 14.0,
                rightLegRotation: direction * 14.0,
                tailRotation: direction * 28.0
            )

        case "stretch":
            let stretch = sin(cycle * 0.5) * a
            return MonkinPose(
                bodyBob: -stretch * 3.0,
                bodyScaleX: 1.0 - stretch * 0.10,
                bodyScaleY: 1.0 + stretch * 0.16,
                headRotation: stretch * 3.0,
                headOffsetY: stretch * 5.0,
                headScaleX: 1.0 - stretch * 0.04,
                headScaleY: 1.0 + stretch * 0.08,
                leftArmRotation: -18.0 - stretch * 16.0,
                rightArmRotation: 18.0 + stretch * 16.0,
                leftArmOffsetY: stretch * 7.0,
                rightArmOffsetY: stretch * 7.0,
                leftLegRotation: -stretch * 8.0,
                rightLegRotation: stretch * 8.0,
                tailRotation: stretch * 18.0
            )

        default:
            return .neutral
        }
    }

    private static func pulse(_ phase: Double, start: Double, end: Double) -> Double {
        let normalized = clamp((phase - start) / max(0.001, end - start))
        return normalized * normalized * (3.0 - 2.0 * normalized)
    }

    private static func clamp(_ value: Double) -> Double {
        min(1.0, max(0.0, value))
    }
}

enum MotionBenchmarkGenerator {
    static func generate(count: Int, seed: UInt64 = 20260820) -> [MotionBenchmarkCase] {
        var random = SeededRandom(seed: seed)
        return (0..<max(0, count)).map { index in
            let task = MotionGraphLibrary.tasks[random.index(upperBound: MotionGraphLibrary.tasks.count)]
            let baseline = MotionGraphParameters(
                amplitude: random.double(in: 0.88...1.12),
                speed: random.double(in: 0.92...1.08),
                anticipation: random.double(in: 0.88...1.12),
                followThrough: random.double(in: 0.88...1.12),
                asymmetry: random.double(in: -0.08...0.08),
                contactOffset: random.double(in: -0.025...0.025)
            )
            let duration = random.double(in: 2.0...3.4)
            let good = MotionGraphCandidate(
                id: "\(index)-a",
                task: task,
                seed: random.state,
                variant: "baseline",
                duration: duration,
                parameters: baseline,
                validationIssues: []
            )

            let corruption = ["timing", "contact", "balance", "follow_through", "overexertion"][random.index(upperBound: 5)]
            let badParameters = corrupted(baseline, kind: corruption)
            let bad = MotionGraphCandidate(
                id: "\(index)-b",
                task: task,
                seed: random.state,
                variant: corruption,
                duration: corruption == "timing" ? duration * 1.45 : duration,
                parameters: badParameters,
                validationIssues: validate(task: task, parameters: badParameters)
            )

            return MotionBenchmarkCase(
                id: "motion-\(String(format: "%04d", index))",
                task: task,
                candidateA: good,
                candidateB: bad,
                presentAOnLeft: random.index(upperBound: 2) == 0
            )
        }
    }

    static func validate(task: String, parameters: MotionGraphParameters) -> [String] {
        let candidate = MotionGraphCandidate(
            id: "validation",
            task: task,
            seed: 0,
            variant: "validation",
            duration: 2.8,
            parameters: parameters,
            validationIssues: []
        )
        var issues: [String] = []
        var previous = MotionGraphLibrary.pose(for: candidate, at: 0)
        for index in 1...24 {
            let pose = MotionGraphLibrary.pose(for: candidate, at: 2.8 * Double(index) / 24.0)
            let delta = maxPoseDelta(previous, pose)
            if !delta.isFinite || delta > 85 {
                issues.append("discontinuous_pose")
                break
            }
            previous = pose
        }
        if parameters.contactOffset < -0.08 || parameters.contactOffset > 0.08 {
            issues.append("contact_out_of_phase")
        }
        if parameters.amplitude > 1.65 {
            issues.append("excessive_amplitude")
        }
        return Array(Set(issues)).sorted()
    }

    private static func corrupted(_ input: MotionGraphParameters, kind: String) -> MotionGraphParameters {
        var result = input
        switch kind {
        case "timing":
            result.anticipation = 0.15
            result.speed = 1.65
        case "contact":
            result.contactOffset = 0.18
        case "balance":
            result.asymmetry = 0.65
        case "follow_through":
            result.followThrough = 0.12
        case "overexertion":
            result.amplitude = 1.75
        default:
            break
        }
        return result
    }

    private static func maxPoseDelta(_ lhs: MonkinPose, _ rhs: MonkinPose) -> Double {
        let values: [CGFloat] = [
            abs(lhs.bodyBob - rhs.bodyBob),
            abs(lhs.headRotation - rhs.headRotation),
            abs(lhs.leftArmRotation - rhs.leftArmRotation),
            abs(lhs.rightArmRotation - rhs.rightArmRotation),
            abs(lhs.leftLegRotation - rhs.leftLegRotation),
            abs(lhs.rightLegRotation - rhs.rightLegRotation),
            abs(lhs.tailRotation - rhs.tailRotation)
        ]
        return Double(values.max() ?? 0)
    }
}

final class MotionBenchmarkStore {
    static let shared = MotionBenchmarkStore()

    private let directory: URL
    private let casesURL: URL
    private let labelsURL: URL
    private let encoder: JSONEncoder
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(label: "com.banyudu.monkin.motion-benchmark")

    private init() {
        directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Monkin", isDirectory: true)
        casesURL = directory.appendingPathComponent("motion-benchmark-cases.jsonl")
        labelsURL = directory.appendingPathComponent("motion-benchmark-labels.jsonl")
        encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func loadOrGenerate(count: Int = 150) -> [MotionBenchmarkCase] {
        if let existing = readCases(), !existing.isEmpty {
            return existing
        }
        let generated = MotionBenchmarkGenerator.generate(count: count)
        writeCases(generated)
        return generated
    }

    func append(_ label: MotionBenchmarkLabel) {
        queue.async { [encoder, labelsURL] in
            guard let data = try? encoder.encode(label),
                  let line = String(data: data, encoding: .utf8)?.appending("\n") else { return }
            if !FileManager.default.fileExists(atPath: labelsURL.path) {
                FileManager.default.createFile(atPath: labelsURL.path, contents: nil)
            }
            guard let handle = try? FileHandle(forWritingTo: labelsURL) else { return }
            handle.seekToEndOfFile()
            handle.write(line.data(using: .utf8)!)
            try? handle.close()
        }
    }

    func labeledCaseIDs() -> Set<String> {
        guard let data = try? Data(contentsOf: labelsURL) else { return [] }
        return Set(data.split(separator: 10).compactMap { line in
            try? decoder.decode(MotionBenchmarkLabel.self, from: Data(line))
        }.map(\.caseID))
    }

    private func readCases() -> [MotionBenchmarkCase]? {
        guard let data = try? Data(contentsOf: casesURL) else { return nil }
        let cases = data.split(separator: 10).compactMap { line in
            try? decoder.decode(MotionBenchmarkCase.self, from: Data(line))
        }
        return cases.isEmpty ? nil : cases
    }

    private func writeCases(_ cases: [MotionBenchmarkCase]) {
        queue.sync {
            let lines = cases.compactMap { try? encoder.encode($0) }
                .map { $0 + Data([10]) }
            try? lines.reduce(into: Data()) { $0.append($1) }.write(to: casesURL, options: .atomic)
        }
    }
}

private struct SeededRandom {
    fileprivate private(set) var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 1 : seed
    }

    mutating func double(in range: ClosedRange<Double>) -> Double {
        state = state &* 2862933555777941757 &+ 3037000493
        let unit = Double(state >> 11) / Double(UInt64.max >> 11)
        return range.lowerBound + (range.upperBound - range.lowerBound) * unit
    }

    mutating func index(upperBound: Int) -> Int {
        guard upperBound > 1 else { return 0 }
        return Int(double(in: 0...Double(upperBound - 1)).rounded(.down))
    }
}
