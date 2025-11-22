import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    override func applicationWillFinishLaunching(_ notification: Notification) {
        if let menu = super.applicationMenu {
            NSApplication.shared.mainMenu = menu
        }
        super.applicationWillFinishLaunching(notification)
    }

    override func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NSApp.activate(ignoringOtherApps: true)

            if let window = self.mainFlutterWindow {
                window.makeKeyAndOrderFront(nil)
                window.center()
                window.orderFrontRegardless()
            }
        }

        super.applicationDidFinishLaunching(notification)
    }

    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    @IBAction func showAboutPanel(_ sender: Any?) {
        NSApp.orderFrontStandardAboutPanel(sender)
    }

    @IBAction func openFile(_ sender: Any?) {
        print("Open file menu item clicked")
    }
}