import AppKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var petWindow: PetWindowController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        petWindow = PetWindowController()
        petWindow.showWindow(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
