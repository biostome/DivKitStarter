import DivKit
import XCTest
@testable import DivKitStarter

final class SDUIActionTests: XCTestCase {
    func testParsesOpenAction() {
        let action = SDUIAction(payload: [
            "action": "open",
            "path": "detail",
            "title": "详情",
        ])

        guard case let .open(path, title) = action else {
            return XCTFail("Expected open action")
        }
        XCTAssertEqual(path, "detail")
        XCTAssertEqual(title, "详情")
    }

    func testRejectsInvalidPagePath() {
        XCTAssertNil(SDUIAction(payload: [
            "action": "open",
            "path": "../bad",
        ]))
    }

    func testParsesBackActionName() {
        XCTAssertEqual(SDUIAction(payload: ["action": "back"])?.name, "back")
    }
}
