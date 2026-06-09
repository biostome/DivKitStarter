import Foundation

enum SDUIEventLogger {
    static func log(_ name: String, _ fields: [String: CustomStringConvertible?] = [:]) {
        #if DEBUG
        let details = fields
            .compactMap { key, value -> String? in
                guard let value else {
                    return nil
                }
                return "\(key)=\(value)"
            }
            .joined(separator: " ")
        print("[SDUI] \(name)\(details.isEmpty ? "" : " \(details)")")
        #endif
    }
}
