import DivKit
import Foundation
import UIKit

final class SDUIActionHandler: DivCustomActionHandling, DivUrlHandler {
  weak var hostViewController: DivHostViewController?

  init(hostViewController: DivHostViewController) {
    self.hostViewController = hostViewController
  }

  func handle(payload: DivDictionary, context: DivActionHandlingContext, sender _: AnyObject?) {
    guard let action = SDUIAction(payload: payload), let hostViewController else {
      SDUIEventLogger.log("action.ignored", [
        "logId": context.info.logId,
        "payload": payload.description,
      ])
      return
    }

    let result: ActionResult
    switch action {
    case let .toast(text):
      hostViewController.showToast(text)
      result = .success
    case let .open(path, title):
      hostViewController.openScreen(path: path, title: title)
      result = .success
    case let .modal(path, title, style):
      hostViewController.presentModal(path: path, title: title, style: style)
      result = .success
    case let .web(url):
      hostViewController.openWeb(url: url)
      result = .success
    case .reload:
      hostViewController.reload()
      result = .success
    case let .alert(title, message):
      hostViewController.showAlert(title: title, message: message)
      result = .success
    case let .copy(text):
      hostViewController.copyText(text)
      result = .success
    case let .share(text, url):
      result = hostViewController.share(text: text, url: url) ? .success : .ignored
    case let .track(name):
      hostViewController.track(name: name)
      result = .success
    case .back:
      hostViewController.goBack()
      result = .success
    }
    SDUIEventLogger.log("action.\(result.rawValue)", [
      "logId": context.info.logId,
      "action": action.name,
    ])
  }

  func handle(_ url: URL, info _: DivActionInfo, sender _: AnyObject?) {
    guard ["http", "https"].contains(url.scheme?.lowercased()), let hostViewController else {
      return
    }
    hostViewController.openWeb(url: url)
  }
}

private enum ActionResult: String {
  case success
  case ignored
}
