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
        return String(format: "Loading model… %.0f%%", progress * 100)
      case .ready:
        return "Model ready"
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
  }

  func exportHistoryData() async -> Data? {
    do {
      return try await chatStore.exportJSONData()
    } catch {
      errorMessage = error.localizedDescription
      return nil
    }
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
        settings: settings.generation
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
        settings: settings.generation
      )

      var assistantText = ""
      for try await chunk in stream {
        assistantText += chunk
        updateMessage(id: assistantMessage.id, content: assistantText)
        await chatStore.updateMessage(id: assistantMessage.id, content: assistantText)
      }

      await chatStore.save()
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
}
