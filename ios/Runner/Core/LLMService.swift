import Foundation
import MLX
import MLXLMCommon
import MLXLLM

enum LLMServiceError: LocalizedError {
  case modelNotSelected
  case modelNotAvailable
  case modelDirectoryMissing
  case modelNotLoaded
  case modelLoadFailed(String)
  case generationFailed(String)

  var errorDescription: String? {
    switch self {
    case .modelNotSelected:
      return NSLocalizedString("error.model.not_selected", comment: "Model not selected")
    case .modelNotAvailable:
      return NSLocalizedString("error.model.not_available", comment: "Model not available")
    case .modelDirectoryMissing:
      return NSLocalizedString("error.model.missing", comment: "Model directory missing")
    case .modelNotLoaded:
      return NSLocalizedString("error.model.not_loaded", comment: "Model not loaded")
    case .modelLoadFailed(let detail):
      return String(format: NSLocalizedString("error.model.load_failed", comment: "Model load failed"), detail)
    case .generationFailed(let detail):
      return String(format: NSLocalizedString("error.generation_failed", comment: "Generation failed"), detail)
    }
  }
}

actor LLMService {
  private let modelStore: ModelStore
  private var modelContainer: ModelContainer?
  private var loadedModelId: String?

  init(modelStore: ModelStore) {
    self.modelStore = modelStore
  }

  func loadModelIfNeeded(
    record: ModelRecord,
    progress: @escaping @Sendable (Double, String?) -> Void
  ) async throws {
    if loadedModelId == record.id, modelContainer != nil { return }

    guard let configuration = await modelStore.configuration(for: record) else {
      throw LLMServiceError.modelDirectoryMissing
    }

    do {
      let container = try await LLMModelFactory.shared.loadContainer(
        configuration: configuration,
        progressHandler: { progressUpdate in
          progress(progressUpdate.fractionCompleted, progressUpdate.localizedDescription)
        }
      )
      modelContainer = container
      loadedModelId = record.id
    } catch let error as ModelFactoryError {
      throw LLMServiceError.modelLoadFailed(error.localizedDescription)
    } catch {
      throw LLMServiceError.modelLoadFailed(error.localizedDescription)
    }
  }

  func unloadModel() {
    modelContainer = nil
    loadedModelId = nil
  }

  func summarizeIfNeeded(
    messages: [ChatMessage],
    summary: String?,
    settings: GenerationSettings,
    systemPrompt: String
  ) async throws -> (summary: String?, messages: [ChatMessage]) {
    let limit = settings.contextLimit
    guard limit > 0 else { return (summary, messages) }
    guard messages.count > 8 else { return (summary, messages) }

    let estimatedTokens = await estimateTokenCount(
      messages: messages,
      summary: summary,
      systemPrompt: systemPrompt
    )
    if estimatedTokens <= limit { return (summary, messages) }

    let keepCount = 8
    let pruned = Array(messages.dropLast(keepCount))
    let kept = Array(messages.suffix(keepCount))

    let updatedSummary = try await generateSummary(previousSummary: summary, messages: pruned)
    return (updatedSummary, kept)
  }

  func streamResponse(
    messages: [ChatMessage],
    summary: String?,
    settings: GenerationSettings,
    systemPrompt: String
  ) async throws -> AsyncThrowingStream<String, Error> {
    guard let container = modelContainer else { throw LLMServiceError.modelNotLoaded }

    let chatMessages = buildChatMessages(
      messages: messages,
      summary: summary,
      systemPrompt: systemPrompt
    )
    let userInput = UserInput(chat: chatMessages)
    let parameters = GenerateParameters(
      maxTokens: settings.maxTokens,
      maxKVSize: settings.contextLimit > 0 ? settings.contextLimit : nil,
      temperature: Float(settings.temperature),
      topP: Float(settings.topP)
    )

    let (stream, continuation) = AsyncThrowingStream<String, Error>.makeStream()

    let task = Task {
      do {
        try await container.perform { context in
          let input = try await context.processor.prepare(input: userInput)
          let generationStream = try MLXLMCommon.generate(
            input: input,
            parameters: parameters,
            context: context
          )

          for await generation in generationStream {
            if let chunk = generation.chunk {
              continuation.yield(chunk)
            }
          }
        }

        Stream().synchronize()
        continuation.finish()
      } catch {
        continuation.finish(throwing: error)
      }
    }

    continuation.onTermination = { _ in
      task.cancel()
    }

    return stream
  }

  private func generateSummary(previousSummary: String?, messages: [ChatMessage]) async throws -> String {
    guard let container = modelContainer else { throw LLMServiceError.modelNotLoaded }

    let instruction = "Ты сохраняешь краткую память диалога. Используй ровно шаблон:\nФакты: ...\nКонтекст: ...\nСтиль: ..."

    var bodyLines: [String] = []
    if let previousSummary, !previousSummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      bodyLines.append("Предыдущее резюме:\n\(previousSummary)")
    }
    bodyLines.append("Новые сообщения:")
    bodyLines.append(contentsOf: messages.map { "\($0.role.rawValue): \($0.content)" })

    let chat: [Chat.Message] = [
      .system(instruction),
      .user(bodyLines.joined(separator: "\n"))
    ]

    let userInput = UserInput(chat: chat)
    let parameters = GenerateParameters(
      maxTokens: 256,
      temperature: 0.2,
      topP: 0.9
    )

    do {
      let output = try await container.perform { context in
        let input = try await context.processor.prepare(input: userInput)
        let generationStream = try MLXLMCommon.generate(
          input: input,
          parameters: parameters,
          context: context
        )

        var text = ""
        for await generation in generationStream {
          if let chunk = generation.chunk {
            text += chunk
          }
        }

        Stream().synchronize()
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
      }
      return output
    } catch {
      throw LLMServiceError.generationFailed(error.localizedDescription)
    }
  }

  private func estimateTokenCount(
    messages: [ChatMessage],
    summary: String?,
    systemPrompt: String
  ) async -> Int {
    guard let container = modelContainer else { return approximateTokenCount(messages: messages, summary: summary) }

    return await container.perform { context in
      let rawMessages = buildRawMessages(
        messages: messages,
        summary: summary,
        systemPrompt: systemPrompt
      )
      do {
        let tokens = try context.tokenizer.applyChatTemplate(messages: rawMessages)
        return tokens.count
      } catch {
        return approximateTokenCount(messages: messages, summary: summary)
      }
    }
  }

  private func approximateTokenCount(messages: [ChatMessage], summary: String?) -> Int {
    let summaryText = summary ?? ""
    let joined = summaryText + "\n" + messages.map { $0.content }.joined(separator: "\n")
    return max(1, joined.count / 4)
  }

  private func buildChatMessages(
    messages: [ChatMessage],
    summary: String?,
    systemPrompt: String
  ) -> [Chat.Message] {
    var result: [Chat.Message] = []
    let trimmedPrompt = systemPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
    if !trimmedPrompt.isEmpty {
      result.append(.system(trimmedPrompt))
    }
    if let summary, !summary.isEmpty {
      result.append(.system("Память:\n\(summary)"))
    }
    result.append(contentsOf: messages.map { message in
      switch message.role {
      case .system:
        return .system(message.content)
      case .user:
        return .user(message.content)
      case .assistant:
        return .assistant(message.content)
      }
    })
    return result
  }

  private func buildRawMessages(
    messages: [ChatMessage],
    summary: String?,
    systemPrompt: String
  ) -> [[String: String]] {
    var raw: [[String: String]] = []
    let trimmedPrompt = systemPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
    if !trimmedPrompt.isEmpty {
      raw.append(["role": "system", "content": trimmedPrompt])
    }
    if let summary, !summary.isEmpty {
      raw.append(["role": "system", "content": "Память:\n\(summary)"])
    }
    raw.append(contentsOf: messages.map { ["role": $0.role.rawValue, "content": $0.content] })
    return raw
  }

  nonisolated static func postProcessResponse(_ text: String) -> String {
    let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
    var result: [Substring] = []
    for line in lines {
      let trimmed = line.trimmingCharacters(in: .whitespaces)
      let isList = trimmed.hasPrefix("- ")
        || trimmed.range(of: #"^\d+\."#, options: .regularExpression) != nil
      if isList, let last = result.last {
        if !last.trimmingCharacters(in: .whitespaces).isEmpty {
          result.append("")
        }
      }
      result.append(line)
    }
    return result.joined(separator: "\n")
  }
}
