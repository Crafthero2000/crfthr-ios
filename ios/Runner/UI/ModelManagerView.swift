import SwiftUI
import UniformTypeIdentifiers

struct ModelManagerView: View {
  @ObservedObject var viewModel: ModelManagerViewModel
  @State private var isImporting = false

  var body: some View {
    List {
      Section("models.section.installed") {
        if viewModel.models.isEmpty {
          Text("models.none")
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
                Text("models.badge.imported")
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

      Section("models.section.download") {
        TextField("models.repo_id.placeholder", text: $viewModel.repoIdInput)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled(true)

        Button {
          viewModel.downloadModel()
        } label: {
          HStack {
            Image(systemName: "arrow.down.circle")
            Text("models.action.download")
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
            Text("models.section.suggested")
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

      Section("models.section.import") {
        Button {
          isImporting = true
        } label: {
          HStack {
            Image(systemName: "folder")
            Text("models.action.import")
          }
        }
        .disabled(viewModel.isDownloading)
      }

      if let error = viewModel.errorMessage {
        Section("models.section.error") {
          Text(error)
            .foregroundColor(.red)
        }
      }
    }
    .navigationTitle("models.title")
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
