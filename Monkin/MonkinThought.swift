import Foundation

struct MonkinThought {
    let text: String
    let figure: MonkinFigureSpec
    let visibleDuration: TimeInterval
}

protocol MonkinThoughtProvider {
    func nextThought() -> MonkinThought?
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

    func nextThought() -> MonkinThought? {
        guard !thoughts.isEmpty else { return nil }
        var index = Int.random(in: thoughts.indices)
        if thoughts.count > 1 {
            while index == lastIndex { index = Int.random(in: thoughts.indices) }
        }
        lastIndex = index
        return thoughts[index]
    }
}
