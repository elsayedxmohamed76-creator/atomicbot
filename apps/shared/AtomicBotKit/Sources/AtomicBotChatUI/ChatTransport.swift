import Foundation

public enum AtomicBotChatTransportEvent: Sendable {
    case health(ok: Bool)
    case tick
    case chat(AtomicBotChatEventPayload)
    case agent(AtomicBotAgentEventPayload)
    case seqGap
}

public protocol AtomicBotChatTransport: Sendable {
    func requestHistory(sessionKey: String) async throws -> AtomicBotChatHistoryPayload
    func sendMessage(
        sessionKey: String,
        message: String,
        thinking: String,
        idempotencyKey: String,
        attachments: [AtomicBotChatAttachmentPayload]) async throws -> AtomicBotChatSendResponse

    func abortRun(sessionKey: String, runId: String) async throws
    func listSessions(limit: Int?) async throws -> AtomicBotChatSessionsListResponse

    func requestHealth(timeoutMs: Int) async throws -> Bool
    func events() -> AsyncStream<AtomicBotChatTransportEvent>

    func setActiveSessionKey(_ sessionKey: String) async throws
}

extension AtomicBotChatTransport {
    public func setActiveSessionKey(_: String) async throws {}

    public func abortRun(sessionKey _: String, runId _: String) async throws {
        throw NSError(
            domain: "AtomicBotChatTransport",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "chat.abort not supported by this transport"])
    }

    public func listSessions(limit _: Int?) async throws -> AtomicBotChatSessionsListResponse {
        throw NSError(
            domain: "AtomicBotChatTransport",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "sessions.list not supported by this transport"])
    }
}
