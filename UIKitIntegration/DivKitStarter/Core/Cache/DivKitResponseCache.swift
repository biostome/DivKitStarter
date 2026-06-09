import Foundation

final class DivKitResponseCache {
  static let shared = DivKitResponseCache()

  private let directoryURL: URL
  private let fileManager: FileManager

  init(fileManager: FileManager = .default) {
    self.fileManager = fileManager
    let cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    directoryURL = cachesURL.appendingPathComponent("DivKitResponses", isDirectory: true)
    try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
  }

  func data(for cardId: String, maxAge: TimeInterval = AppConfiguration.cacheTTL) -> Data? {
    guard let metadata = metadata(for: cardId) else {
      return nil
    }
    guard Date().timeIntervalSince(metadata.storedAt) <= maxAge else {
      SDUIEventLogger.log("cache.expired", ["cardId": cardId])
      return nil
    }
    SDUIEventLogger.log("cache.hit", [
      "cardId": cardId,
      "age": String(format: "%.0f", Date().timeIntervalSince(metadata.storedAt)),
      "version": metadata.pageVersion,
    ])
    return try? Data(contentsOf: fileURL(for: cardId))
  }

  func store(_ data: Data, for cardId: String, responseMetadata: SDUIResponseMetadata? = nil) {
    try? data.write(to: fileURL(for: cardId), options: .atomic)
    let metadata = CacheMetadata(
      storedAt: Date(),
      pageId: responseMetadata?.pageId,
      pageVersion: responseMetadata?.pageVersion,
      publishedAt: responseMetadata?.publishedAt
    )
    if let metadataData = try? JSONEncoder().encode(metadata) {
      try? metadataData.write(to: metadataURL(for: cardId), options: .atomic)
    }
    SDUIEventLogger.log("cache.store", ["cardId": cardId, "version": metadata.pageVersion])
  }

  private func fileURL(for cardId: String) -> URL {
    cacheURL(for: cardId, extension: "json")
  }

  private func metadataURL(for cardId: String) -> URL {
    cacheURL(for: cardId, extension: "meta.json")
  }

  private func cacheURL(for cardId: String, extension pathExtension: String) -> URL {
    let safeName = cardId
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: ":", with: "_")
    return directoryURL.appendingPathComponent("\(safeName).\(pathExtension)")
  }

  private func metadata(for cardId: String) -> CacheMetadata? {
    guard let data = try? Data(contentsOf: metadataURL(for: cardId)) else {
      if fileManager.fileExists(atPath: fileURL(for: cardId).path) {
        return CacheMetadata(storedAt: .distantPast, pageId: nil, pageVersion: nil, publishedAt: nil)
      }
      return nil
    }
    return try? JSONDecoder().decode(CacheMetadata.self, from: data)
  }
}

private struct CacheMetadata: Codable {
  let storedAt: Date
  let pageId: String?
  let pageVersion: Int?
  let publishedAt: String?
}
