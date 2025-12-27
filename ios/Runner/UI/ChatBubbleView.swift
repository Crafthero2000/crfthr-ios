import SwiftUI

struct ChatBubbleView: View {
  let message: ChatMessage

  var body: some View {
    HStack {
      if message.role == .assistant || message.role == .system {
        bubble
        Spacer(minLength: 40)
      } else {
        Spacer(minLength: 40)
        bubble
      }
    }
    .padding(.horizontal)
  }

  private var bubble: some View {
    Text(message.content)
      .font(.body)
      .foregroundColor(foregroundColor)
      .padding(.vertical, 8)
      .padding(.horizontal, 12)
      .background(backgroundColor)
      .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
      .overlay(
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .stroke(borderColor, lineWidth: message.role == .system ? 1 : 0)
      )
  }

  private var backgroundColor: Color {
    switch message.role {
    case .user:
      return Color.accentColor.opacity(0.85)
    case .assistant:
      return Color(.secondarySystemBackground)
    case .system:
      return Color(.systemBackground)
    }
  }

  private var foregroundColor: Color {
    switch message.role {
    case .user:
      return Color.white
    case .assistant, .system:
      return Color.primary
    }
  }

  private var borderColor: Color {
    Color.accentColor.opacity(0.2)
  }
}
