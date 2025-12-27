import SwiftUI

struct RootView: View {
  @ObservedObject var appState: AppState

  var body: some View {
    TabView {
      NavigationStack {
        ChatView(viewModel: appState.chatViewModel)
      }
      .tabItem {
        Label("tab.chat", systemImage: "bubble.left.and.bubble.right")
      }

      NavigationStack {
        ModelManagerView(viewModel: appState.modelManagerViewModel)
      }
      .tabItem {
        Label("tab.models", systemImage: "square.and.arrow.down")
      }

      NavigationStack {
        SettingsView(viewModel: appState.settingsViewModel)
      }
      .tabItem {
        Label("tab.settings", systemImage: "slider.horizontal.3")
      }
    }
  }
}
