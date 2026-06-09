import Foundation

enum DivKitNetworkError: LocalizedError {
  case invalidResponse
  case unacceptableStatusCode(Int)
  case emptyData

  var errorDescription: String? {
    switch self {
    case .invalidResponse:
      return "服务端响应无效"
    case let .unacceptableStatusCode(statusCode):
      return "请求失败，状态码 \(statusCode)"
    case .emptyData:
      return "服务端返回了空数据"
    }
  }
}

struct DivKitNetworkResponse {
  let data: Data
  let metadata: SDUIResponseMetadata
}

struct SDUIResponseMetadata {
  let pageId: String?
  let pageVersion: Int?
  let publishedAt: String?
  let statusCode: Int
  let duration: TimeInterval
}

final class DivKitNetworkClient {
  private let session: URLSession

  init(session: URLSession = .shared) {
    self.session = session
  }

  func fetchDivKitData(from url: URL) async throws -> DivKitNetworkResponse {
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.cachePolicy = .reloadIgnoringLocalCacheData
    request.timeoutInterval = AppConfiguration.networkTimeout
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue(String(AppConfiguration.clientVersion), forHTTPHeaderField: "X-SDUI-Client-Version")
    request.setValue("ios", forHTTPHeaderField: "X-SDUI-Platform")
    request.setValue(AppConfiguration.environmentName, forHTTPHeaderField: "X-SDUI-Environment")

    let startedAt = Date()
    SDUIEventLogger.log("network.request", ["url": url.absoluteString])
    let (data, response) = try await session.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw DivKitNetworkError.invalidResponse
    }
    let duration = Date().timeIntervalSince(startedAt)
    SDUIEventLogger.log("network.response", [
      "url": url.absoluteString,
      "status": httpResponse.statusCode,
      "duration": String(format: "%.3f", duration),
    ])
    guard (200..<300).contains(httpResponse.statusCode) else {
      throw DivKitNetworkError.unacceptableStatusCode(httpResponse.statusCode)
    }
    guard !data.isEmpty else {
      throw DivKitNetworkError.emptyData
    }
    return DivKitNetworkResponse(
      data: data,
      metadata: SDUIResponseMetadata(
        pageId: httpResponse.value(forHTTPHeaderField: "X-SDUI-Page-Id"),
        pageVersion: httpResponse.value(forHTTPHeaderField: "X-SDUI-Page-Version").flatMap(Int.init),
        publishedAt: httpResponse.value(forHTTPHeaderField: "X-SDUI-Published-At"),
        statusCode: httpResponse.statusCode,
        duration: duration
      )
    )
  }
}
