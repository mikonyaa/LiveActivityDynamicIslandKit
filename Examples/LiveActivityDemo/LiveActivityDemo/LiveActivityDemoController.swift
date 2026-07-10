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

    private var activeActivity: Activity<LiveActivityAttributes>?

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

    var statusMessage: DemoMessage {
        message ?? DemoMessage(
            title: "Ready for local preview",
            detail: "Choose a recipe, press Start, then check the Lock Screen or Dynamic Island.",
            style: .neutral
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
        guard liveActivitiesEnabled else {
            message = DemoMessage(
                title: "Live Activities are disabled",
                detail: "Enable Live Activities in Settings to test the real system surface.",
                style: .warning
            )
            return
        }

        await endActivity(showMessage: false)

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
            message = DemoMessage(
                title: "Live Activity running",
                detail: "Go Home or lock the simulator to see the system Dynamic Island and Lock Screen surfaces.",
                style: .success
            )
        } catch {
            message = DemoMessage(
                title: "Could not start Live Activity",
                detail: error.localizedDescription,
                style: .warning
            )
        }
    }

    func updateActivity() async {
        guard let activeActivity else { return }
        await activeActivity.update(activityContent(for: currentModel.liveTimelineSnapshot()))
    }

    func endActivity(showMessage: Bool = true) async {
        guard let activeActivity else { return }
        await activeActivity.end(
            activityContent(for: currentModel.liveTimelineSnapshot(), staleDate: nil),
            dismissalPolicy: .after(Date().addingTimeInterval(30))
        )
        self.activeActivity = nil

        if showMessage {
            message = DemoMessage(
                title: "Live Activity ended",
                detail: "The final state remains briefly based on the dismissal policy.",
                style: .success
            )
        }
    }

    func handle(url: URL) {
        guard url.scheme == "liveactivitydemo" else { return }
        guard url.host == "scenario" else { return }
        let scenarioName = url.pathComponents.dropFirst().first
        guard let scenarioName,
              let scenario = LiveActivityScenario(rawValue: scenarioName)
        else { return }

        select(scenario)

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let stateID = components.queryItems?.first(where: { $0.name == "state" })?.value,
              let index = selectedRecipe.states.firstIndex(where: { $0.id == stateID })
        else { return }

        selectedStateIndex = index
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
}

struct DemoMessage: Identifiable, Equatable {
    enum Style {
        case neutral
        case success
        case warning

        var symbolName: String {
            switch self {
            case .neutral:
                "sparkles"
            case .success:
                "checkmark.circle.fill"
            case .warning:
                "exclamationmark.triangle.fill"
            }
        }

        var tint: Color {
            switch self {
            case .neutral:
                .blue
            case .success:
                .green
            case .warning:
                .orange
            }
        }
    }

    let id = UUID()
    var title: String
    var detail: String
    var style: Style
}
