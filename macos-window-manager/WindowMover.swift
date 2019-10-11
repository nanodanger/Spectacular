import Foundation

protocol WindowMover {
    func moveToLeftHalf(window: AXUIElement)
    func moveToRightHalf(window: AXUIElement)
    func fullSize(window: AXUIElement)
}
