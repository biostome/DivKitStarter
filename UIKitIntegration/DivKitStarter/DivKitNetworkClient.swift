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

final class DivKitNetworkClient {
  private let session: URLSession

  init(session: URLSession = .shared) {
    self.session = session
  }

  func fetchDivKitData(from url: URL) async throws -> Data {
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.cachePolicy = .reloadIgnoringLocalCacheData
    request.timeoutInterval = 15
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    let startedAt = Date()
    log("GET \(url.absoluteString)")
    let (data, response) = try await session.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw DivKitNetworkError.invalidResponse
    }
    log("GET \(url.absoluteString) -> \(httpResponse.statusCode) in \(Date().timeIntervalSince(startedAt))s")
    guard (200..<300).contains(httpResponse.statusCode) else {
      throw DivKitNetworkError.unacceptableStatusCode(httpResponse.statusCode)
    }
    guard !data.isEmpty else {
      throw DivKitNetworkError.emptyData
    }
    return data
  }

  private func log(_ message: String) {
    #if DEBUG
    print("[DivKitNetwork] \(message)")
    #endif
  }
}
