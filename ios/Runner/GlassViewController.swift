import UIKit

final class GlassViewController: UIViewController {
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "Liquid Glass"
    label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
    label.textColor = .label
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let subtitleLabel: UILabel = {
    let label = UILabel()
    label.text = "Soft materials, depth, and clarity in UIKit."
    label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    label.textColor = .secondaryLabel
    label.numberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private lazy var actionButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.title = "Show Dialog"
    config.cornerStyle = .large
    config.baseBackgroundColor = UIColor.systemBlue.withAlphaComponent(0.9)
    config.baseForegroundColor = .white
    config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
    let button = UIButton(configuration: config)
    button.addTarget(self, action: #selector(showDialog), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  private let glassCard: UIVisualEffectView = {
    let blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
    let view = UIVisualEffectView(effect: blur)
    view.layer.cornerRadius = 26
    view.layer.cornerCurve = .continuous
    view.clipsToBounds = true
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private let shadowView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.12
    view.layer.shadowRadius = 24
    view.layer.shadowOffset = CGSize(width: 0, height: 12)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private let gradientLayer = CAGradientLayer()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    buildLayout()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    gradientLayer.frame = view.bounds
    shadowView.layer.shadowPath = UIBezierPath(
      roundedRect: shadowView.bounds,
      cornerRadius: 26
    ).cgPath
  }

  private func buildLayout() {
    gradientLayer.colors = [
      UIColor(red: 0.94, green: 0.96, blue: 1.0, alpha: 1.0).cgColor,
      UIColor(red: 0.90, green: 0.93, blue: 0.98, alpha: 1.0).cgColor,
      UIColor(red: 0.97, green: 0.97, blue: 0.99, alpha: 1.0).cgColor,
    ]
    gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
    gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
    view.layer.insertSublayer(gradientLayer, at: 0)

    view.addSubview(shadowView)
    shadowView.addSubview(glassCard)
    glassCard.contentView.addSubview(titleLabel)
    glassCard.contentView.addSubview(subtitleLabel)
    glassCard.contentView.addSubview(actionButton)

    NSLayoutConstraint.activate([
      shadowView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
      shadowView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
      shadowView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

      glassCard.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor),
      glassCard.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor),
      glassCard.topAnchor.constraint(equalTo: shadowView.topAnchor),
      glassCard.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor),

      titleLabel.topAnchor.constraint(equalTo: glassCard.contentView.topAnchor, constant: 24),
      titleLabel.leadingAnchor.constraint(equalTo: glassCard.contentView.leadingAnchor, constant: 24),
      titleLabel.trailingAnchor.constraint(equalTo: glassCard.contentView.trailingAnchor, constant: -24),

      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
      subtitleLabel.leadingAnchor.constraint(equalTo: glassCard.contentView.leadingAnchor, constant: 24),
      subtitleLabel.trailingAnchor.constraint(equalTo: glassCard.contentView.trailingAnchor, constant: -24),

      actionButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
      actionButton.leadingAnchor.constraint(equalTo: glassCard.contentView.leadingAnchor, constant: 24),
      actionButton.trailingAnchor.constraint(lessThanOrEqualTo: glassCard.contentView.trailingAnchor, constant: -24),
      actionButton.bottomAnchor.constraint(equalTo: glassCard.contentView.bottomAnchor, constant: -24),
    ])
  }

  @objc private func showDialog() {
    let alert = UIAlertController(
      title: "New Dialog",
      message: "A clean UIKit alert with modern spacing and hierarchy.",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }
}
