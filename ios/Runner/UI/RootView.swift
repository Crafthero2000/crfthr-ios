import SwiftUI

struct RootView: View {
  @ObservedObject var appState: AppState

  var body: some View {
    TabView {
      NavigationStack {
        ChatView(viewModel: appState.chatViewModel)
      }
      .tabItem {
        Label("Chat", systemImage: "bubble.left.and.bubble.right")
      }

      NavigationStack {
        ModelManagerView(viewModel: appState.modelManagerViewModel)
      }
      .tabItem {
        Label("Models", systemImage: "square.and.arrow.down")
      }

      NavigationStack {
        SettingsView(viewModel: appState.settingsViewModel)
      }
      .tabItem {
        Label("Settings", systemImage: "slider.horizontal.3")
      }
    }
  }
}
