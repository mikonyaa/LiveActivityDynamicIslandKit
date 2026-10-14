import ActivityKit
import Foundation
import LiveActivityKit
import SwiftUI

enum DemoRouteSource {
    case user, restoration
}

@MainActor
@Observable
final class LiveActivityDemoController {
    private(set) var selectedScenario: LiveActivityScenario = .delivery
    private(set) var selectedStateIndex = 0
    var navigationPath: [LiveActivityScenario] = []
    var message: DemoMessage?
    private(set) var routeFeedback: DemoMessage?
    private(set) var lifecycle: LiveActivityDemoLifecycle = .idle
    private(set) var activeSession: DemoActivitySession?
    private(set) var liveActivitiesEnabled: Bool

    @ObservationIgnored private let adapter: any LiveActivityDemoAdapter
    @ObservationIgnored private var stateObserver: Task<Void, Never>?
    @ObservationIgnored private var authorizationObserver: Task<Void, Never>?
    @ObservationIgnored private var generation = UUID()
    @ObservationIgnored private var isDraining = false
    @ObservationIgnored private var pendingUpdate: ActivityContent<LiveActivityAttributes.ContentState>?
    @ObservationIgnored private var pendingEnd: ActivityContent<LiveActivityAttributes.ContentState>?
    @ObservationIgnored private var terminalRequested = false
    private var previewWasSelected = false
    private var restoredPreview: LiveActivityContentModel?
    private var sessionIsCompatible = true

    init(adapter: any LiveActivityDemoAdapter = SystemLiveActivityDemoAdapter()) {
        self.adapter = adapter
        liveActivitiesEnabled = adapter.areActivitiesEnabled
    }

    deinit {
        stateObserver?.cancel()
        authorizationObserver?.cancel()
    }

    var recipes: [LiveActivityRecipe] { LiveActivityRecipes.all }
    var selectedRecipe: LiveActivityRecipe { LiveActivityRecipes.recipe(for: selectedScenario) }
    var currentModel: LiveActivityContentModel {
        restoredPreview ?? LiveActivityRecipes.state(for: selectedScenario, index: selectedStateIndex)
    }
    var canMoveBackward: Bool { selectedStateIndex > 0 }
    var canMoveForward: Bool { selectedStateIndex < selectedRecipe.states.count - 1 }
    var canStartActivity: Bool {
        activeSession == nil && lifecycle.canStart && liveActivitiesEnabled && !isDraining
    }
    var canUpdateActivity: Bool {
        activeSession?.attributes.scenario == selectedScenario && sessionIsCompatible &&
            liveActivitiesEnabled && lifecycle.canUpdate && !terminalRequested
    }
    var canEndActivity: Bool { activeSession != nil && !terminalRequested }

}

extension LiveActivityDemoController {
    func restoreSession() async {
        observeAuthorization()
        receiveAuthorization(adapter.areActivitiesEnabled)
        guard !isDraining else { return }
        let ongoing = adapter.sessions.filter { $0.state != .ended && $0.state != .dismissed }
        let candidate = ongoing.first(where: { $0.id == activeSession?.id }) ?? ongoing.sorted { $0.id < $1.id }.first
        guard let candidate else {
            if activeSession != nil {
                finishSession()
            } else if lifecycle != .ended {
                lifecycle = liveActivitiesEnabled ? .idle : .unavailable
            }
            return
        }
        install(candidate)
        sessionIsCompatible = validIdentity(candidate)
        guard sessionIsCompatible else {
            lifecycle = .failed("This session has an unknown or incompatible scenario/state. End it before starting a new recipe.")
            message = nil
            return
        }
        if !previewWasSelected {
            _ = applyRoute(
                LiveActivityDemoRoute(scenario: candidate.attributes.scenario, stateID: candidate.content.state.model.id),
                source: .restoration
            )
            restoredPreview = candidate.content.state.model
        }
        lifecycle = lifecycle(for: candidate.state)
        message = nil
    }

    func reconcileForeground() async { await restoreSession() }

    /// Browsing is independent of the immutable identity of the system session.
    func select(_ scenario: LiveActivityScenario) {
        guard let first = LiveActivityRecipes.recipe(for: scenario).firstState else { return }
        _ = applyRoute(LiveActivityDemoRoute(scenario: scenario, stateID: first.id))
    }

    @discardableResult
    func applyRoute(_ route: LiveActivityDemoRoute, source: DemoRouteSource = .user) -> Bool {
        guard let index = LiveActivityRecipes.stateIndex(for: route.scenario, stateID: route.stateID) else {
            routeFeedback = DemoMessage(title: "Unknown recipe state", detail: "The link does not identify one of this demo's snapshots.", style: .warning)
            return false
        }
        withTransaction(Transaction(animation: nil)) {
            selectedScenario = route.scenario
            selectedStateIndex = index
            restoredPreview = nil
            navigationPath = [route.scenario]
            previewWasSelected = source == .user
            routeFeedback = nil
            message = nil
        }
        return true
    }

    @discardableResult
    func handle(url: URL) -> Bool {
        guard let route = LiveActivityDemoRoute(url: url) else {
            routeFeedback = DemoMessage(title: "Invalid activity link", detail: "The scenario URL is malformed or incomplete.", style: .warning)
            return false
        }
        return applyRoute(route)
    }

    func nextState() {
        guard canMoveForward else { return }
        selectState(at: selectedStateIndex + 1)
    }

    func previousState() {
        guard canMoveBackward else { return }
        selectState(at: selectedStateIndex - 1)
    }

    func reset() { selectState(at: 0) }

    func selectState(at index: Int) {
        guard selectedRecipe.states.indices.contains(index) else { return }
        selectedStateIndex = index
        restoredPreview = nil
        previewWasSelected = true
        message = nil
        routeFeedback = nil
        enqueueUpdate(for: currentModel.liveTimelineSnapshot())
        Task { await drain() }
    }

    func startActivity() async {
        observeAuthorization()
        receiveAuthorization(adapter.areActivitiesEnabled)
        guard canStartActivity else { return }
        if adapter.sessions.contains(where: { $0.state != .ended && $0.state != .dismissed }) {
            await restoreSession()
            return
        }
        lifecycle = .starting
        message = nil
        let scenario = selectedScenario
        let model = currentModel.liveTimelineSnapshot()
        do {
            let session = try adapter.request(
                attributes: LiveActivityAttributes(scenario: scenario, activityID: model.id),
                content: activityContent(for: model)
            )
            install(session)
            sessionIsCompatible = true
            lifecycle = lifecycle(for: session.state)
        } catch {
            lifecycle = .failed(error.localizedDescription)
        }
    }

    func updateActivity() async {
        enqueueUpdate(for: currentModel.liveTimelineSnapshot())
        await drain()
    }

    private func enqueueUpdate(for model: LiveActivityContentModel) {
        guard let session = activeSession, session.attributes.scenario == selectedScenario,
              sessionIsCompatible, liveActivitiesEnabled, !terminalRequested,
              lifecycle.canUpdate || lifecycle == .updating else { return }
        pendingUpdate = activityContent(for: model)
    }

    func endActivity(showMessage: Bool = true) async {
        guard let session = activeSession, !terminalRequested else { return }
        terminalRequested = true
        let finalModel = sessionIsCompatible && session.attributes.scenario == selectedScenario
            ? currentModel.liveTimelineSnapshot() : session.content.state.model
        // Explicit nil is separate from the update content's default deadline.
        pendingEnd = activityContent(for: finalModel, staleDate: nil)
        pendingUpdate = nil
        message = nil
        lifecycle = .ending
        await drain()
    }

    private func drain() async {
        guard !isDraining else { return }
        isDraining = true
        defer { isDraining = false }
        while let session = activeSession {
            let token = generation
            do {
                if let end = pendingEnd {
                    pendingEnd = nil
                    try await adapter.end(id: session.id, content: end)
                    guard generation == token else { return }
                    finishSession()
                    return
                }
                guard !terminalRequested, let update = pendingUpdate else { return }
                pendingUpdate = nil
                lifecycle = .updating
                try await adapter.update(id: session.id, content: update)
                guard generation == token, activeSession?.id == session.id else { return }
                activeSession?.content = update
                if !terminalRequested {
                    lifecycle = lifecycle(for: activeSession?.state ?? .active)
                }
            } catch {
                guard generation == token else { return }
                if terminalRequested && pendingEnd != nil { continue }
                pendingUpdate = nil
                terminalRequested = false
                lifecycle = .failed(error.localizedDescription)
                return
            }
        }
    }

    private func activityContent(for model: LiveActivityContentModel) -> ActivityContent<LiveActivityAttributes.ContentState> {
        activityContent(for: model, staleDate: model.timeline.estimatedEnd)
    }

    private func activityContent(
        for model: LiveActivityContentModel, staleDate: Date?
    ) -> ActivityContent<LiveActivityAttributes.ContentState> {
        ActivityContent(state: .init(model: model), staleDate: staleDate)
    }

    private func validIdentity(_ session: DemoActivitySession) -> Bool {
        let scenario = session.attributes.scenario
        return LiveActivityRecipes.stateIndex(for: scenario, stateID: session.attributes.activityID) != nil &&
            LiveActivityRecipes.stateIndex(for: scenario, stateID: session.content.state.model.id) != nil
    }

    private func install(_ session: DemoActivitySession) {
        if activeSession?.id != session.id {
            stateObserver?.cancel()
            generation = UUID()
            terminalRequested = false
            pendingUpdate = nil
            pendingEnd = nil
            let token = generation
            let stream = adapter.states(for: session.id)
            stateObserver = Task { [weak self] in
                for await state in stream {
                    guard !Task.isCancelled else { return }
                    self?.receive(state, id: session.id, token: token)
                }
            }
        }
        activeSession = session
    }

    private func finishSession() {
        stateObserver?.cancel()
        stateObserver = nil
        generation = UUID()
        activeSession = nil
        pendingUpdate = nil
        pendingEnd = nil
        terminalRequested = false
        message = nil
        lifecycle = .ended
    }

    private func receive(_ state: DemoActivityState, id: String, token: UUID) {
        guard generation == token, activeSession?.id == id else { return }
        activeSession?.state = state
        if state == .ended || state == .dismissed {
            finishSession()
        } else if !isDraining && !terminalRequested && sessionIsCompatible {
            lifecycle = lifecycle(for: state)
            message = nil
        }
    }

    private func lifecycle(for state: DemoActivityState) -> LiveActivityDemoLifecycle {
        switch state {
        case .active: .active
        case .stale: .stale
        case .pending: .starting
        case .ended, .dismissed: .ended
        case .unknown: .failed("The system reported an unsupported activity state. End this session before starting another.")
        }
    }

    private func observeAuthorization() {
        guard authorizationObserver == nil else { return }
        let stream = adapter.enablementUpdates()
        authorizationObserver = Task { [weak self] in
            for await enabled in stream {
                guard !Task.isCancelled else { return }
                self?.receiveAuthorization(enabled)
            }
        }
    }

    private func receiveAuthorization(_ enabled: Bool) {
        liveActivitiesEnabled = enabled
        if activeSession == nil && !isDraining {
            if !enabled {
                lifecycle = .unavailable
            } else if lifecycle == .unavailable {
                lifecycle = .idle
                message = nil
            }
        }
        if !enabled { pendingUpdate = nil }
    }
}
