import UIKit

enum HapticService {
    static let light = UIImpactFeedbackGenerator(style: .light)
    static let medium = UIImpactFeedbackGenerator(style: .medium)
    static let heavy = UIImpactFeedbackGenerator(style: .heavy)
    static let notification = UINotificationFeedbackGenerator()
    static let selection = UISelectionFeedbackGenerator()
}
