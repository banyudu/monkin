import AppKit

final class MonkinSVGRenderer {
    func image(for spec: MonkinFigureSpec) -> NSImage? {
        image(for: spec, pose: .neutral)
    }

    func image(for spec: MonkinFigureSpec, pose: MonkinPose) -> NSImage? {
        let svg = render(spec, pose: pose)
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
        render(spec, pose: .neutral)
    }

    func render(_ spec: MonkinFigureSpec, pose: MonkinPose) -> String {
        let accent = color(spec.colors["accent"], fallback: "#4A7772")
        let layers = [
            material("eyes", named: spec.eyes),
            material("brows", named: spec.brows),
            material("mouth", named: spec.mouth),
            material("cheeks", named: spec.cheeks ?? "none")
        ].joined()

        let accessories = spec.accessories.map { material("accessory", named: $0, accent: accent) }.joined()
        return """
        <svg xmlns="http://www.w3.org/2000/svg" width="300" height="300" viewBox="0 0 300 300">
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
          <ellipse cx="150" cy="286" rx="78" ry="9" fill="#17171B" opacity="0.16"/>
          <g filter="url(#shadow)">
            <g transform="translate(0 \(pose.bodyBob)) translate(150 190) scale(\(pose.bodyScaleX) \(pose.bodyScaleY)) translate(-150 -190)">
              <g transform="translate(199 164) rotate(\(pose.tailRotation))">
                <path d="M0 0 Q42 -4 56 29 Q72 66 48 92 Q35 106 20 100" fill="none" stroke="#704027" stroke-width="18" stroke-linecap="round"/>
                <path d="M3 0 Q39 0 51 30" fill="none" stroke="#C48751" stroke-width="5" stroke-linecap="round" opacity="0.7"/>
              </g>
              <path d="M103 145 Q150 119 197 145 L198 229 Q183 253 150 255 Q117 253 102 229Z" fill="url(#fur)" stroke="#2B2522" stroke-width="7"/>
              <path d="M126 150 Q150 137 174 150 L176 217 Q150 236 124 217Z" fill="url(#muzzle)" opacity="0.86"/>
              <g transform="translate(105 \(151 + pose.leftArmOffsetY)) rotate(\(pose.leftArmRotation))">
                <path d="M0 0 Q-15 25 -18 63 Q-15 76 -5 71 Q1 46 20 25Z" fill="url(#fur)" stroke="#2B2522" stroke-width="7" stroke-linejoin="round"/>
                <ellipse cx="-10" cy="70" rx="14" ry="11" fill="#D7A66B" stroke="#2B2522" stroke-width="5"/>
              </g>
              <g transform="translate(195 \(151 + pose.rightArmOffsetY)) rotate(\(pose.rightArmRotation))">
                <path d="M0 0 Q15 25 18 63 Q15 76 5 71 Q-1 46 -20 25Z" fill="url(#fur)" stroke="#2B2522" stroke-width="7" stroke-linejoin="round"/>
                <ellipse cx="10" cy="70" rx="14" ry="11" fill="#D7A66B" stroke="#2B2522" stroke-width="5"/>
              </g>
              <g transform="translate(125 236) rotate(\(pose.leftLegRotation))">
                <path d="M0 0 Q-3 17 -2 31" fill="none" stroke="#704027" stroke-width="25" stroke-linecap="round"/>
                <ellipse cx="-2" cy="38" rx="25" ry="12" fill="#A96235" stroke="#2B2522" stroke-width="6"/>
              </g>
              <g transform="translate(175 236) rotate(\(pose.rightLegRotation))">
                <path d="M0 0 Q3 17 2 31" fill="none" stroke="#704027" stroke-width="25" stroke-linecap="round"/>
                <ellipse cx="2" cy="38" rx="25" ry="12" fill="#A96235" stroke="#2B2522" stroke-width="6"/>
              </g>
            </g>
            <g transform="translate(0 \(pose.bodyBob + pose.headOffsetY)) translate(150 150) rotate(\(pose.headRotation)) scale(\(pose.headScaleX) \(pose.headScaleY)) translate(-150 -150)">
              <path d="M91 76 C84 53 102 38 125 50 Q150 31 175 50 C198 38 216 53 209 76 Q231 95 225 132 C219 169 188 190 150 190 C112 190 81 169 75 132 Q69 95 91 76Z" fill="url(#fur)" stroke="#2B2522" stroke-width="7" stroke-linejoin="round"/>
              <ellipse cx="67" cy="111" rx="25" ry="31" fill="#B97A4D" stroke="#2B2522" stroke-width="7"/>
              <ellipse cx="233" cy="111" rx="25" ry="31" fill="#B97A4D" stroke="#2B2522" stroke-width="7"/>
              <path d="M57 111 Q67 99 77 111 Q67 123 57 111Z" fill="#4A7772" stroke="#2B2522" stroke-width="4"/>
              <path d="M223 111 Q233 99 243 111 Q233 123 223 111Z" fill="#4A7772" stroke="#2B2522" stroke-width="4"/>
              <path d="M123 55 Q137 37 150 51 Q164 36 178 56 Q164 65 150 60 Q136 65 123 55Z" fill="#C88750" stroke="#2B2522" stroke-width="5" stroke-linejoin="round"/>
              <ellipse cx="150" cy="139" rx="57" ry="39" fill="url(#muzzle)" stroke="#2B2522" stroke-width="5"/>
            \(layers)
            \(accessories)
            </g>
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
