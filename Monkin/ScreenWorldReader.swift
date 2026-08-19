import AppKit

enum ScreenWorldItemKind {
    case window
    case accessibilityElement
}

struct ScreenWorldItem {
    let kind: ScreenWorldItemKind
    let label: String
    let role: String?
    let application: String?
    let screenRect: CGRect

    var isSemanticTarget: Bool {
        guard kind == .accessibilityElement, let role else { return false }
        return ["AXButton", "AXCheckBox", "AXRadioButton", "AXSlider", "AXTextField", "AXMenuItem", "AXPopUpButton"].contains(role)
    }
}

final class ScreenWorldReader {
    private let queue = DispatchQueue(label: "com.banyudu.monkin.screen-world")

    func requestAccessibilityAccess() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    /// Reads lightweight metadata only. No pixels are captured here.
    func read(completion: @escaping ([ScreenWorldItem]) -> Void) {
        queue.async {
            var items = self.readWindows()
            items.append(contentsOf: self.readFrontmostAccessibilityElements())
            DispatchQueue.main.async { completion(items) }
        }
    }

    private func readWindows() -> [ScreenWorldItem] {
        guard let windowInfo = CGWindowListCopyWindowInfo(
            [.optionOnScreenOnly, .excludeDesktopElements],
            kCGNullWindowID
        ) as? [[String: Any]] else { return [] }

        return windowInfo.compactMap { info in
            guard let boundsDictionary = info[kCGWindowBounds as String] as? NSDictionary else { return nil }
            var bounds = CGRect.zero
            guard CGRectMakeWithDictionaryRepresentation(boundsDictionary, &bounds),
                  bounds.width > 80, bounds.height > 40 else { return nil }
            let title = info[kCGWindowName as String] as? String ?? ""
            let owner = info[kCGWindowOwnerName as String] as? String
            return ScreenWorldItem(kind: .window,
                                   label: title,
                                   role: nil,
                                   application: owner,
                                   screenRect: ScreenWorldReader.appKitRect(fromQuartz: bounds))
        }
    }

    private func readFrontmostAccessibilityElements() -> [ScreenWorldItem] {
        guard let app = NSWorkspace.shared.frontmostApplication else { return [] }
        let element = AXUIElementCreateApplication(app.processIdentifier)
        var windowsValue: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, kAXWindowsAttribute as CFString, &windowsValue) == .success,
              let windows = windowsValue as? [AXUIElement] else { return [] }

        return windows.flatMap { readElements(in: $0, application: app.localizedName, depth: 0) }
    }

    private func readElements(in element: AXUIElement, application: String?, depth: Int) -> [ScreenWorldItem] {
        guard depth < 5 else { return [] }
        var roleValue: CFTypeRef?
        var titleValue: CFTypeRef?
        var valueValue: CFTypeRef?
        var positionValue: CFTypeRef?
        var sizeValue: CFTypeRef?
        _ = AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &roleValue)
        _ = AXUIElementCopyAttributeValue(element, kAXTitleAttribute as CFString, &titleValue)
        _ = AXUIElementCopyAttributeValue(element, kAXValueAttribute as CFString, &valueValue)
        _ = AXUIElementCopyAttributeValue(element, kAXPositionAttribute as CFString, &positionValue)
        _ = AXUIElementCopyAttributeValue(element, kAXSizeAttribute as CFString, &sizeValue)

        let role = roleValue as? String
        let title = (titleValue as? String) ?? (valueValue as? String) ?? ""
        var items: [ScreenWorldItem] = []
        if let role, !title.isEmpty, let rect = rect(position: positionValue, size: sizeValue) {
            items.append(ScreenWorldItem(kind: .accessibilityElement,
                                         label: title,
                                         role: role,
                                         application: application,
                                         screenRect: rect))
        }

        var childrenValue: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &childrenValue) == .success,
           let children = childrenValue as? [AXUIElement] {
            for child in children {
                items.append(contentsOf: readElements(in: child, application: application, depth: depth + 1))
            }
        }
        return items
    }

    private func rect(position: CFTypeRef?, size: CFTypeRef?) -> CGRect? {
        guard let positionRef = position, let sizeRef = size else { return nil }
        let position = positionRef as! AXValue
        let size = sizeRef as! AXValue
        var point = CGPoint.zero
        var dimensions = CGSize.zero
        guard AXValueGetValue(position, .cgPoint, &point), AXValueGetValue(size, .cgSize, &dimensions),
              dimensions.width > 4, dimensions.height > 4 else { return nil }
        return ScreenWorldReader.appKitRect(fromQuartz: CGRect(origin: point, size: dimensions))
    }

    private static func appKitRect(fromQuartz rect: CGRect) -> CGRect {
        let mainMaxY = NSScreen.screens.first?.frame.maxY ?? 0
        return CGRect(x: rect.minX,
                      y: mainMaxY - rect.maxY,
                      width: rect.width,
                      height: rect.height)
    }
}
