import Combine
import Foundation

@MainActor
final class ModelManagerViewModel: ObservableObject {
  @Published var models: [ModelRecord] = []
  @Published var repoIdInput: String = ""
  @Published var isDownloading = false
  @Published var downloadProgress: Double = 0
  @Published var downloadStatus: String?
  @Published var errorMessage: String?

  let recommendedModels: [ModelCatalogItem]

  private let modelStore: ModelStore
  private let settingsStore: SettingsStore

  init(modelStore: ModelStore, settingsStore: SettingsStore) {
    self.modelStore = modelStore
    self.settingsStore = settingsStore
    self.recommendedModels = ModelStore.recommendedModels
    self.repoIdInput = ModelStore.defaultModelId
  }

  func load() async {
    models = await modelStore.load()
  }

  func downloadModel() {
    let trimmed = repoIdInput.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }

    isDownloading = true
    downloadProgress = 0
    downloadStatus = NSLocalizedString("models.status.starting", comment: "Download starting")
    errorMessage = nil

    Task {
      do {
        let record = try await modelStore.downloadModel(id: trimmed) { progress in
          Task { @MainActor in
            self.downloadProgress = progress.fractionCompleted
            self.downloadStatus = progress.localizedDescription
          }
        }

        models = await modelStore.allModels()
        await settingsStore.updateSelectedModelId(record.id)
        isDownloading = false
        downloadStatus = NSLocalizedString("models.status.downloaded", comment: "Download complete")
      } catch {
        isDownloading = false
        errorMessage = error.localizedDescription
      }
    }
  }

  func importModel(from url: URL, displayName: String) {
    isDownloading = true
    downloadStatus = NSLocalizedString("models.status.importing", comment: "Importing")
    errorMessage = nil

    Task {
      let didAccess = url.startAccessingSecurityScopedResource()
      defer {
        if didAccess {
          url.stopAccessingSecurityScopedResource()
        }
      }

      guard didAccess else {
        isDownloading = false
        errorMessage = NSLocalizedString("models.error.access", comment: "Access folder failed")
        return
      }

      do {
        _ = try await modelStore.importModel(from: url, displayName: displayName)
        models = await modelStore.allModels()
        isDownloading = false
        downloadStatus = NSLocalizedString("models.status.imported", comment: "Imported")
      } catch {
        isDownloading = false
        errorMessage = error.localizedDescription
      }
    }
  }
}
