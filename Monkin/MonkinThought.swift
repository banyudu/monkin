import Foundation

struct MonkinThought {
    let text: String
    let figure: MonkinFigureSpec
    let visibleDuration: TimeInterval
    let motionStyle: String

    init(text: String, figure: MonkinFigureSpec, visibleDuration: TimeInterval, motionStyle: String = "idle") {
        self.text = text
        self.figure = figure
        self.visibleDuration = visibleDuration
        self.motionStyle = motionStyle
    }
}

protocol MonkinThoughtProvider {
    func nextThought(completion: @escaping (MonkinThought?) -> Void)
}

final class LocalThoughtProvider: MonkinThoughtProvider {
    private let thoughts: [MonkinThought] = [
        MonkinThought(
            text: "我刚才认真观察了你的桌面。那个杯子看起来很适合藏秘密。",
            figure: MonkinFigureSpec(eyes: "curious", brows: "raised", mouth: "smirk", cheeks: "light", accessories: ["coffee"], colors: ["accent": "#4A7772"]),
            visibleDuration: 7
        ),
        MonkinThought(
            text: "我有一个问题：为什么人类总是盯着发光的矩形？",
            figure: MonkinFigureSpec(eyes: "curious", brows: "raised", mouth: "open", cheeks: nil, accessories: ["question-mark"], colors: ["accent": "#5E7B68"]),
            visibleDuration: 8
        ),
        MonkinThought(
            text: "我想去公园，但我现在还不会走路。我们可以假装一下吗？",
            figure: MonkinFigureSpec(eyes: "happy", brows: "relaxed", mouth: "smile", cheeks: "light", accessories: ["spark"], colors: ["accent": "#D29A52"]),
            visibleDuration: 8
        ),
        MonkinThought(
            text: "我发现自己刚才忘记了一个想法。它可能躲起来了。",
            figure: MonkinFigureSpec(eyes: "sad", brows: "worried", mouth: "sad", cheeks: nil, accessories: ["moon"], colors: ["accent": "#8D4650"]),
            visibleDuration: 8
        ),
        MonkinThought(
            text: "今天的空气有一点像星期五，虽然我不确定星期五是什么味道。",
            figure: MonkinFigureSpec(eyes: "neutral", brows: "relaxed", mouth: "smile", cheeks: "light", accessories: [], colors: ["accent": "#4A7772"]),
            visibleDuration: 7
        )
    ]

    private var lastIndex: Int?

    func nextThought(completion: @escaping (MonkinThought?) -> Void) {
        guard !thoughts.isEmpty else { completion(nil); return }
        var index = Int.random(in: thoughts.indices)
        if thoughts.count > 1 {
            while index == lastIndex { index = Int.random(in: thoughts.indices) }
        }
        lastIndex = index
        completion(thoughts[index])
    }
}

/// Uses the user's authenticated Codex CLI, keeping API keys out of Monkin.
final class CodexThoughtProvider: MonkinThoughtProvider {
    private struct Payload: Decodable {
        let text: String
        let eyes: String?
        let brows: String?
        let mouth: String?
        let cheeks: String?
        let accessories: [String]?
        let accent: String?
        let visibleDuration: Double?
        let motion: String?
    }

    private let fallback: MonkinThoughtProvider
    private var requestInFlight = false
    private let lock = NSLock()
    private var topicIndex = 0

    init(fallback: MonkinThoughtProvider = LocalThoughtProvider()) {
        self.fallback = fallback
    }

    func nextThought(completion: @escaping (MonkinThought?) -> Void) {
        lock.lock()
        if requestInFlight {
            lock.unlock()
            fallback.nextThought(completion: completion)
            return
        }
        requestInFlight = true
        lock.unlock()

        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self else { return }
            let thought = self.runCodex()
            self.lock.lock()
            self.requestInFlight = false
            self.lock.unlock()
            DispatchQueue.main.async {
                if let thought {
                    completion(thought)
                } else {
                    self.fallback.nextThought(completion: completion)
                }
            }
        }
    }

    private func runCodex() -> MonkinThought? {
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("monkin-thought-\(UUID().uuidString).txt")
        defer { try? FileManager.default.removeItem(at: outputURL) }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/codex")
        process.currentDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        process.arguments = ["exec", "--ephemeral", "--skip-git-repo-check", "--color", "never",
                             "-m", "gpt-5.6-luna", "-o", outputURL.path, "-"]
        var environment = ProcessInfo.processInfo.environment
        environment["PATH"] = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
        process.environment = environment

        let input = Pipe()
        process.standardInput = input
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            let topics = ["窗边的光影", "桌面上的植物", "空气里的声音", "一件被遗忘的小物件", "今天的天气", "影子和反光", "一个奇怪的梦", "人类的习惯"]
            lock.lock()
            let topic = topics[topicIndex % topics.count]
            topicIndex += 1
            lock.unlock()
            let prompt = """
            你是 Monkin，一个住在用户桌面上的成年人的可爱猴子宠物。请用自然、机灵、略带荒诞的中文和主人说一句话，像真的有自己的观察和小脾气。不要说教，不要解释你是 AI，不要使用 markdown。可以逗主人、提出古怪问题、描述你刚才想做的事情，也可以暗示身体动作（比如蛄蛹、突然起跳、躲到屏幕后面）。

            本次优先围绕“\(topic)”说话。请保持主题多样，不要总是围绕鼠标、光标、键盘或咖啡；它们偶尔可以出现，但不要连续重复。每次尽量换一个观察角度。

            只返回一个合法 JSON 对象，不要代码块：
            {"text":"不超过45字的台词","eyes":"neutral|happy|sad|curious|sleepy","brows":"relaxed|raised|worried","mouth":"neutral|smile|open|sad|smirk","cheeks":"light 或 null","accessories":["coffee|spark|question-mark|moon"],"accent":"#RRGGBB","visibleDuration":7,"motion":"\(MonkinMotion.promptValues)"}
            """
            input.fileHandleForWriting.write(prompt.data(using: .utf8)!)
            try input.fileHandleForWriting.close()
            process.waitUntilExit()
        } catch {
            return nil
        }

        guard process.terminationStatus == 0,
              let data = try? Data(contentsOf: outputURL),
              let payload = decodePayload(from: data) else { return nil }
        return makeThought(from: payload)
    }

    private func decodePayload(from data: Data) -> Payload? {
        guard let raw = String(data: data, encoding: .utf8) else { return nil }
        let cleaned = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let start = cleaned.firstIndex(of: "{"), let end = cleaned.lastIndex(of: "}") else { return nil }
        let json = String(cleaned[start...end]).data(using: .utf8)!
        return try? JSONDecoder().decode(Payload.self, from: json)
    }

    private func makeThought(from payload: Payload) -> MonkinThought? {
        let text = payload.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }
        let eyes = ["neutral", "happy", "sad", "curious", "sleepy"].contains(payload.eyes ?? "") ? payload.eyes! : "neutral"
        let brows = ["relaxed", "raised", "worried"].contains(payload.brows ?? "") ? payload.brows! : "relaxed"
        let mouth = ["neutral", "smile", "open", "sad", "smirk"].contains(payload.mouth ?? "") ? payload.mouth! : "smile"
        let accessories = (payload.accessories ?? []).filter { ["coffee", "spark", "question-mark", "moon"].contains($0) }.prefix(2)
        let accent = payload.accent?.hasPrefix("#") == true ? payload.accent! : "#4A7772"
        let duration = min(max(payload.visibleDuration ?? 7, 4), 12)
        let motion = MonkinMotion.all.contains(payload.motion ?? "") ? payload.motion! : "idle"
        return MonkinThought(text: text,
                             figure: MonkinFigureSpec(eyes: eyes, brows: brows, mouth: mouth,
                                                      cheeks: payload.cheeks == "light" ? "light" : nil,
                                                      accessories: Array(accessories), colors: ["accent": accent]),
                             visibleDuration: duration,
                             motionStyle: motion)
    }
}
