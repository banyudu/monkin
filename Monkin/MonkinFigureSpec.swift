import Foundation

/// A data-driven description of Monkin's current appearance.
/// Values are material names, not hard-coded emotions, so new combinations can
/// be produced by a conversation model without changing the app binary.
struct MonkinFigureSpec: Codable, Equatable {
    var eyes: String
    var brows: String
    var mouth: String
    var cheeks: String?
    var accessories: [String]
    var colors: [String: String]

    static let `default` = MonkinFigureSpec(
        eyes: "neutral",
        brows: "relaxed",
        mouth: "smile",
        cheeks: "light",
        accessories: [],
        colors: ["accent": "#4A7772"]
    )
}
