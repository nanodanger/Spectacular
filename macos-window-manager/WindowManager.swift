import Cocoa

enum MoveTypes {
    case leftHalf
    case rightHalf
}

struct ArrowKeys {
    static let right: UInt16 = 0x7C
    static let left: UInt16 = 0x7B
}

class WindowManager {
    private var windowMover = StandardWindowMover()
    
    private static var didRegisterKeyMonitoring = false;
    
    private var frontWindow: AXUIElement? {
        get {
            if let frontApp = NSWorkspace.shared.frontmostApplication {
                if frontApp.isActive {
                    if let frontApp = NSWorkspace.shared.frontmostApplication {
                        if frontApp.isActive {
                            NSLog("Active app name: %@", frontApp.localizedName!)
                            let appRef = AXUIElementCreateApplication(frontApp.processIdentifier)
                            var window: AnyObject?
                            AXUIElementCopyAttributeValue(appRef, kAXFocusedWindowAttribute as CFString, &window);
                            return window as! AXUIElement?
                        }
                    }
                }
            }
            return nil;
        }
    }
    
    func registerKeyMonitoring() {
        if checkAccess() && !WindowManager.didRegisterKeyMonitoring {
            WindowManager.didRegisterKeyMonitoring = true;
            NSLog("WindowMover.registerKeyMonitoring: Registering key-press monitoring\n")
            NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: handleKeyPress(event:))
        }
    }
    
    private func moveWindow(to moveType: MoveTypes) {
        if WindowManager.didRegisterKeyMonitoring {
            switch moveType {
            case .leftHalf:
                moveToLeftHalf()
            case .rightHalf:
                moveToRightHalf()
            }
        }
    }
    
    private func moveToRightHalf() {
        if let w = frontWindow {
            NSLog("WindowManager.moveToRightHalf: Moving window to right half\n");
            windowMover.moveToRightHalf(window: w)
        }
    }
    
    private func moveToLeftHalf() {
        if let w = frontWindow {
            NSLog("WindowManager.moveToLeftHalf: Moving window to left half\n");
            windowMover.moveToLeftHalf(window: w)
        }
    }
    
    private func handleKeyPress(event: NSEvent) -> Void {
        // left arrow && command and shift
        if event.keyCode == ArrowKeys.left && event.modifierFlags.contains(.command) && event.modifierFlags.contains(.shift) {
            NSLog("WindowManager.handleKeyPress: received key press Cmd + Shift + <-\n");
            moveWindow(to: .leftHalf)
        }
        
        // right arrow && command and shift
        if event.keyCode == ArrowKeys.right && event.modifierFlags.contains(.command) && event.modifierFlags.contains(.shift) {
            NSLog("WindowManager.handleKeyPress: received key press Cmd + Shift + ->\n");
            moveWindow(to: .rightHalf)
        }
    }
    
    private func checkAccess() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: true]
        return AXIsProcessTrustedWithOptions(options as CFDictionary?)
    }
}
