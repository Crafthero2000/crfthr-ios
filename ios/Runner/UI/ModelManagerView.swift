import SwiftUI
import UniformTypeIdentifiers

struct ModelManagerView: View {
  @ObservedObject var viewModel: ModelManagerViewModel
  @State private var isImporting = false

  var body: some View {
    List {
      Section("Installed") {
        if viewModel.models.isEmpty {
          Text("No models downloaded yet.")
            .foregroundColor(.secondary)
        } else {
          ForEach(viewModel.models) { model in
            HStack {
              VStack(alignment: .leading, spacing: 4) {
                Text(model.displayName)
                  .font(.headline)
                Text(model.id)
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
              Spacer()
              if model.isLocal {
                Text("Imported")
                  .font(.caption)
                  .padding(.horizontal, 8)
                  .padding(.vertical, 4)
                  .background(Color(.secondarySystemBackground))
                  .clipShape(Capsule())
              }
            }
          }
        }
      }

      Section("Download from Hugging Face") {
        TextField("Repo ID (e.g. mlx-community/Qwen2.5-1.5B-Instruct-4bit)", text: $viewModel.repoIdInput)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled(true)

        Button {
          viewModel.downloadModel()
        } label: {
          HStack {
            Image(systemName: "arrow.down.circle")
            Text("Download model")
          }
        }
        .disabled(viewModel.isDownloading)

        if viewModel.isDownloading {
          ProgressView(value: viewModel.downloadProgress)
          if let status = viewModel.downloadStatus {
            Text(status)
              .font(.footnote)
              .foregroundColor(.secondary)
          }
        }

        if !viewModel.recommendedModels.isEmpty {
          VStack(alignment: .leading, spacing: 6) {
            Text("Suggested")
              .font(.caption)
              .foregroundColor(.secondary)
            ForEach(viewModel.recommendedModels) { model in
              Button {
                viewModel.repoIdInput = model.id
              } label: {
                Text(model.displayName)
              }
            }
          }
        }
      }

      Section("Import local model") {
        Button {
          isImporting = true
        } label: {
          HStack {
            Image(systemName: "folder")
            Text("Import from Files")
          }
        }
        .disabled(viewModel.isDownloading)
      }

      if let error = viewModel.errorMessage {
        Section("Error") {
          Text(error)
            .foregroundColor(.red)
        }
      }
    }
    .navigationTitle("Models")
    .fileImporter(
      isPresented: $isImporting,
      allowedContentTypes: [.folder],
      allowsMultipleSelection: false
    ) { result in
      switch result {
      case .success(let urls):
        guard let url = urls.first else { return }
        let displayName = url.lastPathComponent
        viewModel.importModel(from: url, displayName: displayName)
      case .failure(let error):
        viewModel.errorMessage = error.localizedDescription
      }
    }
  }
}
