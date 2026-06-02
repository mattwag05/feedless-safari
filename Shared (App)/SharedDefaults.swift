import Foundation

enum SharedDefaults {
    static let appGroup = "group.com.mattwagner.feedless-safari"
    static let store: UserDefaults = UserDefaults(suiteName: appGroup) ?? .standard
}
