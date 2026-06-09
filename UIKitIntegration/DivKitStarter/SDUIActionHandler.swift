import DivKit
import Foundation
import UIKit

final class SDUIActionHandler: DivUrlHandler {
  weak var hostViewController: DivHostViewController?
  private let pageNamePattern = #"^[a-zA-Z0-9_-]+$"#

  init(hostViewController: DivHostViewController) {
    self.hostViewController = hostViewController
  }

  func handle(_ url: URL, info _: DivActionInfo, sender _: AnyObject?) {
    guard url.scheme == "sdui" else {
      return
    }

    switch url.host {
    case "toast":
      showToast(url: url)
    case "open":
      openScreen(url: url)
    case "back":
      hostViewController?.goBack()
    default:
      return
    }
  }

  private func showToast(url: URL) {
    guard let hostViewController else {
      return
    }
    let message = url.queryValue(for: "text")
      ?? url.queryValue(for: "message")
      ?? url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    hostViewController.showToast(message.isEmpty ? "提示" : message)
  }

  private func openScreen(url: URL) {
    guard let hostViewController else {
      return
    }
    let path = url.queryValue(for: "path")
      ?? url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    guard !path.isEmpty, path.range(of: pageNamePattern, options: .regularExpression) != nil else {
      hostViewController.showToast("页面路径无效")
      return
    }
    let title = url.queryValue(for: "title")
    hostViewController.openScreen(path: path, title: title)
  }
}

private extension URL {
  func queryValue(for name: String) -> String? {
    URLComponents(url: self, resolvingAgainstBaseURL: false)?
      .queryItems?
      .first(where: { $0.name == name })?
      .value
  }
}
