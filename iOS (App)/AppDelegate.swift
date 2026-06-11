import UIKit
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ app: UIApplication, didFinishLaunchingWithOptions opts: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        PlatformConfig.seedDefaults()
        let win = UIWindow(frame: UIScreen.main.bounds)
        win.rootViewController = UIHostingController(rootView: SettingsView())
        win.makeKeyAndVisible()
        self.window = win
        return true
    }
}
