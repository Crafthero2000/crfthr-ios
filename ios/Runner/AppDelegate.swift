import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let window = UIWindow(frame: UIScreen.main.bounds)

    let dashboard = DashboardViewController(style: .insetGrouped)
    let calculator = CalculatorViewController()
    let settings = SettingsViewController(style: .insetGrouped)

    let dashboardNav = UINavigationController(rootViewController: dashboard)
    dashboardNav.navigationBar.prefersLargeTitles = true
    dashboardNav.tabBarItem = UITabBarItem(
      title: "Дашборд",
      image: UIImage(systemName: "chart.bar"),
      tag: 0
    )

    let calculatorNav = UINavigationController(rootViewController: calculator)
    calculatorNav.navigationBar.prefersLargeTitles = true
    calculatorNav.tabBarItem = UITabBarItem(
      title: "Калькулятор",
      image: UIImage(systemName: "plus.slash.minus"),
      tag: 1
    )

    let settingsNav = UINavigationController(rootViewController: settings)
    settingsNav.navigationBar.prefersLargeTitles = true
    settingsNav.tabBarItem = UITabBarItem(
      title: "Настройки",
      image: UIImage(systemName: "gear"),
      tag: 2
    )

    let tabBar = UITabBarController()
    tabBar.viewControllers = [dashboardNav, calculatorNav, settingsNav]
    window.rootViewController = tabBar
    window.makeKeyAndVisible()
    self.window = window
    return true
  }
}
