import Foundation

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
    
    init?(url: URL) {
        guard url.scheme == "sdui" else {
            return nil
        }
        
        switch url.host {
        case "toast":
            let message = url.queryValue(for: "text")
            ?? url.queryValue(for: "message")
            ?? url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            self = .toast(text: message.isEmpty ? "提示" : message)
        case "open":
            let path = url.queryValue(for: "path")
            ?? url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            guard SDUIAction.isValidPagePath(path) else {
                return nil
            }
            self = .open(path: path, title: url.queryValue(for: "title"))
        case "modal":
            let path = url.queryValue(for: "path")
            ?? url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            guard SDUIAction.isValidPagePath(path) else {
                return nil
            }
            self = .modal(path: path, title: url.queryValue(for: "title"), style: ModalStyle(rawValue: url.queryValue(for: "style") ?? "") ?? .sheet)
        case "web":
            guard
                let rawURL = url.queryValue(for: "url"),
                let webURL = URL(string: rawURL),
                ["http", "https"].contains(webURL.scheme?.lowercased())
            else {
                return nil
            }
            self = .web(url: webURL)
        case "reload":
            self = .reload
        case "alert":
            let message = url.queryValue(for: "message") ?? url.queryValue(for: "text") ?? "提示"
            self = .alert(title: url.queryValue(for: "title"), message: message)
        case "copy":
            guard let text = url.queryValue(for: "text"), !text.isEmpty else {
                return nil
            }
            self = .copy(text: text)
        case "share":
            let shareURL = url.queryValue(for: "url").flatMap(URL.init(string:))
            self = .share(text: url.queryValue(for: "text"), url: shareURL)
        case "track":
            guard let name = url.queryValue(for: "name"), !name.isEmpty else {
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

private extension URL {
    func queryValue(for name: String) -> String? {
        URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first(where: { $0.name == name })?
            .value
    }
}
