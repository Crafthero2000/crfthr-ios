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

  static let defaults = AppSettings(selectedModelId: nil, generation: .defaults)
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

  private func persist() {
    guard let data = try? JSONEncoder().encode(settings) else { return }
    UserDefaults.standard.set(data, forKey: settingsKey)
  }
}
