import Foundation

struct GenerationSettings: Codable, Equatable {
  var maxTokens: Int
  var temperature: Double
  var topP: Double
  var contextLimit: Int

  static let defaults = GenerationSettings(
    maxTokens: 384,
    temperature: 0.7,
    topP: 0.92,
    contextLimit: 4096
  )
}

struct AppSettings: Codable, Equatable {
  var selectedModelId: String?
  var generation: GenerationSettings
  var systemPrompt: String

  static let defaultSystemPrompt = """
  Ты — дружелюбный русскоязычный помощник. Отвечай коротко и по делу, без канцелярита. Не говори, что ты робот. Если не знаешь — скажи честно. Разрешен markdown (списки, код-блоки).
  """

  static let defaults = AppSettings(
    selectedModelId: nil,
    generation: .defaults,
    systemPrompt: defaultSystemPrompt
  )

  init(selectedModelId: String?, generation: GenerationSettings, systemPrompt: String) {
    self.selectedModelId = selectedModelId
    self.generation = generation
    self.systemPrompt = systemPrompt
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let selectedModelId = try container.decodeIfPresent(String.self, forKey: .selectedModelId)
    let generation = try container.decodeIfPresent(GenerationSettings.self, forKey: .generation) ?? .defaults
    let systemPrompt = try container.decodeIfPresent(String.self, forKey: .systemPrompt) ?? AppSettings.defaultSystemPrompt
    self.init(selectedModelId: selectedModelId, generation: generation, systemPrompt: systemPrompt)
  }
}

actor SettingsStore {
  private let settingsKey = "Crfthr.Settings"
  private var settings: AppSettings

  init() {
    self.settings = AppSettings.defaults
  }

  func load() async -> AppSettings {
    if let data = UserDefaults.standard.data(forKey: settingsKey),
       let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
      settings = decoded
    }
    return settings
  }

  func current() -> AppSettings {
    settings
  }

  func updateGeneration(_ generation: GenerationSettings) {
    settings.generation = generation
    persist()
  }

  func updateSelectedModelId(_ id: String?) {
    settings.selectedModelId = id
    persist()
  }

  func updateSystemPrompt(_ prompt: String) {
    settings.systemPrompt = prompt
    persist()
  }

  private func persist() {
    guard let data = try? JSONEncoder().encode(settings) else { return }
    UserDefaults.standard.set(data, forKey: settingsKey)
  }
}
