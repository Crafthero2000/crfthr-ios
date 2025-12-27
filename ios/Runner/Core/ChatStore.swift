import Foundation

struct ChatSnapshot: Equatable {
  var summary: String?
  var messages: [ChatMessage]
}

struct ChatExportItem: Codable, Equatable {
  var role: String
  var content: String
}

actor ChatStore {
  private var summary: String?
  private var messages: [ChatMessage]
  private let historyURL: URL

  init(historyURL: URL = ChatStore.defaultHistoryURL()) {
    self.historyURL = historyURL
    self.summary = nil
    self.messages = []
  }

  static func defaultHistoryURL() -> URL {
    let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    let directory = base.appendingPathComponent("Crfthr", isDirectory: true)
    return directory.appendingPathComponent("chat-history.json")
  }

  func load() async -> ChatSnapshot {
    do {
      let data = try Data(contentsOf: historyURL)
      let history = try JSONDecoder().decode(ChatHistory.self, from: data)
      summary = history.summary
      messages = history.messages
    } catch {
      summary = nil
      messages = []
    }
    return snapshot()
  }

  func snapshot() -> ChatSnapshot {
    ChatSnapshot(summary: summary, messages: messages)
  }

  func append(role: ChatMessage.Role, content: String) -> ChatMessage {
    let message = ChatMessage(role: role, content: content)
    messages.append(message)
    return message
  }

  func updateMessage(id: UUID, content: String) {
    guard let index = messages.firstIndex(where: { $0.id == id }) else { return }
    messages[index].content = content
  }

  func replaceMessages(_ messages: [ChatMessage]) {
    self.messages = messages
  }

  func setSummary(_ summary: String?) {
    self.summary = summary
  }

  func clear() async -> ChatSnapshot {
    summary = nil
    messages = []
    await save()
    return snapshot()
  }

  func save() async {
    do {
      let history = ChatHistory(summary: summary, messages: messages)
      let data = try JSONEncoder().encode(history)
      try FileManager.default.createDirectory(
        at: historyURL.deletingLastPathComponent(),
        withIntermediateDirectories: true
      )
      try data.write(to: historyURL, options: [.atomic])
    } catch {
      // Intentionally ignore persistence errors; UI can still continue.
    }
  }

  func exportItems() -> [ChatExportItem] {
    var items: [ChatExportItem] = []
    if let summary {
      items.append(ChatExportItem(role: "system", content: "Memory:\n\(summary)"))
    }
    items.append(contentsOf: messages.map { ChatExportItem(role: $0.role.rawValue, content: $0.content) })
    return items
  }

  func exportJSONData() throws -> Data {
    let items = exportItems()
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    return try encoder.encode(items)
  }
}
