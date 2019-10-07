//
//  ViewController.swift
//  macos-window-manager
//
//  Created by Tamas Sule on 2019. 10. 07..
//  Copyright © 2019. Tamas Sule. All rights reserved.
//

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
                
                if let wList = value as? [AXUIElement] {
                    
                    for w in wList {
                        var isMainWindow: AnyObject?
                        AXUIElementCopyAttributeValue(w, kAXMainAttribute as CFString, &isMainWindow)
                        
                        var windowTitle: AnyObject?
                        AXUIElementCopyAttributeValue(w, kAXTitleAttribute as CFString, &windowTitle)
                        
                        NSLog("Window title: %@, Is focused %@\n", windowTitle as! NSString, isMainWindow as! Bool ? "yes" : "no")
                        
                        if isMainWindow as! Bool == true  {
                            var position : CFTypeRef
                            var size : CFTypeRef
                            var newPoint = CGPoint(x: 0, y: 0)
                            let screenFrame = NSScreen.main!.frame;
                            var newSize = CGSize(width: screenFrame.width / 2, height: screenFrame.height)
                            
                            NSLog("Window title: %@\n", windowTitle as! NSString)
                            
                            position = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!,&newPoint)!;
                            AXUIElementSetAttributeValue(w, kAXPositionAttribute as CFString, position);
                            
                            size = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!,&newSize)!;
                            AXUIElementSetAttributeValue(w, kAXSizeAttribute as CFString, size);
                        }
                    }
                }
            }
        }
    }
    
    func handeKeyPress(event: NSEvent) -> Void {
        // right arrow && command and shift
        NSLog("Key pressed\n");
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

