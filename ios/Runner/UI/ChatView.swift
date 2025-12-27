import SwiftUI
import UIKit

struct ChatView: View {
  @ObservedObject var viewModel: ChatViewModel
  @FocusState private var isInputFocused: Bool

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
        .scrollDismissesKeyboard(.interactively)
        .contentShape(Rectangle())
        .onTapGesture {
          UIApplication.shared.hideKeyboard()
          isInputFocused = false
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
          .focused($isInputFocused)

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
    .navigationTitle("chat.title")
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Menu {
          ShareLink(item: viewModel.exportText) {
            Label("export.text", systemImage: "doc.plaintext")
          }
          .disabled(viewModel.exportText.isEmpty)

          ShareLink(item: viewModel.exportJSON) {
            Label("export.json", systemImage: "doc.text")
          }
          .disabled(viewModel.exportJSON.isEmpty)
        } label: {
          Label("action.export", systemImage: "square.and.arrow.up")
        }
      }

      ToolbarItem(placement: .topBarLeading) {
        Button {
          Task { await viewModel.clearHistory() }
        } label: {
          Label("action.clear", systemImage: "trash")
        }
      }

      ToolbarItemGroup(placement: .keyboard) {
        Spacer()
        Button("action.done") {
          UIApplication.shared.hideKeyboard()
          isInputFocused = false
        }
      }
    }
  }
}
