import DivKit
import Foundation
import UIKit

final class SDUIActionHandler: DivCustomActionHandling, DivUrlHandler {
  weak var hostViewController: DivHostViewController?

  init(hostViewController: DivHostViewController) {
    self.hostViewController = hostViewController
  }

  func handle(payload: DivDictionary, context _: DivActionHandlingContext, sender _: AnyObject?) {
    guard let action = SDUIAction(payload: payload), let hostViewController else {
      return
    }

    switch action {
    case let .toast(text):
      hostViewController.showToast(text)
    case let .open(path, title):
      hostViewController.openScreen(path: path, title: title)
    case let .modal(path, title, style):
      hostViewController.presentModal(path: path, title: title, style: style)
    case let .web(url):
      hostViewController.openWeb(url: url)
    case .reload:
      hostViewController.reload()
    case let .alert(title, message):
      hostViewController.showAlert(title: title, message: message)
    case let .copy(text):
      hostViewController.copyText(text)
    case let .share(text, url):
      hostViewController.share(text: text, url: url)
    case let .track(name):
      hostViewController.track(name: name)
    case .back:
      hostViewController.goBack()
    }
  }

  func handle(_ url: URL, info _: DivActionInfo, sender _: AnyObject?) {
    guard ["http", "https"].contains(url.scheme?.lowercased()), let hostViewController else {
      return
    }
    hostViewController.openWeb(url: url)
  }
}
