import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(
    _: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let window = UIWindow(frame: UIScreen.main.bounds)
    let rootViewController = DivHostViewController(
      configuration: .root,
      networkClient: DivKitNetworkClient()
    )
    let navigationController = UINavigationController(rootViewController: rootViewController)
    navigationController.navigationBar.prefersLargeTitles = false
    window.rootViewController = navigationController
    window.makeKeyAndVisible()
    self.window = window

    return true
  }
}
