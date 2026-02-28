import Foundation

public enum AtomicBotCameraCommand: String, Codable, Sendable {
    case list = "camera.list"
    case snap = "camera.snap"
    case clip = "camera.clip"
}

public enum AtomicBotCameraFacing: String, Codable, Sendable {
    case back
    case front
}

public enum AtomicBotCameraImageFormat: String, Codable, Sendable {
    case jpg
    case jpeg
}

public enum AtomicBotCameraVideoFormat: String, Codable, Sendable {
    case mp4
}

public struct AtomicBotCameraSnapParams: Codable, Sendable, Equatable {
    public var facing: AtomicBotCameraFacing?
    public var maxWidth: Int?
    public var quality: Double?
    public var format: AtomicBotCameraImageFormat?
    public var deviceId: String?
    public var delayMs: Int?

    public init(
        facing: AtomicBotCameraFacing? = nil,
        maxWidth: Int? = nil,
        quality: Double? = nil,
        format: AtomicBotCameraImageFormat? = nil,
        deviceId: String? = nil,
        delayMs: Int? = nil)
    {
        self.facing = facing
        self.maxWidth = maxWidth
        self.quality = quality
        self.format = format
        self.deviceId = deviceId
        self.delayMs = delayMs
    }
}

public struct AtomicBotCameraClipParams: Codable, Sendable, Equatable {
    public var facing: AtomicBotCameraFacing?
    public var durationMs: Int?
    public var includeAudio: Bool?
    public var format: AtomicBotCameraVideoFormat?
    public var deviceId: String?

    public init(
        facing: AtomicBotCameraFacing? = nil,
        durationMs: Int? = nil,
        includeAudio: Bool? = nil,
        format: AtomicBotCameraVideoFormat? = nil,
        deviceId: String? = nil)
    {
        self.facing = facing
        self.durationMs = durationMs
        self.includeAudio = includeAudio
        self.format = format
        self.deviceId = deviceId
    }
}
