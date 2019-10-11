import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let windowManager = WindowManager()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        windowManager.tryRegisteringKeyMonitoring()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

