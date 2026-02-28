import Foundation

public enum AtomicBotLocationMode: String, Codable, Sendable, CaseIterable {
    case off
    case whileUsing
    case always
}
