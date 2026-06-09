import DivKit
import DivKitExtensions
import UIKit
import WebKit

final class DivHostViewController: UIViewController {
    private let configuration: DivScreenConfiguration
    private let networkClient: DivKitNetworkClient
    
    private lazy var divKitComponents = makeDivKitComponents()
    private lazy var divView = DivView(divKitComponents: divKitComponents)
    private let scrollView = UIScrollView()
    private let refreshControl = UIRefreshControl()
    private let stateView = LoadingStateView()
    private let responseCache = DivKitResponseCache.shared
    private let toastPresenter = ToastPresenter()
    
    private var loadTask: Task<Void, Never>?
    private var isRefreshEnabled = true
    
    init(
        configuration: DivScreenConfiguration = .root,
        networkClient: DivKitNetworkClient = DivKitNetworkClient()
    ) {
        self.configuration = configuration
        self.networkClient = networkClient
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.configuration = .root
        self.networkClient = DivKitNetworkClient()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = configuration.title
        view.backgroundColor = .systemBackground
        setupSubviews()
        loadDivKitData(showFullScreenLoading: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        divView.frame = scrollView.bounds
    }
    
    deinit {
        loadTask?.cancel()
    }
    
    func openScreen(path: String, title: String?) {
        let viewController = DivHostViewController(
            configuration: DivScreenConfiguration(path: path, title: title),
            networkClient: networkClient
        )
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func goBack() {
        if navigationController?.viewControllers.first !== self {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    func showToast(_ message: String) {
        toastPresenter.show(message, in: view)
    }

    func reload() {
        loadDivKitData(showFullScreenLoading: true)
    }

    func showAlert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }

    func copyText(_ text: String) {
        UIPasteboard.general.string = text
        showToast("已复制")
    }

    func share(text: String?, url: URL?) {
        var items: [Any] = []
        if let text {
            items.append(text)
        }
        if let url {
            items.append(url)
        }
        guard !items.isEmpty else {
            return
        }
        present(UIActivityViewController(activityItems: items, applicationActivities: nil), animated: true)
    }

    func track(name: String) {
        #if DEBUG
        print("[SDUITrack] \(name)")
        #endif
    }
    
    private func setupSubviews() {
        scrollView.alwaysBounceVertical = true
        scrollView.refreshControl = refreshControl
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        refreshControl.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
        
        divView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.addSubview(divView)
        
        stateView.translatesAutoresizingMaskIntoConstraints = false
        stateView.retryHandler = { [weak self] in
            self?.loadDivKitData(showFullScreenLoading: true)
        }
        
        view.addSubview(scrollView)
        view.addSubview(stateView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stateView.topAnchor.constraint(equalTo: view.topAnchor),
            stateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    @objc private func refreshTriggered() {
        guard isRefreshEnabled else {
            refreshControl.endRefreshing()
            return
        }
        loadDivKitData(showFullScreenLoading: false)
    }
    
    private func loadDivKitData(showFullScreenLoading: Bool) {
        loadTask?.cancel()
        if showFullScreenLoading {
            stateView.showLoading()
        }
        
        loadTask = Task { [weak self] in
            guard let self else {
                return
            }
            
            do {
                let data = try await networkClient.fetchDivKitData(from: configuration.endpoint)
                try Task.checkCancellation()
                let response = try SDUIPageResponse(data: data)
                try validatePageMetadata(response.metadata)
                await applyPageResponse(response, rawData: data, source: .network)
            } catch is CancellationError {
                return
            } catch {
                await recoverFromLoadError(error)
            }
        }
    }
    
    @MainActor
    private func applyPageResponse(_ response: SDUIPageResponse, rawData: Data, source: DataSource) async {
        refreshControl.endRefreshing()
        stateView.hide()
        applyPageMetadata(response.metadata)
        if source == .network {
            responseCache.store(rawData, for: configuration.cardId.rawValue)
        }
        await divView.setSource(
            .init(kind: .data(response.divKitData), cardId: configuration.cardId),
            debugParams: DebugParams(isDebugInfoEnabled: AppConfiguration.isDivKitDebugEnabled)
        )
    }
    
    @MainActor
    private func recoverFromLoadError(_ error: Error) async {
        refreshControl.endRefreshing()
        if let cachedData = responseCache.data(for: configuration.cardId.rawValue) {
            do {
                let response = try SDUIPageResponse(data: cachedData)
                await applyPageResponse(response, rawData: cachedData, source: .cache)
            } catch {
                stateView.showError(error.localizedDescription)
                return
            }
            showToast("网络异常，已展示缓存内容")
            return
        }
        stateView.showError(error.localizedDescription)
    }

    private func validatePageMetadata(_ metadata: SDUIPageMetadata?) throws {
        guard let metadata else {
            return
        }
        if metadata.minClientVersion > AppConfiguration.clientVersion {
            throw SDUIPageError.unsupportedClientVersion
        }
        let unsupported = metadata.requiredCapabilities.filter {
            !AppConfiguration.supportedCapabilities.contains($0)
        }
        if !unsupported.isEmpty {
            throw SDUIPageError.unsupportedCapabilities(unsupported)
        }
    }

    @MainActor
    private func applyPageMetadata(_ metadata: SDUIPageMetadata?) {
        guard let metadata else {
            return
        }
        if let title = metadata.title {
            self.title = title
        }
        isRefreshEnabled = metadata.refreshable
        refreshControl.isEnabled = metadata.refreshable
    }
    
    private func makeDivKitComponents() -> DivKitComponents {
        let extensionHandlers = [PinchToZoomExtensionHandler(overlayView: view)]
        let customBlockFactory = SampleDivCustomBlockFactory()
        let urlHandler = SDUIActionHandler(hostViewController: self)
        return DivKitComponents(
            divCustomBlockFactory: customBlockFactory,
            extensionHandlers: extensionHandlers,
            reporter: SDUIReporter(),
            urlHandler: urlHandler
        )
    }
    func presentModal(path: String, title: String?, style: ModalStyle) {
        let viewController = DivHostViewController(
            configuration: DivScreenConfiguration(path: path, title: title),
            networkClient: networkClient
        )
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = style == .fullscreen ? .fullScreen : .pageSheet
        present(navigationController, animated: true)
    }

    func openWeb(url: URL) {
        let viewController = WebViewController(url: url)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

private enum DataSource {
    case network
    case cache
}

private enum SDUIPageError: LocalizedError {
    case unsupportedClientVersion
    case unsupportedCapabilities([String])

    var errorDescription: String? {
        switch self {
        case .unsupportedClientVersion:
            return "当前客户端版本过低"
        case let .unsupportedCapabilities(capabilities):
            return "当前客户端不支持能力: \(capabilities.joined(separator: ", "))"
        }
    }
}

private final class WebViewController: UIViewController {
    private let url: URL
    private let webView = WKWebView()

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func loadView() {
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.load(URLRequest(url: url))
    }
}
