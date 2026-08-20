import Foundation

struct MonkinPose: Equatable {
    var bodyBob: CGFloat = 0
    var bodyScaleX: CGFloat = 1
    var bodyScaleY: CGFloat = 1
    var headRotation: CGFloat = 0
    var headOffsetY: CGFloat = 0
    var headScaleX: CGFloat = 1
    var headScaleY: CGFloat = 1
    var leftArmRotation: CGFloat = 0
    var rightArmRotation: CGFloat = 0
    var leftArmOffsetY: CGFloat = 0
    var rightArmOffsetY: CGFloat = 0
    var leftLegRotation: CGFloat = 0
    var rightLegRotation: CGFloat = 0
    var tailRotation: CGFloat = 0

    static let neutral = MonkinPose()
}
