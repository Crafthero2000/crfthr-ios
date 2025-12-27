import Combine
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
  @Published var models: [ModelRecord] = []
  @Published var selectedModelId: String?
  @Published var generation: GenerationSettings = .defaults

  private let modelStore: ModelStore
  private let settingsStore: SettingsStore

  init(modelStore: ModelStore, settingsStore: SettingsStore) {
    self.modelStore = modelStore
    self.settingsStore = settingsStore
  }

  func load() async {
    let appSettings = await settingsStore.load()
    generation = appSettings.generation
    selectedModelId = appSettings.selectedModelId
    models = await modelStore.load()
  }

  func reloadModels() async {
    models = await modelStore.allModels()
  }

  func updateSelectedModelId(_ id: String?) {
    selectedModelId = id
    Task {
      await settingsStore.updateSelectedModelId(id)
    }
  }

  func updateGeneration(_ generation: GenerationSettings) {
    self.generation = generation
    Task {
      await settingsStore.updateGeneration(generation)
    }
  }
}
