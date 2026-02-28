import Foundation

public enum AtomicBotDeviceCommand: String, Codable, Sendable {
    case status = "device.status"
    case info = "device.info"
}

public enum AtomicBotBatteryState: String, Codable, Sendable {
    case unknown
    case unplugged
    case charging
    case full
}

public enum AtomicBotThermalState: String, Codable, Sendable {
    case nominal
    case fair
    case serious
    case critical
}

public enum AtomicBotNetworkPathStatus: String, Codable, Sendable {
    case satisfied
    case unsatisfied
    case requiresConnection
}

public enum AtomicBotNetworkInterfaceType: String, Codable, Sendable {
    case wifi
    case cellular
    case wired
    case other
}

public struct AtomicBotBatteryStatusPayload: Codable, Sendable, Equatable {
    public var level: Double?
    public var state: AtomicBotBatteryState
    public var lowPowerModeEnabled: Bool

    public init(level: Double?, state: AtomicBotBatteryState, lowPowerModeEnabled: Bool) {
        self.level = level
        self.state = state
        self.lowPowerModeEnabled = lowPowerModeEnabled
    }
}

public struct AtomicBotThermalStatusPayload: Codable, Sendable, Equatable {
    public var state: AtomicBotThermalState

    public init(state: AtomicBotThermalState) {
        self.state = state
    }
}

public struct AtomicBotStorageStatusPayload: Codable, Sendable, Equatable {
    public var totalBytes: Int64
    public var freeBytes: Int64
    public var usedBytes: Int64

    public init(totalBytes: Int64, freeBytes: Int64, usedBytes: Int64) {
        self.totalBytes = totalBytes
        self.freeBytes = freeBytes
        self.usedBytes = usedBytes
    }
}

public struct AtomicBotNetworkStatusPayload: Codable, Sendable, Equatable {
    public var status: AtomicBotNetworkPathStatus
    public var isExpensive: Bool
    public var isConstrained: Bool
    public var interfaces: [AtomicBotNetworkInterfaceType]

    public init(
        status: AtomicBotNetworkPathStatus,
        isExpensive: Bool,
        isConstrained: Bool,
        interfaces: [AtomicBotNetworkInterfaceType])
    {
        self.status = status
        self.isExpensive = isExpensive
        self.isConstrained = isConstrained
        self.interfaces = interfaces
    }
}

public struct AtomicBotDeviceStatusPayload: Codable, Sendable, Equatable {
    public var battery: AtomicBotBatteryStatusPayload
    public var thermal: AtomicBotThermalStatusPayload
    public var storage: AtomicBotStorageStatusPayload
    public var network: AtomicBotNetworkStatusPayload
    public var uptimeSeconds: Double

    public init(
        battery: AtomicBotBatteryStatusPayload,
        thermal: AtomicBotThermalStatusPayload,
        storage: AtomicBotStorageStatusPayload,
        network: AtomicBotNetworkStatusPayload,
        uptimeSeconds: Double)
    {
        self.battery = battery
        self.thermal = thermal
        self.storage = storage
        self.network = network
        self.uptimeSeconds = uptimeSeconds
    }
}

public struct AtomicBotDeviceInfoPayload: Codable, Sendable, Equatable {
    public var deviceName: String
    public var modelIdentifier: String
    public var systemName: String
    public var systemVersion: String
    public var appVersion: String
    public var appBuild: String
    public var locale: String

    public init(
        deviceName: String,
        modelIdentifier: String,
        systemName: String,
        systemVersion: String,
        appVersion: String,
        appBuild: String,
        locale: String)
    {
        self.deviceName = deviceName
        self.modelIdentifier = modelIdentifier
        self.systemName = systemName
        self.systemVersion = systemVersion
        self.appVersion = appVersion
        self.appBuild = appBuild
        self.locale = locale
    }
}
