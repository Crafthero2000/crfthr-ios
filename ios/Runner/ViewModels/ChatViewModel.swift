import Combine
import Foundation

@MainActor
final class ChatViewModel: ObservableObject {
  enum ModelState: Equatable {
    case idle
    case loading(Double)
    case ready
    case failed(String)

    var isLoading: Bool {
      if case .loading = self { return true }
      return false
    }

    var statusText: String? {
      switch self {
      case .idle:
        return nil
      case .loading(let progress):
        return String(
          format: NSLocalizedString("status.loading_model", comment: "Loading model"),
          progress * 100
        )
      case .ready:
        return NSLocalizedString("status.model_ready", comment: "Model ready")
      case .failed(let message):
        return message
      }
    }
  }

  @Published var messages: [ChatMessage] = []
  @Published var inputText: String = ""
  @Published var isGenerating = false
  @Published var modelState: ModelState = .idle
  @Published var errorMessage: String?
  @Published var exportText: String = ""
  @Published var exportJSON: String = ""

  private let chatStore: ChatStore
  private let modelStore: ModelStore
  private let settingsStore: SettingsStore
  private let llmService: LLMService

  init(
    chatStore: ChatStore,
    modelStore: ModelStore,
    settingsStore: SettingsStore,
    llmService: LLMService
  ) {
    self.chatStore = chatStore
    self.modelStore = modelStore
    self.settingsStore = settingsStore
    self.llmService = llmService
  }

  func load() async {
    let snapshot = await chatStore.load()
    messages = snapshot.messages
    await refreshExports()
  }

  func sendMessage() {
    let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }
    inputText = ""
    Task { await send(trimmed) }
  }

  func clearHistory() async {
    let snapshot = await chatStore.clear()
    messages = snapshot.messages
    await refreshExports()
  }

  private func send(_ text: String) async {
    isGenerating = true
    errorMessage = nil

    let userMessage = await chatStore.append(role: .user, content: text)
    messages.append(userMessage)

    do {
      let settings = await settingsStore.current()
      guard let selectedModelId = settings.selectedModelId else {
        throw LLMServiceError.modelNotSelected
      }
      guard let modelRecord = await modelStore.model(withId: selectedModelId) else {
        throw LLMServiceError.modelNotAvailable
      }

      modelState = .loading(0)
      try await llmService.loadModelIfNeeded(record: modelRecord) { progress, _ in
        Task { @MainActor in
          self.modelState = .loading(progress)
        }
      }
      modelState = .ready

      let snapshot = await chatStore.snapshot()
      let summaryResult = try await llmService.summarizeIfNeeded(
        messages: snapshot.messages,
        summary: snapshot.summary,
        settings: settings.generation,
        systemPrompt: settings.systemPrompt
      )

      if summaryResult.summary != snapshot.summary || summaryResult.messages != snapshot.messages {
        await chatStore.setSummary(summaryResult.summary)
        await chatStore.replaceMessages(summaryResult.messages)
        await chatStore.save()
        messages = summaryResult.messages
      }

      let assistantMessage = await chatStore.append(role: .assistant, content: "")
      messages.append(assistantMessage)

      let stream = try await llmService.streamResponse(
        messages: summaryResult.messages,
        summary: summaryResult.summary,
        settings: settings.generation,
        systemPrompt: settings.systemPrompt
      )

      var assistantText = ""
      for try await chunk in stream {
        assistantText += chunk
        let displayText = LLMService.postProcessResponse(assistantText)
        updateMessage(id: assistantMessage.id, content: displayText)
        await chatStore.updateMessage(id: assistantMessage.id, content: displayText)
      }

      let finalText = LLMService.postProcessResponse(assistantText)
      updateMessage(id: assistantMessage.id, content: finalText)
      await chatStore.updateMessage(id: assistantMessage.id, content: finalText)
      await chatStore.save()
      await refreshExports()
    } catch {
      errorMessage = error.localizedDescription
      modelState = .failed(error.localizedDescription)
    }

    isGenerating = false
  }

  private func updateMessage(id: UUID, content: String) {
    guard let index = messages.firstIndex(where: { $0.id == id }) else { return }
    messages[index].content = content
  }

  private func refreshExports() async {
    let items = await chatStore.exportItems()
    exportText = buildExportText(items: items)
    exportJSON = buildExportJSON(items: items)
  }

  private func buildExportText(items: [ChatExportItem]) -> String {
    let roleUser = NSLocalizedString("export.role.user", comment: "Export role user")
    let roleAssistant = NSLocalizedString("export.role.assistant", comment: "Export role assistant")
    let roleSystem = NSLocalizedString("export.role.system", comment: "Export role system")
    let separator = NSLocalizedString("export.separator", comment: "Export separator")

    let blocks = items.map { item -> String in
      let label: String
      switch item.role {
      case "user":
        label = roleUser
      case "assistant":
        label = roleAssistant
      default:
        label = roleSystem
      }
      return "\(label): \(item.content)"
    }
    return blocks.joined(separator: "\n\(separator)\n")
  }

  private func buildExportJSON(items: [ChatExportItem]) -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    guard let data = try? encoder.encode(items),
          let json = String(data: data, encoding: .utf8) else {
      return ""
    }
    return json
  }
}
