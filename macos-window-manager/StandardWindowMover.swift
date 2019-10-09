import Cocoa

class StandardWindowMover: WindowMover {
    
    func moveToLeftHalf(window: AXUIElement) {
        let screenFrame = NSScreen.main!.frame;
        var newSize = CGSize(width: screenFrame.width / 2, height: screenFrame.height)
        
        var position : CFTypeRef
        var size : CFTypeRef
        var newPoint = CGPoint(x: 0, y: 0)
        
        position = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!,&newPoint)!;
        AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, position);
        
        size = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!,&newSize)!;
        AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, size);
    }
    
    func moveToRightHalf(window: AXUIElement) {
        let screenFrame = NSScreen.main!.frame;
        var newSize = CGSize(width: screenFrame.width / 2, height: screenFrame.height)
        
        var position : CFTypeRef
        var size : CFTypeRef
        var newPoint = CGPoint(x: screenFrame.width / 2, y: 0)
        
        position = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!,&newPoint)!;
        AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, position);
        
        size = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!,&newSize)!;
        AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, size);
    }
}
