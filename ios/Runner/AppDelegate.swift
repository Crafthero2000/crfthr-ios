import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let window = UIWindow(frame: UIScreen.main.bounds)
    let root = GlassViewController(style: .insetGrouped)
    let navigation = UINavigationController(rootViewController: root)
    navigation.navigationBar.prefersLargeTitles = true
    window.rootViewController = navigation
    window.makeKeyAndVisible()
    self.window = window
    return true
  }
}
