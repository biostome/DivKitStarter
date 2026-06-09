import Foundation

struct SDUIPageResponse {
  let divKitData: Data
  let metadata: SDUIPageMetadata?

  init(data: Data) throws {
    guard
      let object = try JSONSerialization.jsonObject(with: data) as? [String: Any],
      let pageObject = object["page"] as? [String: Any]
    else {
      divKitData = data
      metadata = nil
      return
    }

    metadata = SDUIPageMetadata(object: pageObject)

    var divKitObject = object
    divKitObject.removeValue(forKey: "page")
    divKitData = try JSONSerialization.data(withJSONObject: divKitObject)
  }
}

struct SDUIPageMetadata {
  let id: String?
  let title: String?
  let version: Int?
  let publishedAt: String?
  let status: String?
  let refreshable: Bool
  let minClientVersion: Int
  let requiredCapabilities: [String]

  init(object: [String: Any]) {
    id = object["id"] as? String
    title = object["title"] as? String
    version = object["version"] as? Int
    publishedAt = object["publishedAt"] as? String
    status = object["status"] as? String
    refreshable = object["refreshable"] as? Bool ?? true
    minClientVersion = object["minClientVersion"] as? Int ?? 1
    requiredCapabilities = object["requiredCapabilities"] as? [String] ?? []
  }
}
