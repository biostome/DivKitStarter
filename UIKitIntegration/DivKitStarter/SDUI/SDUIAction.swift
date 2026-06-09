import Foundation
import DivKit

enum SDUIAction {
    case toast(text: String)
    case open(path: String, title: String?)
    case modal(path: String, title: String?, style: ModalStyle)
    case web(url: URL)
    case reload
    case alert(title: String?, message: String)
    case copy(text: String)
    case share(text: String?, url: URL?)
    case track(name: String)
    case back

    var name: String {
        switch self {
        case .toast:
            return "toast"
        case .open:
            return "open"
        case .modal:
            return "modal"
        case .web:
            return "web"
        case .reload:
            return "reload"
        case .alert:
            return "alert"
        case .copy:
            return "copy"
        case .share:
            return "share"
        case .track:
            return "track"
        case .back:
            return "back"
        }
    }
    
    init?(payload: DivDictionary) {
        guard let action = payload.stringValue(for: "action") else {
            return nil
        }

        switch action {
        case "toast":
            let message = payload.stringValue(for: "text") ?? payload.stringValue(for: "message") ?? "提示"
            self = .toast(text: message.isEmpty ? "提示" : message)
        case "open":
            guard let path = payload.stringValue(for: "path") else {
                return nil
            }
            guard SDUIAction.isValidPagePath(path) else {
                return nil
            }
            self = .open(path: path, title: payload.stringValue(for: "title"))
        case "modal":
            guard let path = payload.stringValue(for: "path") else {
                return nil
            }
            guard SDUIAction.isValidPagePath(path) else {
                return nil
            }
            self = .modal(
                path: path,
                title: payload.stringValue(for: "title"),
                style: ModalStyle(rawValue: payload.stringValue(for: "style") ?? "") ?? .sheet
            )
        case "web":
            guard
                let rawURL = payload.stringValue(for: "url"),
                let webURL = URL(string: rawURL),
                ["http", "https"].contains(webURL.scheme?.lowercased())
            else {
                return nil
            }
            self = .web(url: webURL)
        case "reload":
            self = .reload
        case "alert":
            let message = payload.stringValue(for: "message") ?? payload.stringValue(for: "text") ?? "提示"
            self = .alert(title: payload.stringValue(for: "title"), message: message)
        case "copy":
            guard let text = payload.stringValue(for: "text"), !text.isEmpty else {
                return nil
            }
            self = .copy(text: text)
        case "share":
            let shareURL = payload.stringValue(for: "url").flatMap(URL.init(string:))
            self = .share(text: payload.stringValue(for: "text"), url: shareURL)
        case "track":
            guard let name = payload.stringValue(for: "name"), !name.isEmpty else {
                return nil
            }
            self = .track(name: name)
        case "back":
            self = .back
        default:
            return nil
        }
    }
    
    static func isValidPagePath(_ path: String) -> Bool {
        !path.isEmpty && path.range(of: #"^[a-zA-Z0-9_-]+$"#, options: .regularExpression) != nil
    }
}

enum ModalStyle: String {
    case sheet
    case fullscreen
}

private extension DivDictionary {
    func stringValue(for key: String) -> String? {
        if let value = self[key] as? String {
            return value
        }
        return self[key].map(String.init(describing:))
    }
}
