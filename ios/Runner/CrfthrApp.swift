import SwiftUI

@main
struct CrfthrApp: App {
  @StateObject private var appState = AppState()

  var body: some Scene {
    WindowGroup {
      RootView(appState: appState)
        .task {
          await appState.load()
        }
    }
  }
}
