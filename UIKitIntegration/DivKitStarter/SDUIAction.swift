import Foundation

enum SDUIAction {
  case toast(text: String)
  case open(path: String, title: String?)
  case back

  init?(url: URL) {
    guard url.scheme == "sdui" else {
      return nil
    }

    switch url.host {
    case "toast":
      let message = url.queryValue(for: "text")
        ?? url.queryValue(for: "message")
        ?? url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
      self = .toast(text: message.isEmpty ? "提示" : message)
    case "open":
      let path = url.queryValue(for: "path")
        ?? url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
      guard SDUIAction.isValidPagePath(path) else {
        return nil
      }
      self = .open(path: path, title: url.queryValue(for: "title"))
    case "back":
      self = .back
    default:
      return nil
    }
  }

  static func isValidPagePath(_ path: String) -> Bool {
    !path.isEmpty && path.range(of: #"^[a-zA-Z0-9_-]+$"#, options: .regularExpression) != nil
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
