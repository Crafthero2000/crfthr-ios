import Foundation
import MLXLMCommon

struct ModelRecord: Identifiable, Codable, Hashable {
  enum Source: String, Codable {
    case huggingFace
    case localFolder
  }

  var id: String
  var displayName: String
  var source: Source
  var localPath: String?
  var createdAt: Date

  var identifier: String { id }

  var isLocal: Bool {
    source == .localFolder
  }
}

struct ModelCatalogItem: Identifiable, Hashable {
  var id: String
  var displayName: String
}

extension Notification.Name {
  static let modelStoreDidChange = Notification.Name("ModelStoreDidChange")
}

actor ModelStore {
  private var models: [ModelRecord] = []
  private let metadataURL: URL
  private let importedRootURL: URL

  nonisolated static let defaultModelId = "mlx-community/Qwen2.5-1.5B-Instruct-4bit"
  nonisolated static let recommendedModels: [ModelCatalogItem] = [
    ModelCatalogItem(id: "mlx-community/Qwen2.5-1.5B-Instruct-4bit", displayName: "Qwen 2.5 1.5B Instruct (4bit)"),
    ModelCatalogItem(id: "mlx-community/Qwen3-0.6B-4bit", displayName: "Qwen 3 0.6B (4bit)"),
    ModelCatalogItem(id: "mlx-community/SmolLM-135M-Instruct-4bit", displayName: "SmolLM 135M Instruct (4bit)")
  ]

  init(
    metadataURL: URL = ModelStore.defaultMetadataURL(),
    importedRootURL: URL = ModelStore.defaultImportedModelsURL()
  ) {
    self.metadataURL = metadataURL
    self.importedRootURL = importedRootURL
  }

  static func defaultMetadataURL() -> URL {
    let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    let directory = base.appendingPathComponent("Crfthr", isDirectory: true)
    return directory.appendingPathComponent("models.json")
  }

  static func defaultImportedModelsURL() -> URL {
    let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    let directory = base.appendingPathComponent("Crfthr", isDirectory: true)
    return directory.appendingPathComponent("ImportedModels", isDirectory: true)
  }

  func load() async -> [ModelRecord] {
    do {
      let data = try Data(contentsOf: metadataURL)
      models = try JSONDecoder().decode([ModelRecord].self, from: data)
    } catch {
      models = []
    }
    return models
  }

  func allModels() -> [ModelRecord] {
    models
  }

  func model(withId id: String) -> ModelRecord? {
    models.first { $0.id == id }
  }

  func downloadModel(
    id: String,
    progress: @escaping @Sendable (Progress) -> Void
  ) async throws -> ModelRecord {
    let configuration = ModelConfiguration(id: id)
    _ = try await MLXLMCommon.downloadModel(hub: defaultHubApi, configuration: configuration, progressHandler: progress)

    if let existing = models.first(where: { $0.id == id }) {
      return existing
    }

    let displayName = id.split(separator: "/").last.map(String.init) ?? id
    let record = ModelRecord(
      id: id,
      displayName: displayName,
      source: .huggingFace,
      localPath: nil,
      createdAt: Date()
    )
    models.append(record)
    await persist()
    notifyChange()
    return record
  }

  func importModel(from sourceURL: URL, displayName: String) async throws -> ModelRecord {
    try FileManager.default.createDirectory(
      at: importedRootURL,
      withIntermediateDirectories: true
    )

    let safeName = displayName
      .replacingOccurrences(of: "[^a-zA-Z0-9-_]+", with: "-", options: .regularExpression)
      .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    let folderName = "\(safeName.isEmpty ? "model" : safeName)-\(UUID().uuidString)"
    let destinationURL = importedRootURL.appendingPathComponent(folderName, isDirectory: true)

    try FileManager.default.copyItem(at: sourceURL, to: destinationURL)

    let record = ModelRecord(
      id: "local-\(UUID().uuidString)",
      displayName: displayName,
      source: .localFolder,
      localPath: folderName,
      createdAt: Date()
    )
    models.append(record)
    await persist()
    notifyChange()
    return record
  }

  func modelDirectory(for record: ModelRecord) -> URL? {
    switch record.source {
    case .huggingFace:
      return ModelConfiguration(id: record.id).modelDirectory(hub: defaultHubApi)
    case .localFolder:
      guard let localPath = record.localPath else { return nil }
      return importedRootURL.appendingPathComponent(localPath, isDirectory: true)
    }
  }

  func configuration(for record: ModelRecord) -> ModelConfiguration? {
    switch record.source {
    case .huggingFace:
      return ModelConfiguration(id: record.id)
    case .localFolder:
      guard let directory = modelDirectory(for: record) else { return nil }
      return ModelConfiguration(directory: directory)
    }
  }

  private func persist() async {
    do {
      let data = try JSONEncoder().encode(models)
      try FileManager.default.createDirectory(
        at: metadataURL.deletingLastPathComponent(),
        withIntermediateDirectories: true
      )
      try data.write(to: metadataURL, options: [.atomic])
    } catch {
      // Ignore persistence issues; the in-memory list still works.
    }
  }

  private func notifyChange() {
    NotificationCenter.default.post(name: .modelStoreDidChange, object: nil)
  }
}
