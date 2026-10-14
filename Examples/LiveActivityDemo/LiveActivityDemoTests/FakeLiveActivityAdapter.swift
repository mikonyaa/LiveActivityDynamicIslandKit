import ActivityKit
import Foundation
import LiveActivityKit
@testable import LiveActivityDemo

@MainActor
final class FakeLiveActivityAdapter: LiveActivityDemoAdapter {
    var areActivitiesEnabled = true
    var sessions: [DemoActivitySession] = []
    var updates: [(String, ActivityContent<LiveActivityAttributes.ContentState>)] = []
    var endings: [(String, ActivityContent<LiveActivityAttributes.ContentState>)] = []
    var requests: [DemoActivitySession] = []
    var suspendUpdates = false
    var suspendEnd = false
    var updateError: DemoActivityError?
    var endError: DemoActivityError?
    var stateTerminations: [String: Int] = [:]
    var authorizationTerminations = 0
    private var heldUpdate: CheckedContinuation<Void, Never>?
    private var heldEnd: CheckedContinuation<Void, Never>?
    private var stateContinuations: [String: AsyncStream<DemoActivityState>.Continuation] = [:]
    private var enablementContinuation: AsyncStream<Bool>.Continuation?

    func request(
        attributes: LiveActivityAttributes,
        content: ActivityContent<LiveActivityAttributes.ContentState>
    ) throws -> DemoActivitySession {
        try DemoActivityPayload.validate(attributes: attributes, content: content)
        let session = DemoActivitySession(id: "session-\(requests.count + 1)", attributes: attributes, content: content, state: .active)
        sessions.append(session)
        requests.append(session)
        return session
    }

    func update(id: String, content: ActivityContent<LiveActivityAttributes.ContentState>) async throws {
        updates.append((id, content))
        if suspendUpdates {
            await withCheckedContinuation { heldUpdate = $0 }
        }
        if let updateError { throw updateError }
        if let index = sessions.firstIndex(where: { $0.id == id }) {
            sessions[index].content = content
        }
    }

    func end(id: String, content: ActivityContent<LiveActivityAttributes.ContentState>) async throws {
        if let endError { throw endError }
        endings.append((id, content))
        if suspendEnd {
            await withCheckedContinuation { heldEnd = $0 }
        }
        sessions.removeAll { $0.id == id }
    }

    func states(for id: String) -> AsyncStream<DemoActivityState> {
        AsyncStream { continuation in
            stateContinuations[id] = continuation
            continuation.onTermination = { [weak self] _ in
                Task { @MainActor in self?.stateTerminations[id, default: 0] += 1 }
            }
        }
    }

    func enablementUpdates() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            enablementContinuation = continuation
            continuation.onTermination = { [weak self] _ in
                Task { @MainActor in self?.authorizationTerminations += 1 }
            }
        }
    }

    func emit(_ state: DemoActivityState, id: String = "session-1") {
        if let index = sessions.firstIndex(where: { $0.id == id }) {
            sessions[index].state = state
        }
        stateContinuations[id]?.yield(state)
    }

    func setEnabled(_ enabled: Bool) {
        areActivitiesEnabled = enabled
        enablementContinuation?.yield(enabled)
    }

    func releaseUpdate() {
        heldUpdate?.resume()
        heldUpdate = nil
        suspendUpdates = false
    }

    func releaseEnd() {
        heldEnd?.resume()
        heldEnd = nil
        suspendEnd = false
    }
}
