import UIKit

final class GlassViewController: UITableViewController {
  private var hapticsEnabled = true
  private var selectedMode = 0

  private enum Section: Int, CaseIterable {
    case summary
    case controls
    case actions
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Liquid Glass"
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    Section.allCases.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let section = Section(rawValue: section) else { return 0 }
    switch section {
    case .summary:
      return 1
    case .controls:
      return 2
    case .actions:
      return 1
    }
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    guard let section = Section(rawValue: section) else { return nil }
    switch section {
    case .summary:
      return "Overview"
    case .controls:
      return "Controls"
    case .actions:
      return "Actions"
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.selectionStyle = .none
    cell.accessoryView = nil
    cell.accessoryType = .none
    cell.textLabel?.numberOfLines = 0

    guard let section = Section(rawValue: indexPath.section) else { return cell }
    switch section {
    case .summary:
      cell.textLabel?.text = "Standard UIKit components adopt the latest system look automatically."
    case .controls:
      if indexPath.row == 0 {
        cell.textLabel?.text = "Haptics"
        let toggle = UISwitch()
        toggle.isOn = hapticsEnabled
        toggle.addTarget(self, action: #selector(hapticsChanged(_:)), for: .valueChanged)
        cell.accessoryView = toggle
      } else {
        cell.textLabel?.text = "Mode"
        let segmented = UISegmentedControl(items: ["Light", "Soft", "Contrast"])
        segmented.selectedSegmentIndex = selectedMode
        segmented.addTarget(self, action: #selector(modeChanged(_:)), for: .valueChanged)
        cell.accessoryView = segmented
      }
    case .actions:
      cell.textLabel?.text = "Show dialog"
      cell.accessoryType = .disclosureIndicator
      cell.selectionStyle = .default
    }

    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard Section(rawValue: indexPath.section) == .actions else { return }
    tableView.deselectRow(at: indexPath, animated: true)
    showDialog()
  }

  @objc private func hapticsChanged(_ sender: UISwitch) {
    hapticsEnabled = sender.isOn
  }

  @objc private func modeChanged(_ sender: UISegmentedControl) {
    selectedMode = sender.selectedSegmentIndex
  }

  private func showDialog() {
    let alert = UIAlertController(
      title: "New Dialog",
      message: "System alerts pick up the newest platform visuals.",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }
}
