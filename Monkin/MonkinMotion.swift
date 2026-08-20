import Foundation

enum MonkinMotion {
    static let all = ["idle", "wriggle", "jump", "wave", "celebrate", "peek", "sleepy", "scratch", "tiptoe", "spin", "stumble", "hide", "stretch", "escape", "dive", "swim", "soccer", "basketball", "tennis", "skate", "weightlifting", "jump-rope"]
    static let expressive = Array(all.dropFirst())
    static let sports = ["soccer", "basketball", "tennis", "swim", "skate", "weightlifting", "jump-rope"]

    /// The only motion names accepted at the animation boundary. Callers from
    /// thoughts, roaming, and future conversation tools may provide arbitrary
    /// strings, so keeping this validation here prevents a renderer-specific
    /// input from ever receiving an unknown state.
    static func validatedStyle(_ style: String) -> String {
        all.contains(style) ? style : "idle"
    }

    static func randomExpressive() -> String {
        // Make sports common enough to notice during a short observation.
        if Int.random(in: 0..<3) == 0, let sport = sports.randomElement() {
            return sport
        }
        return expressive.randomElement() ?? "wriggle"
    }
}
