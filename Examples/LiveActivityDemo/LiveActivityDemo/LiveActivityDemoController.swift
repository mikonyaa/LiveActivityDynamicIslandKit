@preconcurrency import ActivityKit
import Foundation
import LiveActivityKit
import SwiftUI

@MainActor
@Observable
final class LiveActivityDemoController {
    var selectedScenario: LiveActivityScenario = .delivery
    var selectedStateIndex = 0
    var message: DemoMessage?
    private(set) var lifecycle: LiveActivityDemoLifecycle = .idle

    private var activeActivity: Activity<LiveActivityAttributes>?
    private var stateObserver: Task<Void, Never>?
    private var updateRequestedWhileBusy = false

    var recipes: [LiveActivityRecipe] {
        LiveActivityRecipes.all
    }

    var selectedRecipe: LiveActivityRecipe {
        LiveActivityRecipes.recipe(for: selectedScenario)
    }

    var currentModel: LiveActivityContentModel {
        LiveActivityRecipes.state(for: selectedScenario, index: selectedStateIndex)
    }

    var canMoveBackward: Bool {
        selectedStateIndex > 0
    }

    var canMoveForward: Bool {
        selectedStateIndex < selectedRecipe.states.count - 1
    }

    var liveActivitiesEnabled: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    var canStartActivity: Bool { lifecycle.canStart && liveActivitiesEnabled }
    var canUpdateActivity: Bool { lifecycle.canUpdate }
    var canEndActivity: Bool { lifecycle.canEnd }

    func restoreSession() async {
        guard liveActivitiesEnabled else {
            lifecycle = .unavailable
            activeActivity = nil
            return
        }

        guard let activity = Activity<LiveActivityAttributes>.activities.first else {
            lifecycle = .idle
            activeActivity = nil
            return
        }

        activeActivity = activity
        _ = apply(
            scenario: activity.attributes.scenario,
            stateID: activity.content.state.model.id
        )
        lifecycle = lifecycle(for: activity.activityState)
        observe(activity)
        message = DemoMessage(
            title: "Live Activity restored",
            detail: "This session was recovered from ActivityKit after the app relaunched.",
            style: .success
        )
    }

    func select(_ scenario: LiveActivityScenario) {
        withTransaction(Transaction(animation: nil)) {
            selectedScenario = scenario
            selectedStateIndex = 0
        }
        Task { await updateActivity() }
    }

    func nextState() {
        guard canMoveForward else { return }
        selectedStateIndex += 1
        Task { await updateActivity() }
    }

    func previousState() {
        guard canMoveBackward else { return }
        selectedStateIndex -= 1
        Task { await updateActivity() }
    }

    func reset() {
        selectedStateIndex = 0
        message = nil
        Task { await updateActivity() }
    }

    func startActivity() async {
        guard lifecycle.canStart, !lifecycle.isBusy else { return }
        guard liveActivitiesEnabled else {
            lifecycle = .unavailable
            message = DemoMessage(
                title: "Live Activities are disabled",
                detail: "Enable Live Activities in Settings to test the real system surface.",
                style: .warning
            )
            return
        }

        if let existing = Activity<LiveActivityAttributes>.activities.first {
            activeActivity = existing
            lifecycle = lifecycle(for: existing.activityState)
            observe(existing)
            message = DemoMessage(
                title: "Live Activity already running",
                detail: "The existing session was restored instead of creating a duplicate.",
                style: .success
            )
            return
        }

        lifecycle = .starting
        message = nil
        do {
            let model = currentModel.liveTimelineSnapshot()
            let attributes = LiveActivityAttributes(
                scenario: selectedScenario,
                activityID: model.id
            )
            let activity = try Activity.request(
                attributes: attributes,
                content: activityContent(for: model),
                pushType: nil
            )
            activeActivity = activity
            lifecycle = .active
            observe(activity)
            message = DemoMessage(
                title: "Live Activity running",
                detail: "Go Home or lock the simulator to see the system Dynamic Island and Lock Screen surfaces.",
                style: .success
            )
        } catch {
            lifecycle = .failed(error.localizedDescription)
            message = DemoMessage(
                title: "Could not start Live Activity",
                detail: error.localizedDescription,
                style: .warning
            )
        }
    }

    func updateActivity() async {
        guard activeActivity != nil else { return }
        if lifecycle == .updating {
            updateRequestedWhileBusy = true
            return
        }
        guard lifecycle.canUpdate else { return }

        repeat {
            updateRequestedWhileBusy = false
            guard let activeActivity else { return }
            lifecycle = .updating
            await activeActivity.update(activityContent(for: currentModel.liveTimelineSnapshot()))
        } while updateRequestedWhileBusy && self.activeActivity != nil

        if activeActivity != nil {
            lifecycle = .active
        }
    }

    func endActivity(showMessage: Bool = true) async {
        guard let activeActivity, lifecycle.canEnd, !lifecycle.isBusy else { return }
        lifecycle = .ending
        await activeActivity.end(
            activityContent(for: currentModel.liveTimelineSnapshot(), staleDate: nil),
            dismissalPolicy: .after(Date().addingTimeInterval(30))
        )
        self.activeActivity = nil
        stateObserver?.cancel()
        stateObserver = nil
        lifecycle = .ended

        if showMessage {
            message = DemoMessage(
                title: "Live Activity ended",
                detail: "The final state remains briefly based on the dismissal policy.",
                style: .success
            )
        }
    }

    func handle(url: URL) {
        guard let route = LiveActivityDemoRoute(url: url) else { return }
        guard apply(scenario: route.scenario, stateID: route.stateID) else { return }
        Task { await updateActivity() }
    }

    func selectState(at index: Int) {
        guard selectedRecipe.states.indices.contains(index) else { return }
        selectedStateIndex = index
        Task { await updateActivity() }
    }

    private func activityContent(
        for model: LiveActivityContentModel,
        staleDate: Date? = nil
    ) -> ActivityContent<LiveActivityAttributes.ContentState> {
        ActivityContent(
            state: LiveActivityAttributes.ContentState(model: model),
            staleDate: staleDate ?? model.timeline.estimatedEnd
        )
    }

    @discardableResult
    private func apply(scenario: LiveActivityScenario, stateID: String) -> Bool {
        guard let index = LiveActivityRecipes.stateIndex(for: scenario, stateID: stateID) else {
            return false
        }
        withTransaction(Transaction(animation: nil)) {
            selectedScenario = scenario
            selectedStateIndex = index
        }
        return true
    }

    private func observe(_ activity: Activity<LiveActivityAttributes>) {
        stateObserver?.cancel()
        stateObserver = Task { [weak self] in
            for await state in activity.activityStateUpdates {
                guard !Task.isCancelled else { return }
                self?.receive(state)
            }
        }
    }

    // ActivityState gained `pending` in the iOS 26 SDK, so the case is compiled
    // only when the matching Swift toolchain is available.
    private func receive(_ state: ActivityState) {
        let reportedLifecycle = lifecycle(for: state)
        if !(lifecycle.isBusy && reportedLifecycle == .active) {
            lifecycle = reportedLifecycle
        }
        switch state {
        case .ended, .dismissed:
            activeActivity = nil
            stateObserver = nil
        case .active:
            break
        case .stale:
            break
#if compiler(>=6.2)
        case .pending:
            break
#endif
        @unknown default:
            break
        }
    }

    private func lifecycle(for state: ActivityState) -> LiveActivityDemoLifecycle {
        switch state {
        case .active:
            .active
        case .stale:
            .active
#if compiler(>=6.2)
        case .pending:
            .starting
#endif
        case .ended, .dismissed:
            .ended
        @unknown default:
            .idle
        }
    }
}

extension LiveActivityDemoController {
    var statusMessage: DemoMessage {
        if let message { return message }
        switch lifecycle {
        case .unavailable:
            return DemoMessage(
                title: "Live Activities unavailable",
                detail: "Enable Live Activities in Settings to test the system surfaces.",
                style: .warning
            )
        case .active:
            return DemoMessage(
                title: "Live Activity running",
                detail: "Change the timeline below, then check the Lock Screen or Dynamic Island.",
                style: .success
            )
        case .starting, .updating, .ending:
            return DemoMessage(
                title: "Applying lifecycle change",
                detail: "ActivityKit is updating the system presentation.",
                style: .neutral
            )
        case .failed(let detail):
            return DemoMessage(title: "ActivityKit error", detail: detail, style: .warning)
        case .idle, .ended:
            return DemoMessage(
                title: "Ready for local preview",
                detail: "Choose a recipe, press Start, then check the Lock Screen or Dynamic Island.",
                style: .neutral
            )
        }
    }
}
