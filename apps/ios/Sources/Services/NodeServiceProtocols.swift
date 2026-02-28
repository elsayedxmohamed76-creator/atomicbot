import CoreLocation
import Foundation
import AtomicBotKit
import UIKit

protocol CameraServicing: Sendable {
    func listDevices() async -> [CameraController.CameraDeviceInfo]
    func snap(params: AtomicBotCameraSnapParams) async throws -> (format: String, base64: String, width: Int, height: Int)
    func clip(params: AtomicBotCameraClipParams) async throws -> (format: String, base64: String, durationMs: Int, hasAudio: Bool)
}

protocol ScreenRecordingServicing: Sendable {
    func record(
        screenIndex: Int?,
        durationMs: Int?,
        fps: Double?,
        includeAudio: Bool?,
        outPath: String?) async throws -> String
}

@MainActor
protocol LocationServicing: Sendable {
    func authorizationStatus() -> CLAuthorizationStatus
    func accuracyAuthorization() -> CLAccuracyAuthorization
    func ensureAuthorization(mode: AtomicBotLocationMode) async -> CLAuthorizationStatus
    func currentLocation(
        params: AtomicBotLocationGetParams,
        desiredAccuracy: AtomicBotLocationAccuracy,
        maxAgeMs: Int?,
        timeoutMs: Int?) async throws -> CLLocation
    func startLocationUpdates(
        desiredAccuracy: AtomicBotLocationAccuracy,
        significantChangesOnly: Bool) -> AsyncStream<CLLocation>
    func stopLocationUpdates()
    func startMonitoringSignificantLocationChanges(onUpdate: @escaping @Sendable (CLLocation) -> Void)
    func stopMonitoringSignificantLocationChanges()
}

protocol DeviceStatusServicing: Sendable {
    func status() async throws -> AtomicBotDeviceStatusPayload
    func info() -> AtomicBotDeviceInfoPayload
}

protocol PhotosServicing: Sendable {
    func latest(params: AtomicBotPhotosLatestParams) async throws -> AtomicBotPhotosLatestPayload
}

protocol ContactsServicing: Sendable {
    func search(params: AtomicBotContactsSearchParams) async throws -> AtomicBotContactsSearchPayload
    func add(params: AtomicBotContactsAddParams) async throws -> AtomicBotContactsAddPayload
}

protocol CalendarServicing: Sendable {
    func events(params: AtomicBotCalendarEventsParams) async throws -> AtomicBotCalendarEventsPayload
    func add(params: AtomicBotCalendarAddParams) async throws -> AtomicBotCalendarAddPayload
}

protocol RemindersServicing: Sendable {
    func list(params: AtomicBotRemindersListParams) async throws -> AtomicBotRemindersListPayload
    func add(params: AtomicBotRemindersAddParams) async throws -> AtomicBotRemindersAddPayload
}

protocol MotionServicing: Sendable {
    func activities(params: AtomicBotMotionActivityParams) async throws -> AtomicBotMotionActivityPayload
    func pedometer(params: AtomicBotPedometerParams) async throws -> AtomicBotPedometerPayload
}

struct WatchMessagingStatus: Sendable, Equatable {
    var supported: Bool
    var paired: Bool
    var appInstalled: Bool
    var reachable: Bool
    var activationState: String
}

struct WatchQuickReplyEvent: Sendable, Equatable {
    var replyId: String
    var promptId: String
    var actionId: String
    var actionLabel: String?
    var sessionKey: String?
    var note: String?
    var sentAtMs: Int?
    var transport: String
}

struct WatchNotificationSendResult: Sendable, Equatable {
    var deliveredImmediately: Bool
    var queuedForDelivery: Bool
    var transport: String
}

protocol WatchMessagingServicing: AnyObject, Sendable {
    func status() async -> WatchMessagingStatus
    func setReplyHandler(_ handler: (@Sendable (WatchQuickReplyEvent) -> Void)?)
    func sendNotification(
        id: String,
        params: AtomicBotWatchNotifyParams) async throws -> WatchNotificationSendResult
}

extension CameraController: CameraServicing {}
extension ScreenRecordService: ScreenRecordingServicing {}
extension LocationService: LocationServicing {}
