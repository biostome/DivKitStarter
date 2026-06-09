import XCTest
@testable import DivKitStarter

final class SDUIPageResponseTests: XCTestCase {
    func testParsesPageMetadataAndRemovesPageFromDivKitData() throws {
        let data = """
        {
          "page": {
            "id": "home",
            "title": "首页",
            "version": 2,
            "publishedAt": "2026-06-09T00:00:00.000Z",
            "status": "published",
            "refreshable": false,
            "minClientVersion": 3,
            "requiredCapabilities": ["toast"]
          },
          "card": {
            "log_id": "home",
            "states": [
              {
                "state_id": 0,
                "div": {
                  "type": "text",
                  "text": "Hello"
                }
              }
            ]
          }
        }
        """.data(using: .utf8)!

        let response = try SDUIPageResponse(data: data)
        XCTAssertEqual(response.metadata?.id, "home")
        XCTAssertEqual(response.metadata?.version, 2)
        XCTAssertEqual(response.metadata?.status, "published")
        XCTAssertEqual(response.metadata?.refreshable, false)

        let object = try JSONSerialization.jsonObject(with: response.divKitData) as? [String: Any]
        XCTAssertNil(object?["page"])
        XCTAssertNotNil(object?["card"])
    }
}
