@preconcurrency import ActivityKit
import Foundation
import LiveActivityKit

enum DemoActivityState: Sendable {
    case active, stale, pending, ended, dismissed, unknown
}

struct DemoActivitySession {
    var id: String
    var attributes: LiveActivityAttributes
    var content: ActivityContent<LiveActivityAttributes.ContentState>
    var state: DemoActivityState
}

@MainActor
protocol LiveActivityDemoAdapter: AnyObject {
    var areActivitiesEnabled: Bool { get }
    var sessions: [DemoActivitySession] { get }
    func request(
        attributes: LiveActivityAttributes,
        content: ActivityContent<LiveActivityAttributes.ContentState>
    ) throws -> DemoActivitySession
    func update(id: String, content: ActivityContent<LiveActivityAttributes.ContentState>) async throws
    func end(id: String, content: ActivityContent<LiveActivityAttributes.ContentState>) async throws
    func states(for id: String) -> AsyncStream<DemoActivityState>
    func enablementUpdates() -> AsyncStream<Bool>
}

enum DemoActivityError: LocalizedError {
    case payloadTooLarge(bytes: Int)
    case missingSession

    var errorDescription: String? {
        switch self {
        case .payloadTooLarge(let bytes):
            "Live Activity data is \(bytes) bytes; attributes and content must fit within 4 KB (4096 bytes)."
        case .missingSession:
            "The system no longer has this Live Activity."
        }
    }
}

/// App integration preflight; the rendering package does not limit external strings.
enum DemoActivityPayload {
    static func byteCount(
        attributes: LiveActivityAttributes,
        content: ActivityContent<LiveActivityAttributes.ContentState>
    ) throws -> Int {
        let encoder = JSONEncoder()
        return try encoder.encode(attributes).count + encoder.encode(content.state).count
    }

    static func validate(
        attributes: LiveActivityAttributes,
        content: ActivityContent<LiveActivityAttributes.ContentState>
    ) throws {
        let bytes = try byteCount(attributes: attributes, content: content)
        guard bytes <= 4096 else { throw DemoActivityError.payloadTooLarge(bytes: bytes) }
    }
}

@MainActor
final class SystemLiveActivityDemoAdapter: LiveActivityDemoAdapter {
    private let authorization = ActivityAuthorizationInfo()
    private var handles: [String: Activity<LiveActivityAttributes>] = [:]

    var areActivitiesEnabled: Bool { authorization.areActivitiesEnabled }

    var sessions: [DemoActivitySession] {
        Activity<LiveActivityAttributes>.activities.map { activity in
            handles[activity.id] = activity
            return snapshot(activity)
        }
    }

    func request(
        attributes: LiveActivityAttributes,
        content: ActivityContent<LiveActivityAttributes.ContentState>
    ) throws -> DemoActivitySession {
        try DemoActivityPayload.validate(attributes: attributes, content: content)
        let activity = try Activity.request(attributes: attributes, content: content, pushType: nil)
        handles[activity.id] = activity
        return snapshot(activity)
    }

    func update(id: String, content: ActivityContent<LiveActivityAttributes.ContentState>) async throws {
        guard let activity = handles[id] else { throw DemoActivityError.missingSession }
        try DemoActivityPayload.validate(attributes: activity.attributes, content: content)
        await activity.update(content)
    }

    func end(id: String, content: ActivityContent<LiveActivityAttributes.ContentState>) async throws {
        guard let activity = handles[id] else { throw DemoActivityError.missingSession }
        try DemoActivityPayload.validate(attributes: activity.attributes, content: content)
        await activity.end(content, dismissalPolicy: .after(Date().addingTimeInterval(30)))
        handles[id] = nil
    }

    func states(for id: String) -> AsyncStream<DemoActivityState> {
        guard let activity = handles[id] else { return AsyncStream { $0.finish() } }
        return AsyncStream { continuation in
            let task = Task { @MainActor [weak self] in
                for await state in activity.activityStateUpdates {
                    guard !Task.isCancelled else { break }
                    continuation.yield(Self.map(state))
                    if state == .ended || state == .dismissed {
                        self?.handles[id] = nil
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func enablementUpdates() -> AsyncStream<Bool> {
        let authorization = authorization
        return AsyncStream { continuation in
            let task = Task { @MainActor in
                for await enabled in authorization.activityEnablementUpdates {
                    guard !Task.isCancelled else { break }
                    continuation.yield(enabled)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private func snapshot(_ activity: Activity<LiveActivityAttributes>) -> DemoActivitySession {
        DemoActivitySession(id: activity.id, attributes: activity.attributes, content: activity.content, state: Self.map(activity.activityState))
    }

    private static func map(_ state: ActivityState) -> DemoActivityState {
        switch state {
        case .active: .active
        case .stale: .stale
        case .ended: .ended
        case .dismissed: .dismissed
#if compiler(>=6.2)
        case .pending: .pending
#endif
        @unknown default: .unknown
        }
    }
}
