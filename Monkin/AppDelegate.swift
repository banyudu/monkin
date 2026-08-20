import AppKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var petWindow: PetWindowController!
    private var benchmarkWindow: MotionBenchmarkWindowController?
    private var statusItem: NSStatusItem!

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
        installStatusItem()
        // Order the floating pet without activating Monkin or stealing the
        // key window from the editor that launched/restarted it.
        petWindow.window?.orderFrontRegardless()
    }

    private func installStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "🐒"
        let menu = NSMenu()
        let benchmarkItem = NSMenuItem(title: "Open Motion Benchmark",
                                       action: #selector(openMotionBenchmark),
                                       keyEquivalent: "b")
        benchmarkItem.target = self
        menu.addItem(benchmarkItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit Monkin",
                                action: #selector(NSApplication.terminate(_:)),
                                keyEquivalent: "q"))
        statusItem.menu = menu
    }

    @objc private func openMotionBenchmark() {
        if benchmarkWindow == nil {
            benchmarkWindow = MotionBenchmarkWindowController()
        }
        benchmarkWindow?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
