import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
  enum Role: String, Codable {
    case system
    case user
    case assistant
  }

  let id: UUID
  let role: Role
  var content: String
  let createdAt: Date

  init(id: UUID = UUID(), role: Role, content: String, createdAt: Date = Date()) {
    self.id = id
    self.role = role
    self.content = content
    self.createdAt = createdAt
  }
}

struct ChatHistory: Codable, Equatable {
  var summary: String?
  var messages: [ChatMessage]
}
