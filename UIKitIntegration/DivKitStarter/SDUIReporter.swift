import DivKit
import Foundation

final class SDUIReporter: DivReporter {
  func reportError(cardId: DivCardID, error: DivError) {
    #if DEBUG
    print("[SDUIReporter] error cardId=\(cardId.rawValue) error=\(error)")
    #endif
  }

  func reportAction(cardId: DivCardID, info: DivActionInfo) {
    #if DEBUG
    print("[SDUIReporter] action cardId=\(cardId.rawValue) logId=\(info.logId) url=\(info.url?.absoluteString ?? "-")")
    #endif
  }
}
