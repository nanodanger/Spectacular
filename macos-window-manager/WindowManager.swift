import Cocoa
import Carbon

enum MoveTypes {
    case leftHalf
    case rightHalf
    case fullSize
}

struct KeyboardKeys {
    static let upArrow: UInt16 = 0x7E
    static let rightArrow: UInt16 = 0x7C
    static let leftArrow: UInt16 = 0x7B
    static let f: UInt16 = 0x03
}

func myCGEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    
    if [.keyDown , .keyUp].contains(type) {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        if event.flags.contains(.maskCommand) && event.flags.contains(.maskAlternate) && keyCode == KeyboardKeys.leftArrow {
            if [.keyDown].contains(type) {
                WindowManager.shared.moveWindow(to: .leftHalf)
                NSLog("Found shortcut btw")
            }
            return nil
            
        } else if event.flags.contains(.maskCommand) && event.flags.contains(.maskAlternate) && keyCode == KeyboardKeys.rightArrow {
            if [.keyDown].contains(type) {
                WindowManager.shared.moveWindow(to: .rightHalf)
            }
            return nil
            
        } else if event.flags.contains(.maskCommand) && event.flags.contains(.maskAlternate) && keyCode == KeyboardKeys.f {
            if [.keyDown].contains(type) {
                WindowManager.shared.moveWindow(to: .fullSize)
            }
            return nil
        }
    }
    return Unmanaged.passRetained(event)
}

class WindowManager {
    private var windowMover = StandardWindowMover()
    
    static let shared = WindowManager();
    
    init() {}
    
    private static var didRegisterKeyMonitoring = false
    private var didShowAXPopup = false
    
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
    
    private func registerKeyMonitoring() {
        if !WindowManager.didRegisterKeyMonitoring {
            WindowManager.didRegisterKeyMonitoring = true;
            NSLog("WindowMover.registerKeyMonitoring: Registering key-press monitoring\n")

            let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
            guard let eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                                   place: .headInsertEventTap,
                                                   options: .defaultTap,
                                                   eventsOfInterest: CGEventMask(eventMask),
                                                   callback: myCGEventCallback,
                                                   userInfo: nil) else {
                                                    NSLog("Error: Failed to create event tap")
                                                    exit(1)
            }
            
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
            CFRunLoopRun()
        }
    }
    
    func moveWindow(to moveType: MoveTypes) {
        if WindowManager.didRegisterKeyMonitoring {
            switch moveType {
            case .leftHalf:
                moveToLeftHalf()
            case .rightHalf:
                moveToRightHalf()
            case .fullSize:
                fullSize()
            }
        }
    }
    
    private func fullSize() {
        if let w = frontWindow {
            NSLog("WindowMover.fullSize: Full size window\n")
            windowMover.fullSize(window: w)
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
        if event.keyCode == KeyboardKeys.leftArrow && event.modifierFlags.contains(.command) && event.modifierFlags.contains(.shift) {
            NSLog("WindowManager.handleKeyPress: received key press Cmd + Shift + <-\n");
            moveWindow(to: .leftHalf)
        }
        
        // right arrow && command and shift
        if event.keyCode == KeyboardKeys.rightArrow && event.modifierFlags.contains(.command) && event.modifierFlags.contains(.shift) {
            NSLog("WindowManager.handleKeyPress: received key press Cmd + Shift + ->\n");
            moveWindow(to: .rightHalf)
        }
        
        // Cmd + Option + f
        if(event.keyCode == KeyboardKeys.f && event.modifierFlags.contains(.command) && event.modifierFlags.contains(.option)) {
            NSLog("WindowManager.handleKeyPress: received key press Cmd + Optin + f\n");
            moveWindow(to: .fullSize)
            
        }
    }
    
    func checkAccess(showPopup: Bool) -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: showPopup]
        return AXIsProcessTrustedWithOptions(options as CFDictionary?)
    }
    
    public func tryRegisteringKeyMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
            if self.checkAccess(showPopup: !self.didShowAXPopup) {
                self.registerKeyMonitoring()
                timer.invalidate()
            }
            self.didShowAXPopup = true
        }
    }
}
