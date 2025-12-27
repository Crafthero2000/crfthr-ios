import SwiftUI

struct SettingsView: View {
  @ObservedObject var viewModel: SettingsViewModel

  var body: some View {
    Form {
      Section("Model") {
        if viewModel.models.isEmpty {
          Text("No models installed yet. Download one in the Models tab.")
            .foregroundColor(.secondary)
        } else {
          Picker("Selected model", selection: Binding(
            get: { viewModel.selectedModelId ?? "" },
            set: { newValue in
              viewModel.updateSelectedModelId(newValue.isEmpty ? nil : newValue)
            }
          )) {
            Text("None").tag("")
            ForEach(viewModel.models) { model in
              Text(model.displayName).tag(model.id)
            }
          }
        }
      }

      Section("Generation") {
        Stepper(value: Binding(
          get: { viewModel.generation.maxTokens },
          set: { newValue in
            var updated = viewModel.generation
            updated.maxTokens = newValue
            viewModel.updateGeneration(updated)
          }
        ), in: 64...2048, step: 32) {
          Text("Max tokens: \(viewModel.generation.maxTokens)")
        }

        VStack(alignment: .leading) {
          Text("Temperature: \(viewModel.generation.temperature, specifier: \"%.2f\")")
          Slider(
            value: Binding(
              get: { viewModel.generation.temperature },
              set: { newValue in
                var updated = viewModel.generation
                updated.temperature = newValue
                viewModel.updateGeneration(updated)
              }
            ),
            in: 0...1.5
          )
        }

        VStack(alignment: .leading) {
          Text("Top P: \(viewModel.generation.topP, specifier: \"%.2f\")")
          Slider(
            value: Binding(
              get: { viewModel.generation.topP },
              set: { newValue in
                var updated = viewModel.generation
                updated.topP = newValue
                viewModel.updateGeneration(updated)
              }
            ),
            in: 0.5...1.0
          )
        }

        Stepper(value: Binding(
          get: { viewModel.generation.contextLimit },
          set: { newValue in
            var updated = viewModel.generation
            updated.contextLimit = newValue
            viewModel.updateGeneration(updated)
          }
        ), in: 512...8192, step: 256) {
          Text("Context limit: \(viewModel.generation.contextLimit)")
        }
      }
    }
    .navigationTitle("Settings")
    .onReceive(NotificationCenter.default.publisher(for: .modelStoreDidChange)) { _ in
      Task { await viewModel.reloadModels() }
    }
  }
}
