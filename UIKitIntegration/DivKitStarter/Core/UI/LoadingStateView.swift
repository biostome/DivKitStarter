import UIKit

final class LoadingStateView: UIView {
  var retryHandler: (() -> Void)?

  private let stackView = UIStackView()
  private let activityIndicator = UIActivityIndicatorView(style: .large)
  private let titleLabel = UILabel()
  private let messageLabel = UILabel()
  private let retryButton = UIButton(type: .system)

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }

  func showLoading() {
    isHidden = false
    activityIndicator.isHidden = false
    activityIndicator.startAnimating()
    titleLabel.text = "加载中"
    messageLabel.text = "正在请求本地 DivKit JSON"
    retryButton.isHidden = true
  }

  func showError(_ message: String) {
    isHidden = false
    activityIndicator.stopAnimating()
    activityIndicator.isHidden = true
    titleLabel.text = "网络异常"
    messageLabel.text = message
    retryButton.isHidden = false
  }

  func hide() {
    activityIndicator.stopAnimating()
    isHidden = true
  }

  private func setupView() {
    backgroundColor = .systemBackground
    isHidden = true

    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.spacing = 12
    stackView.translatesAutoresizingMaskIntoConstraints = false

    titleLabel.font = .preferredFont(forTextStyle: .headline)
    titleLabel.textColor = .label

    messageLabel.font = .preferredFont(forTextStyle: .subheadline)
    messageLabel.textColor = .secondaryLabel
    messageLabel.numberOfLines = 0
    messageLabel.textAlignment = .center

    retryButton.setTitle("重试", for: .normal)
    retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)

    addSubview(stackView)
    stackView.addArrangedSubview(activityIndicator)
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(messageLabel)
    stackView.addArrangedSubview(retryButton)

    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
      stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24),
      stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
      stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
      messageLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -48),
    ])
  }

  @objc private func retryButtonTapped() {
    retryHandler?()
  }
}
