import SwiftUI

struct ChatView: View {
  @ObservedObject var viewModel: ChatViewModel
  @State private var isExporting = false
  @State private var exportDocument: ChatHistoryDocument?

  var body: some View {
    VStack(spacing: 0) {
      if let statusText = viewModel.modelState.statusText, viewModel.modelState.isLoading {
        HStack {
          ProgressView()
          Text(statusText)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
      }

      ScrollViewReader { proxy in
        ScrollView {
          LazyVStack(spacing: 12) {
            ForEach(viewModel.messages) { message in
              ChatBubbleView(message: message)
                .id(message.id)
            }
          }
          .padding(.vertical, 16)
        }
        .onChange(of: viewModel.messages.count) { _ in
          if let lastId = viewModel.messages.last?.id {
            withAnimation(.easeOut(duration: 0.2)) {
              proxy.scrollTo(lastId, anchor: .bottom)
            }
          }
        }
      }

      if let error = viewModel.errorMessage {
        Text(error)
          .font(.footnote)
          .foregroundColor(.red)
          .padding(.horizontal)
          .padding(.bottom, 4)
      }

      Divider()

      HStack(alignment: .bottom, spacing: 12) {
        TextEditor(text: $viewModel.inputText)
          .frame(minHeight: 36, maxHeight: 120)
          .padding(8)
          .background(Color(.secondarySystemBackground))
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

        Button {
          viewModel.sendMessage()
        } label: {
          Image(systemName: "paperplane.fill")
            .foregroundColor(.white)
            .padding(10)
            .background(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.accentColor)
            .clipShape(Circle())
        }
        .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isGenerating)
      }
      .padding()
      .background(Color(.systemBackground))
    }
    .navigationTitle("Local Assistant")
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          Task {
            if let data = await viewModel.exportHistoryData() {
              exportDocument = ChatHistoryDocument(data: data)
              isExporting = true
            }
          }
        } label: {
          Label("Export", systemImage: "square.and.arrow.up")
        }
      }

      ToolbarItem(placement: .topBarLeading) {
        Button {
          Task { await viewModel.clearHistory() }
        } label: {
          Label("Clear", systemImage: "trash")
        }
      }
    }
    .fileExporter(
      isPresented: $isExporting,
      document: exportDocument,
      contentType: .json,
      defaultFilename: "chat-history"
    ) { result in
      if case .failure(let error) = result {
        viewModel.errorMessage = error.localizedDescription
      }
    }
  }
}
