import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    self.isMovableByWindowBackground = true
    self.collectionBehavior = [.fullScreenPrimary]

    FilePickerPlugin.register(with: flutterViewController.registrar(forPlugin: "FilePickerPlugin"))

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
