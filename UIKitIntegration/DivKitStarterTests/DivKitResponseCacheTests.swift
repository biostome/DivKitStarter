import XCTest
@testable import DivKitStarter

final class DivKitResponseCacheTests: XCTestCase {
    func testReturnsFreshCachedData() throws {
        let fileManager = FileManager.default
        let cache = DivKitResponseCache(fileManager: fileManager)
        let cardId = UUID().uuidString
        let data = Data("{}".utf8)

        cache.store(data, for: cardId)

        XCTAssertEqual(cache.data(for: cardId, maxAge: 60), data)
    }

    func testRejectsExpiredCachedData() throws {
        let cache = DivKitResponseCache(fileManager: .default)
        let cardId = UUID().uuidString

        cache.store(Data("{}".utf8), for: cardId)

        XCTAssertNil(cache.data(for: cardId, maxAge: -1))
    }
}
