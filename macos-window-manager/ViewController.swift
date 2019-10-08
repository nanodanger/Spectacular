import Cocoa

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !checkAccess() {
            NSLog("No access\n");
        }
        
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: self.handeKeyPress(event:))
    }
    
    func moveFrontWindow() {
        if let frontApp = NSWorkspace.shared.frontmostApplication {
            if frontApp.isActive {
                NSLog("Active app name: %@", frontApp.localizedName!)
                let appRef = AXUIElementCreateApplication(frontApp.processIdentifier)
                var value: AnyObject?
                AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute as CFString, &value)
                AXUIElementCopyAttributeValue(appRef, kAXFocusedWindowAttribute as CFString, &value);
                
                if let window = value as! AXUIElement? {
                    var position : CFTypeRef
                    var size : CFTypeRef
                    var newPoint = CGPoint(x: 0, y: 0)
                    let screenFrame = NSScreen.main!.frame;
                    var newSize = CGSize(width: screenFrame.width / 2, height: screenFrame.height)
                    
                    //NSLog("Window title: %@\n", windowTitle as! NSString)
                    
                    position = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!,&newPoint)!;
                    AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, position);
                    
                    size = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!,&newSize)!;
                    AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, size);
                }
            }
        }
    }
    
    func handeKeyPress(event: NSEvent) -> Void {
        // right arrow && command and shift
        if event.keyCode == 0x7C && event.modifierFlags.contains(.command) && event.modifierFlags.contains(.shift) {
            NSLog("Shortcut found\n");
            moveFrontWindow();
        }
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    public func checkAccess() -> Bool{
        //set the options: false means it wont ask
        //true means it will popup and ask
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: true]
        //translate into boolean value
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary?)
        return accessEnabled
    }
    
    
}

