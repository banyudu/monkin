import AppKit

final class MonkinSVGRenderer {
    func image(for spec: MonkinFigureSpec) -> NSImage? {
        let svg = render(spec)
        let data = Data(svg.utf8)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("monkin-\(UUID().uuidString).svg")

        do {
            try data.write(to: url, options: .atomic)
            defer { try? FileManager.default.removeItem(at: url) }
            return NSImage(contentsOf: url)
        } catch {
            return nil
        }
    }

    func render(_ spec: MonkinFigureSpec) -> String {
        let accent = color(spec.colors["accent"], fallback: "#4A7772")
        let layers = [
            material("eyes", named: spec.eyes),
            material("brows", named: spec.brows),
            material("mouth", named: spec.mouth),
            material("cheeks", named: spec.cheeks ?? "none")
        ].joined()

        let accessories = spec.accessories.map { material("accessory", named: $0, accent: accent) }.joined()
        return """
        <svg xmlns="http://www.w3.org/2000/svg" width="300" height="250" viewBox="0 0 300 250">
          <defs>
            <linearGradient id="fur" x1="0" y1="0" x2="0.8" y2="1">
              <stop offset="0" stop-color="#C48751"/><stop offset="0.58" stop-color="#9A5D34"/><stop offset="1" stop-color="#704027"/>
            </linearGradient>
            <linearGradient id="muzzle" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0" stop-color="#F1D29A"/><stop offset="1" stop-color="#D7A96B"/>
            </linearGradient>
            <filter id="shadow" x="-20%" y="-20%" width="140%" height="150%">
              <feDropShadow dx="0" dy="8" stdDeviation="7" flood-color="#17171B" flood-opacity="0.28"/>
            </filter>
          </defs>
          <ellipse cx="150" cy="222" rx="86" ry="12" fill="#17171B" opacity="0.16"/>
          <g filter="url(#shadow)">
            <path d="M87 77 C82 48 103 35 126 49 C140 34 160 34 175 49 C199 35 220 49 214 78 C235 96 237 141 215 169 C197 194 172 204 150 204 C128 204 103 194 85 169 C63 141 65 96 87 77Z" fill="url(#fur)" stroke="#2B2522" stroke-width="7" stroke-linejoin="round"/>
            <ellipse cx="74" cy="112" rx="29" ry="35" fill="#B97A4D" stroke="#2B2522" stroke-width="7"/>
            <ellipse cx="226" cy="112" rx="29" ry="35" fill="#B97A4D" stroke="#2B2522" stroke-width="7"/>
            <path d="M62 111 Q74 97 86 111 Q74 126 62 111Z" fill="#4A7772" stroke="#2B2522" stroke-width="4"/>
            <path d="M214 111 Q226 97 238 111 Q226 126 214 111Z" fill="#4A7772" stroke="#2B2522" stroke-width="4"/>
            <path d="M119 58 Q132 39 149 52 Q165 38 181 58 Q165 65 150 61 Q135 66 119 58Z" fill="#C88750" stroke="#2B2522" stroke-width="5" stroke-linejoin="round"/>
            <ellipse cx="150" cy="141" rx="69" ry="48" fill="url(#muzzle)" stroke="#2B2522" stroke-width="5"/>
            \(layers)
            \(accessories)
          </g>
        </svg>
        """
    }

    private func material(_ family: String, named name: String, accent: String = "#4A7772") -> String {
        switch "\(family):\(name)" {
        case "eyes:neutral": return eyes("#25262A", glint: true)
        case "eyes:happy": return "<path d=\"M101 119 Q116 132 131 119 M169 119 Q184 132 199 119\" fill=\"none\" stroke=\"#25262A\" stroke-width=\"6\" stroke-linecap=\"round\"/>"
        case "eyes:sad": return eyes("#25262A", glint: false, sad: true)
        case "eyes:curious": return eyes("#25262A", glint: true, curious: true)
        case "eyes:sleepy": return "<path d=\"M101 116 Q116 125 131 116 M169 116 Q184 125 199 116\" fill=\"none\" stroke=\"#25262A\" stroke-width=\"6\" stroke-linecap=\"round\"/>"
        case "eyes:blink": return "<path d=\"M101 120 Q116 126 131 120 M169 120 Q184 126 199 120\" fill=\"none\" stroke=\"#25262A\" stroke-width=\"6\" stroke-linecap=\"round\"/>"
        case "brows:raised": return "<path d=\"M101 101 Q116 87 132 100 M168 100 Q184 87 200 101\" fill=\"none\" stroke=\"#2B2522\" stroke-width=\"6\" stroke-linecap=\"round\"/>"
        case "brows:worried": return "<path d=\"M101 101 Q116 111 132 105 M168 105 Q184 111 200 101\" fill=\"none\" stroke=\"#2B2522\" stroke-width=\"6\" stroke-linecap=\"round\"/>"
        case "brows:relaxed": return "<path d=\"M101 108 Q116 99 131 108 M169 108 Q184 99 199 108\" fill=\"none\" stroke=\"#2B2522\" stroke-width=\"6\" stroke-linecap=\"round\"/>"
        case "mouth:neutral": return mouth("M136 153 Q150 159 164 153", color: "#563123")
        case "mouth:smile": return mouth("M132 151 Q150 164 168 151", color: "#563123") + "<path d=\"M144 157 Q150 162 156 157\" fill=\"none\" stroke=\"#C47A51\" stroke-width=\"4\" stroke-linecap=\"round\"/>"
        case "mouth:open": return "<ellipse cx=\"150\" cy=\"151\" rx=\"18\" ry=\"13\" fill=\"#563123\"/><path d=\"M141 155 Q150 162 159 155\" fill=\"none\" stroke=\"#C47A51\" stroke-width=\"4\" stroke-linecap=\"round\"/>"
        case "mouth:sad": return mouth("M134 160 Q150 148 166 160", color: "#563123")
        case "mouth:smirk": return mouth("M133 154 Q150 164 168 149", color: "#563123")
        case "cheeks:light": return "<path d=\"M88 143 Q101 136 113 143 M187 143 Q199 136 212 143\" fill=\"none\" stroke=\"#C47A51\" stroke-width=\"5\" stroke-linecap=\"round\" opacity=\"0.68\"/>"
        case "accessory:coffee": return "<path d=\"M207 72 L222 72 L220 94 Q215 101 209 94Z\" fill=\"\(accent)\" stroke=\"#2B2522\" stroke-width=\"4\"/><path d=\"M222 78 Q234 78 228 88 Q225 91 220 89\" fill=\"none\" stroke=\"#2B2522\" stroke-width=\"4\"/><path d=\"M211 64 Q207 58 212 53 M219 64 Q215 58 220 53\" fill=\"none\" stroke=\"#FFF4D5\" stroke-width=\"3\" stroke-linecap=\"round\"/>"
        case "accessory:spark": return "<path d=\"M210 65 L215 78 L228 83 L215 88 L210 101 L205 88 L192 83 L205 78Z\" fill=\"\(accent)\" stroke=\"#2B2522\" stroke-width=\"3\"/>"
        case "accessory:question-mark": return "<text x=\"202\" y=\"95\" font-family=\"Avenir Next, sans-serif\" font-size=\"42\" font-weight=\"700\" fill=\"\(accent)\" stroke=\"#2B2522\" stroke-width=\"2\">?</text>"
        case "accessory:moon": return "<path d=\"M220 65 A20 20 0 1 0 220 101 A15 15 0 1 1 220 65Z\" fill=\"\(accent)\" stroke=\"#2B2522\" stroke-width=\"4\"/>"
        default: return ""
        }
    }

    private func eyes(_ color: String, glint: Bool, sad: Bool = false, curious: Bool = false) -> String {
        let leftY = curious ? 117 : 121
        let rightY = sad ? 125 : (curious ? 117 : 121)
        let glints = glint ? "<circle cx=\"121\" cy=\"116\" r=\"4\" fill=\"#FFF9E9\"/><circle cx=\"187\" cy=\"116\" r=\"4\" fill=\"#FFF9E9\"/>" : ""
        return "<ellipse cx=\"117\" cy=\"\(leftY)\" rx=\"10\" ry=\"15\" fill=\"\(color)\"/><ellipse cx=\"183\" cy=\"\(rightY)\" rx=\"10\" ry=\"15\" fill=\"\(color)\"/>\(glints)"
    }

    private func mouth(_ curve: String, color: String) -> String {
        "<path d=\"\(curve)\" fill=\"none\" stroke=\"\(color)\" stroke-width=\"6\" stroke-linecap=\"round\"/>"
    }

    private func color(_ value: String?, fallback: String) -> String {
        guard let value, value.hasPrefix("#"), value.count == 7 else { return fallback }
        return value
    }
}
