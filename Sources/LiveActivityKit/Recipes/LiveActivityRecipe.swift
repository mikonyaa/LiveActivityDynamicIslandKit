import Foundation

public struct LiveActivityRecipe: Identifiable, Hashable, Sendable {
    public var id: LiveActivityScenario { scenario }
    public var scenario: LiveActivityScenario
    public var states: [LiveActivityContentModel]

    public init(
        scenario: LiveActivityScenario,
        states: [LiveActivityContentModel]
    ) {
        self.scenario = scenario
        self.states = states
    }

    public var firstState: LiveActivityContentModel {
        states[0]
    }
}

public enum LiveActivityRecipes {
    public static var all: [LiveActivityRecipe] {
        [
            delivery,
            ride,
            timer,
            sports,
            download,
            trip
        ]
    }

    public static func recipe(for scenario: LiveActivityScenario) -> LiveActivityRecipe {
        all.first { $0.scenario == scenario } ?? delivery
    }

    public static func state(
        for scenario: LiveActivityScenario,
        index: Int
    ) -> LiveActivityContentModel {
        let recipe = recipe(for: scenario)
        guard !recipe.states.isEmpty else { return delivery.firstState }
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
