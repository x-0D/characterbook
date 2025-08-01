import FlutterMacOS
import AppKit

public class FilePickerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "file_picker",
            binaryMessenger: registrar.messenger
        )
        let instance = FilePickerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "pickFile":
            handlePickFile(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handlePickFile(call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            let panel = NSOpenPanel()
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            panel.allowsMultipleSelection = false
            
            if let args = call.arguments as? [String: Any],
               let extensions = args["fileExtension"] as? String {
                let fileTypes = extensions
                    .replacingOccurrences(of: ".", with: "")
                    .components(separatedBy: ",")
                    .filter { !$0.isEmpty }
                panel.allowedFileTypes = fileTypes
            } else {
                panel.allowedFileTypes = ["json", "characterbook", "character", "race", "chax"]
            }
            
            let response = panel.runModal()
            if response == .OK, let url = panel.urls.first {
                result(url.path)
            } else {
                result(nil)
            }
        }
    }
}