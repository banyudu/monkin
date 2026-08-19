import AppKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var petWindow: PetWindowController!

    static func main() {
        let application = NSApplication.shared
        let delegate = AppDelegate()
        application.delegate = delegate
        withExtendedLifetime(delegate) {
            application.run()
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        petWindow = PetWindowController()
        // Order the floating pet without activating Monkin or stealing the
        // key window from the editor that launched/restarted it.
        petWindow.window?.orderFrontRegardless()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
