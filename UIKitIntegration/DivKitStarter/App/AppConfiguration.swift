import DivKit
import Foundation

struct AppConfiguration {
  static let clientVersion = 1
  static let supportedCapabilities: Set<String> = [
    "toast",
    "open",
    "modal",
    "web",
    "reload",
    "alert",
    "copy",
    "share",
    "track",
    "back",
  ]

  static var environmentName: String {
    (Bundle.main.object(forInfoDictionaryKey: "API_ENV") as? String) ?? "local"
  }

  static var apiBaseURL: URL {
    if
      let value = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
      let url = URL(string: value),
      !value.isEmpty {
      return url
    }
    return URL(string: "http://localhost:3000/api/")!
  }

  static var networkTimeout: TimeInterval {
    15
  }

  static var cacheTTL: TimeInterval {
    60 * 60
  }

  static var isDivKitDebugEnabled: Bool {
    #if DEBUG
    true
    #else
    false
    #endif
  }
}

struct DivScreenConfiguration {
  let endpoint: URL
  let cardId: DivCardID
  let title: String

  static let root = DivScreenConfiguration(
    endpoint: AppConfiguration.apiBaseURL,
    cardId: DivCardID(rawValue: "root"),
    title: "DivKit"
  )

  init(endpoint: URL, cardId: DivCardID, title: String) {
    self.endpoint = endpoint
    self.cardId = cardId
    self.title = title
  }

  init(path: String, title: String? = nil) {
    let normalizedPath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    let url = AppConfiguration.apiBaseURL.appendingAPIPath(normalizedPath)
    self.init(
      endpoint: url,
      cardId: DivCardID(rawValue: normalizedPath.isEmpty ? "root" : normalizedPath),
      title: title ?? "DivKit"
    )
  }
}

private extension URL {
  func appendingAPIPath(_ path: String) -> URL {
    guard !path.isEmpty else {
      return self
    }

    if absoluteString.hasSuffix("/") {
      return appendingPathComponent(path)
    }
    return URL(string: absoluteString + "/" + path)!
  }
}
