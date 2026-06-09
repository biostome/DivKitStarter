import DivKit
import Foundation
import UIKit

final class SDUIActionHandler: DivUrlHandler {
  weak var hostViewController: DivHostViewController?

  init(hostViewController: DivHostViewController) {
    self.hostViewController = hostViewController
  }

  func handle(_ url: URL, info _: DivActionInfo, sender _: AnyObject?) {
    guard let action = SDUIAction(url: url), let hostViewController else {
      return
    }

    switch action {
    case let .toast(text):
      hostViewController.showToast(text)
    case let .open(path, title):
      hostViewController.openScreen(path: path, title: title)
    case .back:
      hostViewController.goBack()
    }
  }
}
