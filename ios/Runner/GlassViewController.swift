import UIKit

final class DashboardViewController: UITableViewController {
  private struct KPI {
    let type: MetricType
    let title: String
    let value: String
    let change: String
    let subtitle: String
  }

  private struct DailyActivity {
    let day: String
    let sessions: Int
    let appeals: Int
    let avgRating: Double
  }

  private struct Trend {
    let month: String
    let hours: Int
    let sessions: Int
    let efficiency: Int
  }

  private enum Section: Int, CaseIterable {
    case kpi
    case daily
    case trends
  }

  private let kpis: [KPI] = [
    KPI(type: .sessions, title: "Сессии", value: "124", change: "+8%", subtitle: "за текущий месяц"),
    KPI(type: .appeals, title: "Обращения", value: "487", change: "+12%", subtitle: "всего обработано"),
    KPI(type: .hours, title: "Время работы", value: "156.5ч", change: "+5%", subtitle: "за месяц"),
    KPI(type: .avgDuration, title: "Средняя длительность", value: "18.2м", change: "-3%", subtitle: "на сессию"),
  ]

  private let dailyActivity: [DailyActivity] = [
    DailyActivity(day: "Пн", sessions: 18, appeals: 72, avgRating: 4.5),
    DailyActivity(day: "Вт", sessions: 22, appeals: 85, avgRating: 4.7),
    DailyActivity(day: "Ср", sessions: 20, appeals: 78, avgRating: 4.6),
    DailyActivity(day: "Чт", sessions: 24, appeals: 92, avgRating: 4.8),
    DailyActivity(day: "Пт", sessions: 19, appeals: 74, avgRating: 4.4),
    DailyActivity(day: "Сб", sessions: 12, appeals: 45, avgRating: 4.5),
    DailyActivity(day: "Вс", sessions: 9, appeals: 41, avgRating: 4.3),
  ]

  private let trends: [Trend] = [
    Trend(month: "Июн", hours: 142, sessions: 98, efficiency: 85),
    Trend(month: "Июл", hours: 158, sessions: 110, efficiency: 88),
    Trend(month: "Авг", hours: 145, sessions: 102, efficiency: 86),
    Trend(month: "Сен", hours: 165, sessions: 118, efficiency: 90),
    Trend(month: "Окт", hours: 152, sessions: 112, efficiency: 87),
    Trend(month: "Ноя", hours: 156, sessions: 124, efficiency: 89),
  ]

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Дашборд"
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.tableHeaderView = makeHeader()
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Период",
      style: .plain,
      target: self,
      action: #selector(showPeriod)
    )
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    guard let header = tableView.tableHeaderView else { return }
    let height = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    if header.frame.height != height {
      header.frame.size.height = height
      tableView.tableHeaderView = header
    }
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    Section.allCases.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let section = Section(rawValue: section) else { return 0 }
    switch section {
    case .kpi:
      return kpis.count
    case .daily:
      return dailyActivity.count
    case .trends:
      return trends.count
    }
  }

  override func tableView(
    _ tableView: UITableView,
    titleForHeaderInSection section: Int
  ) -> String? {
    guard let section = Section(rawValue: section) else { return nil }
    switch section {
    case .kpi:
      return "Ключевые показатели"
    case .daily:
      return "Активность по дням"
    case .trends:
      return "Динамика показателей"
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let section = Section(rawValue: indexPath.section) else {
      return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    }

    switch section {
    case .kpi:
      let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
      let kpi = kpis[indexPath.row]
      cell.textLabel?.text = "\(kpi.title) · \(kpi.value)"
      cell.detailTextLabel?.text = "\(kpi.subtitle) · \(kpi.change)"
      cell.accessoryType = .disclosureIndicator
      return cell
    case .daily:
      let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
      let item = dailyActivity[indexPath.row]
      cell.textLabel?.text = "\(item.day): \(item.sessions) сессий, \(item.appeals) обращений, рейтинг \(item.avgRating)"
      cell.textLabel?.numberOfLines = 0
      return cell
    case .trends:
      let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
      let item = trends[indexPath.row]
      cell.textLabel?.text = "\(item.month): \(item.hours)ч, \(item.sessions) сессий, эффективность \(item.efficiency)%"
      cell.textLabel?.numberOfLines = 0
      return cell
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let section = Section(rawValue: indexPath.section), section == .kpi else { return }
    tableView.deselectRow(at: indexPath, animated: true)
    let kpi = kpis[indexPath.row]
    let detail = DashboardDetailViewController(metric: kpi.type)
    navigationController?.pushViewController(detail, animated: true)
  }

  private func makeHeader() -> UIView {
    let titleLabel = UILabel()
    titleLabel.text = "Рабочий помощник"
    titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
    titleLabel.textColor = .label

    let subtitleLabel = UILabel()
    subtitleLabel.text = "Оператор call-центра"
    subtitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    subtitleLabel.textColor = .secondaryLabel

    let periodLabel = UILabel()
    periodLabel.text = "Период: 01.11.2025 – 07.11.2025"
    periodLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
    periodLabel.textColor = .secondaryLabel

    let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, periodLabel])
    stack.axis = .vertical
    stack.spacing = 6
    stack.translatesAutoresizingMaskIntoConstraints = false

    let container = UIView()
    container.addSubview(stack)

    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
      stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
      stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
      stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
    ])

    return container
  }

  @objc private func showPeriod() {
    let alert = UIAlertController(
      title: "Период",
      message: "01.11.2025 – 07.11.2025",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "Ок", style: .default))
    present(alert, animated: true)
  }
}

final class SettingsViewController: UITableViewController {
  private enum Segment: Int, CaseIterable {
    case profile
    case interface
    case admin

    var title: String {
      switch self {
      case .profile:
        return "Профиль"
      case .interface:
        return "Интерфейс"
      case .admin:
        return "Администрирование"
      }
    }
  }

  private enum AdminSection: Int, CaseIterable {
    case profiles
    case periods
    case system
  }

  private var selectedSegment: Segment = .profile {
    didSet { tableView.reloadData() }
  }

  private var profileData: [String: String] = [
    "Имя": "Иван",
    "Фамилия": "Петров",
    "Email": "ivan@example.com",
    "Телефон": "+7 (999) 123-45-67",
    "Должность": "Оператор call-центра",
  ]

  private let profileFields = ["Имя", "Фамилия", "Email", "Телефон", "Должность"]

  private var interfaceSettings: [String: Bool] = [
    "Тёмная тема": false,
    "Компактный вид": false,
    "Уведомления": true,
    "Звуковые сигналы": true,
  ]

  private var language = "Русский"
  private var dateFormat = "ДД.ММ.ГГГГ"
  private var baseAmount = "10000"
  private var apiEndpoint = "https://api.example.com/slots"

  private let workProfiles: [(name: String, type: String, employment: String, base: String)] = [
    ("Чаты ГПД", "Чаты", "ГПД", "8000 ₽"),
    ("Звонки СМЗ", "Звонки", "СМЗ", "12000 ₽"),
    ("Чаты СМЗ", "Чаты", "СМЗ", "10000 ₽"),
    ("Звонки ГПД", "Звонки", "ГПД", "9000 ₽"),
  ]

  private let periods: [(name: String, profile: String, dates: String, status: String)] = [
    ("Ноябрь 2025", "Звонки СМЗ", "2025-11-01 – 2025-11-30", "Активный"),
    ("Декабрь 2025", "Звонки СМЗ", "2025-12-01 – 2025-12-31", "Запланирован"),
  ]

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Настройки"
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.register(TextFieldCell.self, forCellReuseIdentifier: "textFieldCell")
    tableView.tableHeaderView = makeHeader()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    guard let header = tableView.tableHeaderView else { return }
    let height = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    if header.frame.height != height {
      header.frame.size.height = height
      tableView.tableHeaderView = header
    }
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    switch selectedSegment {
    case .profile:
      return 1
    case .interface:
      return 2
    case .admin:
      return AdminSection.allCases.count
    }
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch selectedSegment {
    case .profile:
      return profileFields.count + 1
    case .interface:
      if section == 0 { return 2 }
      return 4
    case .admin:
      guard let adminSection = AdminSection(rawValue: section) else { return 0 }
      switch adminSection {
      case .profiles:
        return workProfiles.count
      case .periods:
        return periods.count
      case .system:
        return 3
      }
    }
  }

  override func tableView(
    _ tableView: UITableView,
    titleForHeaderInSection section: Int
  ) -> String? {
    switch selectedSegment {
    case .profile:
      return "Личная информация"
    case .interface:
      return section == 0 ? "Переключатели" : "Язык и формат"
    case .admin:
      guard let adminSection = AdminSection(rawValue: section) else { return nil }
      switch adminSection {
      case .profiles:
        return "Профили работы"
      case .periods:
        return "Расчетные периоды"
      case .system:
        return "Системные настройки"
      }
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch selectedSegment {
    case .profile:
      if indexPath.row == profileFields.count {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "Сохранить изменения"
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = view.tintColor
        return cell
      }

      let key = profileFields[indexPath.row]
      let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell", for: indexPath) as! TextFieldCell
      cell.configure(title: key, placeholder: profileData[key] ?? "", value: profileData[key] ?? "", keyboardType: .default) {
        [weak self] text in
        self?.profileData[key] = text
      }
      return cell
    case .interface:
      if indexPath.section == 0 {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let key = indexPath.row == 0 ? "Тёмная тема" : "Компактный вид"
        cell.textLabel?.text = key
        cell.detailTextLabel?.text = indexPath.row == 0
          ? "Использовать тёмное оформление интерфейса"
          : "Уменьшить отступы между элементами"
        let toggle = UISwitch()
        toggle.isOn = interfaceSettings[key] ?? false
        toggle.addTarget(self, action: #selector(interfaceSwitchChanged(_:)), for: .valueChanged)
        toggle.accessibilityIdentifier = key
        cell.accessoryView = toggle
        return cell
      }

      if indexPath.row == 0 {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = "Язык интерфейса"
        cell.detailTextLabel?.text = language
        cell.accessoryType = .disclosureIndicator
        return cell
      }

      if indexPath.row == 1 {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = "Формат даты"
        cell.detailTextLabel?.text = dateFormat
        cell.accessoryType = .disclosureIndicator
        return cell
      }

      let key = indexPath.row == 2 ? "Уведомления" : "Звуковые сигналы"
      let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
      cell.textLabel?.text = key
      cell.detailTextLabel?.text = indexPath.row == 2
        ? "Показывать уведомления о новых событиях"
        : "Воспроизводить звук при уведомлениях"
      let toggle = UISwitch()
      toggle.isOn = interfaceSettings[key] ?? true
      toggle.addTarget(self, action: #selector(interfaceSwitchChanged(_:)), for: .valueChanged)
      toggle.accessibilityIdentifier = key
      cell.accessoryView = toggle
      return cell
    case .admin:
      guard let adminSection = AdminSection(rawValue: indexPath.section) else {
        return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
      }
      switch adminSection {
      case .profiles:
        let profile = workProfiles[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = profile.name
        cell.detailTextLabel?.text = "\(profile.type) · \(profile.employment) · \(profile.base)"
        cell.selectionStyle = .none
        return cell
      case .periods:
        let period = periods[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = period.name
        cell.detailTextLabel?.text = "\(period.profile) · \(period.dates) · \(period.status)"
        cell.accessoryType = .disclosureIndicator
        return cell
      case .system:
        if indexPath.row == 0 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell", for: indexPath) as! TextFieldCell
          cell.configure(title: "Базовая мотивация (₽)", placeholder: "10000", value: baseAmount, keyboardType: .numberPad) {
            [weak self] text in
            self?.baseAmount = text
          }
          return cell
        }
        if indexPath.row == 1 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell", for: indexPath) as! TextFieldCell
          cell.configure(title: "API Endpoint", placeholder: apiEndpoint, value: apiEndpoint, keyboardType: .URL) {
            [weak self] text in
            self?.apiEndpoint = text
          }
          return cell
        }
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "Сохранить настройки"
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = view.tintColor
        return cell
      }
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    switch selectedSegment {
    case .profile:
      if indexPath.row == profileFields.count {
        showSimpleAlert(title: "Сохранено", message: "Изменения профиля сохранены.")
      }
    case .interface:
      if indexPath.section == 1 {
        if indexPath.row == 0 {
          showLanguagePicker()
        } else if indexPath.row == 1 {
          showDateFormatPicker()
        }
      }
    case .admin:
      guard let adminSection = AdminSection(rawValue: indexPath.section) else { return }
      switch adminSection {
      case .periods:
        let period = periods[indexPath.row]
        let detail = PeriodDetailViewController(periodName: period.name)
        navigationController?.pushViewController(detail, animated: true)
      case .system:
        if indexPath.row == 2 {
          showSimpleAlert(title: "Сохранено", message: "Системные настройки сохранены.")
        }
      default:
        break
      }
    }
  }

  private func makeHeader() -> UIView {
    let titleLabel = UILabel()
    titleLabel.text = "Настройки"
    titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
    titleLabel.textColor = .label

    let subtitleLabel = UILabel()
    subtitleLabel.text = "Управление профилем и системой"
    subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    subtitleLabel.textColor = .secondaryLabel

    let segmented = UISegmentedControl(items: Segment.allCases.map { $0.title })
    segmented.selectedSegmentIndex = selectedSegment.rawValue
    segmented.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)

    let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, segmented])
    stack.axis = .vertical
    stack.spacing = 12
    stack.translatesAutoresizingMaskIntoConstraints = false

    let container = UIView()
    container.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
      stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
      stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
      stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
    ])

    return container
  }

  @objc private func segmentChanged(_ sender: UISegmentedControl) {
    selectedSegment = Segment(rawValue: sender.selectedSegmentIndex) ?? .profile
  }

  @objc private func interfaceSwitchChanged(_ sender: UISwitch) {
    guard let key = sender.accessibilityIdentifier else { return }
    interfaceSettings[key] = sender.isOn
  }

  private func showLanguagePicker() {
    let sheet = UIAlertController(title: "Язык интерфейса", message: nil, preferredStyle: .actionSheet)
    ["Русский", "English", "Қазақша"].forEach { option in
      sheet.addAction(UIAlertAction(title: option, style: .default) { [weak self] _ in
        self?.language = option
        self?.tableView.reloadData()
      })
    }
    sheet.addAction(UIAlertAction(title: "Отмена", style: .cancel))
    presentActionSheet(sheet)
  }

  private func showDateFormatPicker() {
    let sheet = UIAlertController(title: "Формат даты", message: nil, preferredStyle: .actionSheet)
    ["ДД.ММ.ГГГГ", "ММ/ДД/ГГГГ", "ГГГГ-ММ-ДД"].forEach { option in
      sheet.addAction(UIAlertAction(title: option, style: .default) { [weak self] _ in
        self?.dateFormat = option
        self?.tableView.reloadData()
      })
    }
    sheet.addAction(UIAlertAction(title: "Отмена", style: .cancel))
    presentActionSheet(sheet)
  }

  private func showSimpleAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ок", style: .default))
    present(alert, animated: true)
  }

  private func presentActionSheet(_ alert: UIAlertController) {
    if let popover = alert.popoverPresentationController {
      popover.sourceView = view
      popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
      popover.permittedArrowDirections = []
    }
    present(alert, animated: true)
  }
}

final class PeriodDetailViewController: UITableViewController {
  private let periodName: String
  private let metrics: [(name: String, weight: String, rule: String)] = [
    ("Качество", "25%", "<85: 0.5x, 85-90: 1.5x, 90-95: 2.0x, >95: 2.5x"),
    ("Эффективность", "25%", ">85%: 2.0x, иначе: 1.0x"),
    ("Трансферы", "30%", "<10%: 2.0x, иначе: 1.0x"),
    ("Эффективное время", "20%", ">80%: 1.5x, иначе: 1.0x"),
  ]

  init(periodName: String) {
    self.periodName = periodName
    super.init(style: .insetGrouped)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Показатели периода"
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    metrics.count
  }

  override func tableView(
    _ tableView: UITableView,
    titleForHeaderInSection section: Int
  ) -> String? {
    periodName
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let metric = metrics[indexPath.row]
    cell.textLabel?.text = "\(metric.name) · \(metric.weight) · \(metric.rule)"
    cell.textLabel?.numberOfLines = 0
    cell.selectionStyle = .none
    return cell
  }
}

final class TextFieldCell: UITableViewCell, UITextFieldDelegate {
  private let field = UITextField()
  private var onChange: ((String) -> Void)?

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    selectionStyle = .none
    field.translatesAutoresizingMaskIntoConstraints = false
    field.textAlignment = .right
    field.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    contentView.addSubview(field)

    NSLayoutConstraint.activate([
      field.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      field.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      field.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 140),
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(
    title: String,
    placeholder: String,
    value: String,
    keyboardType: UIKeyboardType,
    onChange: @escaping (String) -> Void
  ) {
    textLabel?.text = title
    field.placeholder = placeholder
    field.text = value
    field.keyboardType = keyboardType
    self.onChange = onChange
  }

  @objc private func textChanged() {
    onChange?(field.text ?? "")
  }
}

enum MetricType: String {
  case sessions
  case appeals
  case hours
  case avgDuration
}

final class DashboardDetailViewController: UITableViewController {
  private let metric: MetricType

  private struct DetailData {
    let title: String
    let description: String
    let rows: [String]
  }

  private let data: [MetricType: DetailData] = [
    .sessions: DetailData(
      title: "Детали сессий",
      description: "Подробная информация по всем сессиям",
      rows: [
        "07.11.2025 · Телефон · 22м · Оценка 5",
        "07.11.2025 · Чат · 15м · Оценка 4",
        "06.11.2025 · Телефон · 18м · Оценка 5",
        "06.11.2025 · Email · 12м · Оценка 4",
        "05.11.2025 · Телефон · 25м · Оценка 5",
      ]
    ),
    .appeals: DetailData(
      title: "Детали обращений",
      description: "Подробная информация по обращениям",
      rows: [
        "07.11.2025 · Техподдержка · Закрыто · 12",
        "06.11.2025 · Продажи · Закрыто · 18",
        "05.11.2025 · Консультация · Закрыто · 15",
        "04.11.2025 · Техподдержка · Закрыто · 14",
        "03.11.2025 · Продажи · Закрыто · 20",
      ]
    ),
    .hours: DetailData(
      title: "Детали рабочего времени",
      description: "Распределение рабочих часов",
      rows: [
        "07.11.2025 · 09:00–18:00 · 8.5ч",
        "06.11.2025 · 09:00–17:30 · 8.0ч",
        "05.11.2025 · 09:15–18:15 · 8.5ч",
        "04.11.2025 · 09:00–17:45 · 8.25ч",
        "03.11.2025 · 09:00–18:00 · 8.5ч",
      ]
    ),
    .avgDuration: DetailData(
      title: "Детали длительности",
      description: "Средняя длительность по типам",
      rows: [
        "Телефон · 20.5м (5–45м)",
        "Чат · 15.2м (3–35м)",
        "Email · 12.8м (5–25м)",
        "Видеозвонок · 25.0м (10–60м)",
      ]
    ),
  ]

  init(metric: MetricType) {
    self.metric = metric
    super.init(style: .insetGrouped)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = data[metric]?.title
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.tableHeaderView = makeHeader()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    guard let header = tableView.tableHeaderView else { return }
    let height = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    if header.frame.height != height {
      header.frame.size.height = height
      tableView.tableHeaderView = header
    }
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    data[metric]?.rows.count ?? 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = data[metric]?.rows[indexPath.row]
    cell.textLabel?.numberOfLines = 0
    return cell
  }

  private func makeHeader() -> UIView {
    let label = UILabel()
    label.text = data[metric]?.description
    label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    label.textColor = .secondaryLabel
    label.numberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false

    let container = UIView()
    container.addSubview(label)
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
      label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
      label.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
      label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
    ])
    return container
  }
}

final class CalculatorViewController: UITableViewController {
  private enum Section: Int, CaseIterable {
    case profile
    case grade
    case period
    case metrics
    case action
    case result
  }

  private struct Grade {
    let id: Int
    let name: String
    let effectiveMinuteCost: Double
  }

  private struct WorkProfile {
    let id: String
    let name: String
    let type: String
    let employment: String
    let grades: [Grade]
  }

  private struct WeightedMetric {
    let enabled: Bool
    let weight: Double
  }

  private struct ProfileSettings {
    let baseAmount: Double
    let weightedMetrics: [MetricKey: WeightedMetric]
    let paidMetrics: Set<MetricKey>
  }

  private struct Period {
    let id: String
    let name: String
    let profiles: [String: ProfileSettings]
  }

  private struct BreakdownItem {
    let name: String
    let value: Double
    let coefficient: Double
  }

  private struct PaidBreakdownItem {
    let name: String
    let amount: Double
    let rate: Double
    let quantity: Double
  }

  private struct Result {
    let baseMotivation: Double
    let paidAmount: Double
    let total: Double
    let breakdown: [BreakdownItem]
    let paidBreakdown: [PaidBreakdownItem]
  }

  private enum MetricKey: String, CaseIterable {
    case quality
    case efficiency
    case transfer
    case csat
    case effectiveMinutes

    var title: String {
      switch self {
      case .quality:
        return "Качество (%)"
      case .efficiency:
        return "Эффективность (%)"
      case .transfer:
        return "Трансферы (%)"
      case .csat:
        return "CSAT (1-5)"
      case .effectiveMinutes:
        return "Эффективные минуты"
      }
    }

    var placeholder: String {
      switch self {
      case .quality:
        return "92"
      case .efficiency:
        return "88"
      case .transfer:
        return "8"
      case .csat:
        return "4.7"
      case .effectiveMinutes:
        return "2400"
      }
    }
  }

  private let workProfiles: [WorkProfile] = [
    WorkProfile(
      id: "chat-gpd",
      name: "Чаты ГПД",
      type: "chat",
      employment: "gpd",
      grades: [
        Grade(id: 1, name: "Junior", effectiveMinuteCost: 2.5),
        Grade(id: 2, name: "Middle", effectiveMinuteCost: 3.0),
        Grade(id: 3, name: "Senior", effectiveMinuteCost: 3.5),
      ]
    ),
    WorkProfile(
      id: "calls-smz",
      name: "Звонки СМЗ",
      type: "calls",
      employment: "smz",
      grades: [
        Grade(id: 1, name: "Junior", effectiveMinuteCost: 3.0),
        Grade(id: 2, name: "Middle", effectiveMinuteCost: 3.5),
        Grade(id: 3, name: "Senior", effectiveMinuteCost: 4.0),
      ]
    ),
    WorkProfile(
      id: "chat-smz",
      name: "Чаты СМЗ",
      type: "chat",
      employment: "smz",
      grades: [
        Grade(id: 1, name: "Junior", effectiveMinuteCost: 2.8),
        Grade(id: 2, name: "Middle", effectiveMinuteCost: 3.2),
        Grade(id: 3, name: "Senior", effectiveMinuteCost: 3.7),
      ]
    ),
    WorkProfile(
      id: "calls-gpd",
      name: "Звонки ГПД",
      type: "calls",
      employment: "gpd",
      grades: [
        Grade(id: 1, name: "Junior", effectiveMinuteCost: 2.7),
        Grade(id: 2, name: "Middle", effectiveMinuteCost: 3.2),
        Grade(id: 3, name: "Senior", effectiveMinuteCost: 3.8),
      ]
    ),
  ]

  private let periods: [Period] = [
    Period(
      id: "nov-2025",
      name: "Ноябрь 2025",
      profiles: [
        "chat-gpd": ProfileSettings(
          baseAmount: 8000,
          weightedMetrics: [
            .quality: WeightedMetric(enabled: true, weight: 0.4),
            .efficiency: WeightedMetric(enabled: true, weight: 0.3),
            .csat: WeightedMetric(enabled: true, weight: 0.3),
          ],
          paidMetrics: [.effectiveMinutes]
        ),
        "calls-smz": ProfileSettings(
          baseAmount: 12000,
          weightedMetrics: [
            .transfer: WeightedMetric(enabled: true, weight: 0.35),
            .efficiency: WeightedMetric(enabled: true, weight: 0.35),
            .quality: WeightedMetric(enabled: true, weight: 0.3),
          ],
          paidMetrics: [.effectiveMinutes]
        ),
        "chat-smz": ProfileSettings(
          baseAmount: 10000,
          weightedMetrics: [
            .quality: WeightedMetric(enabled: true, weight: 0.35),
            .efficiency: WeightedMetric(enabled: true, weight: 0.3),
            .csat: WeightedMetric(enabled: true, weight: 0.35),
          ],
          paidMetrics: [.effectiveMinutes]
        ),
        "calls-gpd": ProfileSettings(
          baseAmount: 9000,
          weightedMetrics: [
            .transfer: WeightedMetric(enabled: true, weight: 0.3),
            .efficiency: WeightedMetric(enabled: true, weight: 0.4),
            .quality: WeightedMetric(enabled: true, weight: 0.3),
          ],
          paidMetrics: [.effectiveMinutes]
        ),
      ]
    ),
    Period(
      id: "dec-2025",
      name: "Декабрь 2025",
      profiles: [
        "chat-gpd": ProfileSettings(
          baseAmount: 8500,
          weightedMetrics: [
            .quality: WeightedMetric(enabled: true, weight: 0.4),
            .efficiency: WeightedMetric(enabled: true, weight: 0.3),
            .csat: WeightedMetric(enabled: true, weight: 0.3),
          ],
          paidMetrics: [.effectiveMinutes]
        ),
        "calls-smz": ProfileSettings(
          baseAmount: 12500,
          weightedMetrics: [
            .efficiency: WeightedMetric(enabled: true, weight: 0.4),
            .quality: WeightedMetric(enabled: true, weight: 0.35),
            .csat: WeightedMetric(enabled: true, weight: 0.25),
          ],
          paidMetrics: [.effectiveMinutes]
        ),
        "chat-smz": ProfileSettings(
          baseAmount: 10500,
          weightedMetrics: [
            .quality: WeightedMetric(enabled: true, weight: 0.35),
            .efficiency: WeightedMetric(enabled: true, weight: 0.3),
            .csat: WeightedMetric(enabled: true, weight: 0.35),
          ],
          paidMetrics: [.effectiveMinutes]
        ),
        "calls-gpd": ProfileSettings(
          baseAmount: 9500,
          weightedMetrics: [
            .efficiency: WeightedMetric(enabled: true, weight: 0.4),
            .quality: WeightedMetric(enabled: true, weight: 0.35),
            .csat: WeightedMetric(enabled: true, weight: 0.25),
          ],
          paidMetrics: [.effectiveMinutes]
        ),
      ]
    ),
  ]

  private let qualityCoefficients: [(min: Double, max: Double, coefficient: Double)] = [
    (0, 85, 0.5),
    (85, 90, 1.5),
    (90, 95, 2.0),
    (95, 100, 2.5),
  ]

  private var selectedPeriodId: String
  private var selectedProfileId: String
  private var selectedGradeId: Int
  private var metrics: [MetricKey: String] = [:]
  private var result: Result?

  init() {
    selectedPeriodId = periods[0].id
    selectedProfileId = workProfiles[0].id
    selectedGradeId = 2
    super.init(style: .insetGrouped)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Калькулятор"
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.register(TextFieldCell.self, forCellReuseIdentifier: "textFieldCell")
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    Section.allCases.filter { $0 != .result || result != nil }.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let section = Section(rawValue: section) else { return 0 }
    switch section {
    case .profile:
      return 2
    case .grade:
      return 2
    case .period:
      return 3
    case .metrics:
      return enabledMetrics().count
    case .action:
      return 1
    case .result:
      return resultRowCount()
    }
  }

  override func tableView(
    _ tableView: UITableView,
    titleForHeaderInSection section: Int
  ) -> String? {
    guard let section = Section(rawValue: section) else { return nil }
    switch section {
    case .profile:
      return "Профиль работы"
    case .grade:
      return "Грейд"
    case .period:
      return "Расчетный период"
    case .metrics:
      return "Введите показатели"
    case .action:
      return nil
    case .result:
      return "Результат"
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let section = Section(rawValue: indexPath.section) else {
      return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    }

    switch section {
    case .profile:
      let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
      if indexPath.row == 0 {
        cell.textLabel?.text = "Профиль"
        cell.detailTextLabel?.text = currentProfile().name
        cell.accessoryType = .disclosureIndicator
      } else {
        cell.textLabel?.text = "Базовая мотивация"
        cell.detailTextLabel?.text = "\(Int(currentSettings().baseAmount)) ₽"
        cell.selectionStyle = .none
      }
      return cell
    case .grade:
      let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
      if indexPath.row == 0 {
        cell.textLabel?.text = "Грейд"
        cell.detailTextLabel?.text = currentGrade().name
        cell.accessoryType = .disclosureIndicator
      } else {
        cell.textLabel?.text = "Эффективная минута"
        cell.detailTextLabel?.text = "\(currentGrade().effectiveMinuteCost) ₽/мин"
        cell.selectionStyle = .none
      }
      return cell
    case .period:
      let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
      if indexPath.row == 0 {
        cell.textLabel?.text = "Период"
        cell.detailTextLabel?.text = currentPeriod().name
        cell.accessoryType = .disclosureIndicator
      } else if indexPath.row == 1 {
        cell.textLabel?.text = "Показатели с весами"
        cell.detailTextLabel?.text = weightedMetricSummary()
        cell.detailTextLabel?.numberOfLines = 2
        cell.selectionStyle = .none
      } else {
        cell.textLabel?.text = "Оплачиваемые"
        cell.detailTextLabel?.text = paidMetricSummary()
        cell.detailTextLabel?.numberOfLines = 2
        cell.selectionStyle = .none
      }
      return cell
    case .metrics:
      let key = enabledMetrics()[indexPath.row]
      let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell", for: indexPath) as! TextFieldCell
      cell.configure(
        title: key.title,
        placeholder: key.placeholder,
        value: metrics[key] ?? "",
        keyboardType: key == .csat ? .decimalPad : .numberPad
      ) { [weak self] text in
        self?.metrics[key] = text
      }
      return cell
    case .action:
      let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
      cell.textLabel?.text = "Рассчитать мотивацию"
      cell.textLabel?.textAlignment = .center
      cell.textLabel?.textColor = view.tintColor
      return cell
    case .result:
      return resultCell(for: indexPath)
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let section = Section(rawValue: indexPath.section) else { return }
    tableView.deselectRow(at: indexPath, animated: true)

    switch section {
    case .profile:
      if indexPath.row == 0 {
        showProfilePicker()
      }
    case .grade:
      if indexPath.row == 0 {
        showGradePicker()
      }
    case .period:
      if indexPath.row == 0 {
        showPeriodPicker()
      }
    case .action:
      calculate()
    default:
      break
    }
  }

  private func currentProfile() -> WorkProfile {
    workProfiles.first { $0.id == selectedProfileId } ?? workProfiles[0]
  }

  private func currentGrade() -> Grade {
    currentProfile().grades.first { $0.id == selectedGradeId } ?? currentProfile().grades[0]
  }

  private func currentPeriod() -> Period {
    periods.first { $0.id == selectedPeriodId } ?? periods[0]
  }

  private func currentSettings() -> ProfileSettings {
    currentPeriod().profiles[selectedProfileId] ?? currentPeriod().profiles.values.first!
  }

  private func enabledMetrics() -> [MetricKey] {
    let settings = currentSettings()
    return MetricKey.allCases.filter { key in
      if key == .effectiveMinutes { return settings.paidMetrics.contains(key) }
      return settings.weightedMetrics[key]?.enabled == true
    }
  }

  private func weightedMetricSummary() -> String {
    let settings = currentSettings()
    let items = MetricKey.allCases.compactMap { key -> String? in
      guard let value = settings.weightedMetrics[key], value.enabled else { return nil }
      return "\(keyTitle(for: key)) \(Int(value.weight * 100))%"
    }
    return items.joined(separator: ", ")
  }

  private func paidMetricSummary() -> String {
    currentSettings().paidMetrics.contains(.effectiveMinutes)
      ? "Эффективные минуты"
      : "Нет"
  }

  private func keyTitle(for key: MetricKey) -> String {
    switch key {
    case .quality:
      return "Качество"
    case .efficiency:
      return "Эффективность"
    case .transfer:
      return "Трансферы"
    case .csat:
      return "CSAT"
    case .effectiveMinutes:
      return "Эффективные минуты"
    }
  }

  private func showProfilePicker() {
    let sheet = UIAlertController(title: "Профиль работы", message: nil, preferredStyle: .actionSheet)
    workProfiles.forEach { profile in
      sheet.addAction(UIAlertAction(title: profile.name, style: .default) { [weak self] _ in
        self?.selectedProfileId = profile.id
        self?.selectedGradeId = profile.grades.first?.id ?? 1
        self?.result = nil
        self?.tableView.reloadData()
      })
    }
    sheet.addAction(UIAlertAction(title: "Отмена", style: .cancel))
    presentActionSheet(sheet)
  }

  private func showGradePicker() {
    let sheet = UIAlertController(title: "Грейд", message: nil, preferredStyle: .actionSheet)
    currentProfile().grades.forEach { grade in
      sheet.addAction(UIAlertAction(title: grade.name, style: .default) { [weak self] _ in
        self?.selectedGradeId = grade.id
        self?.result = nil
        self?.tableView.reloadData()
      })
    }
    sheet.addAction(UIAlertAction(title: "Отмена", style: .cancel))
    presentActionSheet(sheet)
  }

  private func showPeriodPicker() {
    let sheet = UIAlertController(title: "Расчетный период", message: nil, preferredStyle: .actionSheet)
    periods.forEach { period in
      sheet.addAction(UIAlertAction(title: period.name, style: .default) { [weak self] _ in
        self?.selectedPeriodId = period.id
        self?.result = nil
        self?.tableView.reloadData()
      })
    }
    sheet.addAction(UIAlertAction(title: "Отмена", style: .cancel))
    presentActionSheet(sheet)
  }

  private func presentActionSheet(_ alert: UIAlertController) {
    if let popover = alert.popoverPresentationController {
      popover.sourceView = view
      popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
      popover.permittedArrowDirections = []
    }
    present(alert, animated: true)
  }

  private func calculate() {
    let settings = currentSettings()
    let baseAmount = settings.baseAmount
    var breakdown: [BreakdownItem] = []
    var paidBreakdown: [PaidBreakdownItem] = []
    var baseMotivation = 0.0
    var paidAmount = 0.0

    if settings.weightedMetrics[.quality]?.enabled == true {
      let quality = Double(metrics[.quality] ?? "") ?? 0
      let coefficient = qualityCoefficient(for: quality)
      let value = baseAmount * settings.weightedMetrics[.quality]!.weight * coefficient
      breakdown.append(BreakdownItem(name: "Качество", value: value, coefficient: coefficient))
      baseMotivation += value
    }

    if settings.weightedMetrics[.efficiency]?.enabled == true {
      let efficiency = Double(metrics[.efficiency] ?? "") ?? 0
      let coefficient = efficiency >= 85 ? 2.0 : 1.0
      let value = baseAmount * settings.weightedMetrics[.efficiency]!.weight * coefficient
      breakdown.append(BreakdownItem(name: "Эффективность", value: value, coefficient: coefficient))
      baseMotivation += value
    }

    if settings.weightedMetrics[.transfer]?.enabled == true {
      let transfer = Double(metrics[.transfer] ?? "") ?? 0
      let coefficient = transfer <= 10 ? 2.0 : 1.0
      let value = baseAmount * settings.weightedMetrics[.transfer]!.weight * coefficient
      breakdown.append(BreakdownItem(name: "Трансферы", value: value, coefficient: coefficient))
      baseMotivation += value
    }

    if settings.weightedMetrics[.csat]?.enabled == true {
      let csat = Double(metrics[.csat] ?? "") ?? 0
      let coefficient = csat >= 4.5 ? 2.0 : 1.0
      let value = baseAmount * settings.weightedMetrics[.csat]!.weight * coefficient
      breakdown.append(BreakdownItem(name: "CSAT", value: value, coefficient: coefficient))
      baseMotivation += value
    }

    if settings.paidMetrics.contains(.effectiveMinutes) {
      let minutes = Double(metrics[.effectiveMinutes] ?? "") ?? 0
      let rate = currentGrade().effectiveMinuteCost
      let amount = minutes * rate
      paidBreakdown.append(PaidBreakdownItem(
        name: "Эффективные минуты",
        amount: amount,
        rate: rate,
        quantity: minutes
      ))
      paidAmount += amount
    }

    let total = baseMotivation + paidAmount
    result = Result(
      baseMotivation: baseMotivation,
      paidAmount: paidAmount,
      total: total,
      breakdown: breakdown,
      paidBreakdown: paidBreakdown
    )
    tableView.reloadData()
  }

  private func qualityCoefficient(for quality: Double) -> Double {
    qualityCoefficients.first { quality >= $0.min && quality < $0.max }?.coefficient ?? 1
  }

  private func resultRowCount() -> Int {
    guard let result else { return 0 }
    return 3 + result.breakdown.count + result.paidBreakdown.count
  }

  private func resultCell(for indexPath: IndexPath) -> UITableViewCell {
    guard let result else { return UITableViewCell() }
    let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
    cell.selectionStyle = .none

    if indexPath.row == 0 {
      cell.textLabel?.text = "Итоговая мотивация"
      cell.detailTextLabel?.text = String(format: "%.2f ₽", result.total)
      return cell
    }

    if indexPath.row == 1 {
      cell.textLabel?.text = "Базовая"
      cell.detailTextLabel?.text = String(format: "%.2f ₽", result.baseMotivation)
      return cell
    }

    if indexPath.row == 2 {
      cell.textLabel?.text = "Оплачиваемые"
      cell.detailTextLabel?.text = String(format: "%.2f ₽", result.paidAmount)
      return cell
    }

    let breakdownStart = 3
    let breakdownEnd = breakdownStart + result.breakdown.count
    if indexPath.row < breakdownEnd {
      let item = result.breakdown[indexPath.row - breakdownStart]
      cell.textLabel?.text = "\(item.name) · \(item.coefficient)x"
      cell.detailTextLabel?.text = String(format: "%.2f ₽", item.value)
      return cell
    }

    let paidIndex = indexPath.row - breakdownEnd
    let item = result.paidBreakdown[paidIndex]
    cell.textLabel?.text = "\(item.name) · \(item.quantity) мин × \(item.rate)"
    cell.detailTextLabel?.text = String(format: "%.2f ₽", item.amount)
    return cell
  }
}
