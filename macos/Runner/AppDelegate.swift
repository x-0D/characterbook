import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
    var flutterViewController: FlutterViewController?

    override func applicationDidFinishLaunching(_ notification: Notification) {
        let mainWindow = self.mainFlutterWindow as? MainFlutterWindow
        self.flutterViewController = mainWindow?.contentViewController as? FlutterViewController

        setupMenuHandlers()

        super.applicationDidFinishLaunching(notification)
    }

    func setupMenuHandlers() {
        if let mainMenu = NSApp.mainMenu,
            let appMenu = mainMenu.item(at: 0)?.submenu,
            let preferencesItem = appMenu.item(withTitle: "Preferences…")
        {
            preferencesItem.target = self
            preferencesItem.action = #selector(openPreferences(_:))
        }
    }

    @objc func openPreferences(_ sender: Any?) {
        let channel = FlutterMethodChannel(
            name: "characterbook/menu",
            binaryMessenger: flutterViewController!.engine.binaryMessenger
        )
        channel.invokeMethod("openSettings", arguments: nil)
    }

    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
