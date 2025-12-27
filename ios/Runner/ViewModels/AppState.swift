import Combine
import Foundation

@MainActor
final class AppState: ObservableObject {
  let chatStore: ChatStore
  let modelStore: ModelStore
  let settingsStore: SettingsStore
  let llmService: LLMService

  let chatViewModel: ChatViewModel
  let settingsViewModel: SettingsViewModel
  let modelManagerViewModel: ModelManagerViewModel

  init() {
    let modelStore = ModelStore()
    let chatStore = ChatStore()
    let settingsStore = SettingsStore()
    let llmService = LLMService(modelStore: modelStore)

    self.chatStore = chatStore
    self.modelStore = modelStore
    self.settingsStore = settingsStore
    self.llmService = llmService

    self.chatViewModel = ChatViewModel(
      chatStore: chatStore,
      modelStore: modelStore,
      settingsStore: settingsStore,
      llmService: llmService
    )
    self.settingsViewModel = SettingsViewModel(
      modelStore: modelStore,
      settingsStore: settingsStore
    )
    self.modelManagerViewModel = ModelManagerViewModel(
      modelStore: modelStore,
      settingsStore: settingsStore
    )
  }

  func load() async {
    await chatViewModel.load()
    await settingsViewModel.load()
    await modelManagerViewModel.load()
  }
}
