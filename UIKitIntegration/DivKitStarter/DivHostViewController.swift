import DivKit
import DivKitExtensions
import UIKit

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
        await applyDivKitData(data, source: .network)
      } catch is CancellationError {
        return
      } catch {
        await recoverFromLoadError(error)
      }
    }
  }

  @MainActor
  private func applyDivKitData(_ data: Data, source: DataSource) async {
    refreshControl.endRefreshing()
    stateView.hide()
    if source == .network {
      responseCache.store(data, for: configuration.cardId.rawValue)
    }
    await divView.setSource(
      .init(kind: .data(data), cardId: configuration.cardId),
      debugParams: DebugParams(isDebugInfoEnabled: AppConfiguration.isDivKitDebugEnabled)
    )
  }

  @MainActor
  private func recoverFromLoadError(_ error: Error) async {
    refreshControl.endRefreshing()
    if let cachedData = responseCache.data(for: configuration.cardId.rawValue) {
      await applyDivKitData(cachedData, source: .cache)
      showToast("网络异常，已展示缓存内容")
      return
    }
    stateView.showError(error.localizedDescription)
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
}

private enum DataSource {
  case network
  case cache
}
