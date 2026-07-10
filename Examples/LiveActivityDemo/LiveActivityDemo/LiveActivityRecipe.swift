import Foundation
import LiveActivityKit

struct LiveActivityRecipe: Identifiable, Hashable, Sendable {
    var id: LiveActivityScenario { scenario }
    var scenario: LiveActivityScenario
    var states: [LiveActivityContentModel]

    init(
        scenario: LiveActivityScenario,
        states: [LiveActivityContentModel]
    ) {
        self.scenario = scenario
        self.states = states
    }

    var firstState: LiveActivityContentModel? {
        states.first
    }
}

enum LiveActivityRecipes {
    static var all: [LiveActivityRecipe] {
        [
            delivery,
            ride,
            timer,
            sports,
            download,
            trip
        ]
    }

    static func recipe(for scenario: LiveActivityScenario) -> LiveActivityRecipe {
        all.first { $0.scenario == scenario } ?? delivery
    }

    static func state(
        for scenario: LiveActivityScenario,
        index: Int
    ) -> LiveActivityContentModel {
        let recipe = recipe(for: scenario)
        guard let fallback = delivery.firstState else {
            preconditionFailure("The delivery demo recipe must contain at least one state.")
        }
        guard !recipe.states.isEmpty else { return fallback }
        let safeIndex = min(max(index, 0), recipe.states.count - 1)
        return recipe.states[safeIndex]
    }

    static let baseDate = Date(timeIntervalSinceReferenceDate: 795_000_000)

    static func timeline(
        minutes: TimeInterval,
        remaining: String
    ) -> LiveActivityTimeline {
        LiveActivityTimeline(
            startedAt: baseDate,
            estimatedEnd: baseDate.addingTimeInterval(minutes * 60),
            remainingText: remaining
        )
    }
}
