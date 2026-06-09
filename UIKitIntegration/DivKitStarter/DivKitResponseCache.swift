import Foundation

final class DivKitResponseCache {
  static let shared = DivKitResponseCache()

  private let directoryURL: URL

  init(fileManager: FileManager = .default) {
    let cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    directoryURL = cachesURL.appendingPathComponent("DivKitResponses", isDirectory: true)
    try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
  }

  func data(for cardId: String) -> Data? {
    try? Data(contentsOf: fileURL(for: cardId))
  }

  func store(_ data: Data, for cardId: String) {
    try? data.write(to: fileURL(for: cardId), options: .atomic)
  }

  private func fileURL(for cardId: String) -> URL {
    let safeName = cardId
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: ":", with: "_")
    return directoryURL.appendingPathComponent("\(safeName).json")
  }
}
