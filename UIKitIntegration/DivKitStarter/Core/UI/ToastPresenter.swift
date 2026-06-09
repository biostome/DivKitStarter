import UIKit

final class ToastPresenter {
  private weak var currentToast: UIView?

  func show(_ message: String, in view: UIView) {
    currentToast?.removeFromSuperview()

    let label = UILabel()
    label.text = message
    label.textColor = .white
    label.font = .preferredFont(forTextStyle: .subheadline)
    label.numberOfLines = 0
    label.textAlignment = .center

    let container = UIView()
    container.backgroundColor = UIColor.black.withAlphaComponent(0.82)
    container.layer.cornerRadius = 10
    container.translatesAutoresizingMaskIntoConstraints = false
    container.alpha = 0

    label.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(label)
    view.addSubview(container)
    currentToast = container

    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
      label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
      label.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
      label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),

      container.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
      container.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
      container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -28),
    ])

    UIView.animate(withDuration: 0.2) {
      container.alpha = 1
    }

    UIView.animate(
      withDuration: 0.2,
      delay: 1.6,
      options: [.curveEaseInOut],
      animations: {
        container.alpha = 0
      },
      completion: { _ in
        container.removeFromSuperview()
      }
    )
  }
}
