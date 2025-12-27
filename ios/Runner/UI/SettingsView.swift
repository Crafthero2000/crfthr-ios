import SwiftUI

struct SettingsView: View {
  @ObservedObject var viewModel: SettingsViewModel

  var body: some View {
    Form {
      Section("settings.section.model") {
        if viewModel.models.isEmpty {
          Text("settings.no_models")
            .foregroundColor(.secondary)
        } else {
          Picker("settings.selected_model", selection: Binding(
            get: { viewModel.selectedModelId ?? "" },
            set: { newValue in
              viewModel.updateSelectedModelId(newValue.isEmpty ? nil : newValue)
            }
          )) {
            Text("settings.none").tag("")
            ForEach(viewModel.models) { model in
              Text(model.displayName).tag(model.id)
            }
          }
        }
      }

      Section("settings.section.generation") {
        Stepper(value: Binding(
          get: { viewModel.generation.maxTokens },
          set: { newValue in
            var updated = viewModel.generation
            updated.maxTokens = newValue
            viewModel.updateGeneration(updated)
          }
        ), in: 64...2048, step: 32) {
          Text(
            String(
              format: NSLocalizedString("settings.max_tokens", comment: "Max tokens"),
              viewModel.generation.maxTokens
            )
          )
        }

        VStack(alignment: .leading) {
          Text(
            String(
              format: NSLocalizedString("settings.temperature", comment: "Temperature"),
              viewModel.generation.temperature
            )
          )
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
          Text(
            String(
              format: NSLocalizedString("settings.top_p", comment: "Top P"),
              viewModel.generation.topP
            )
          )
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
          Text(
            String(
              format: NSLocalizedString("settings.context_limit", comment: "Context limit"),
              viewModel.generation.contextLimit
            )
          )
        }
      }

      Section("settings.section.system_prompt") {
        ZStack(alignment: .topLeading) {
          TextEditor(text: Binding(
            get: { viewModel.systemPrompt },
            set: { newValue in
              viewModel.updateSystemPrompt(newValue)
            }
          ))
          .frame(minHeight: 120)

          if viewModel.systemPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Text("settings.system_prompt.placeholder")
              .foregroundColor(.secondary)
              .padding(.top, 8)
              .padding(.leading, 5)
              .allowsHitTesting(false)
          }
        }

        Text("settings.system_prompt.help")
          .font(.footnote)
          .foregroundColor(.secondary)

        Button("settings.system_prompt.reset") {
          viewModel.resetSystemPrompt()
        }
      }
    }
    .navigationTitle("settings.title")
    .onReceive(NotificationCenter.default.publisher(for: .modelStoreDidChange)) { _ in
      Task { await viewModel.reloadModels() }
    }
  }
}
