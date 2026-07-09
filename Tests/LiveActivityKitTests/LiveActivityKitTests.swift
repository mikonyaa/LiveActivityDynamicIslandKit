import Testing
import Foundation
@testable import LiveActivityKit

@Suite("LiveActivityKit")
struct LiveActivityKitTests {
    @Test("Every scenario has a recipe with states")
    func everyScenarioHasRecipe() {
        #expect(LiveActivityRecipes.all.count == LiveActivityScenario.allCases.count)

        for scenario in LiveActivityScenario.allCases {
            let recipe = LiveActivityRecipes.recipe(for: scenario)
            #expect(recipe.scenario == scenario)
            #expect(recipe.states.count >= 4)
        }
    }

    @Test("Progress clamps to a valid range")
    func progressClamps() {
        #expect(LiveActivityProgress(fraction: -1, label: "low").fraction == 0)
        #expect(LiveActivityProgress(fraction: 2, label: "high").fraction == 1)
    }

    @Test("Deep links use the demo scheme")
    func deepLinkUsesDemoScheme() {
        let link = LiveActivityDeepLink(scenario: .delivery, stateID: "delivery-1")
        #expect(link.url.scheme == "liveactivitydemo")
        #expect(link.url.absoluteString.contains("delivery"))
    }

    @Test("Accessibility summaries include useful state")
    func accessibilitySummaryIncludesState() {
        let model = LiveActivityRecipes.delivery.firstState
        #expect(model.accessibilitySummary.contains(model.title))
        #expect(model.accessibilitySummary.contains(model.primaryValue))
    }

    @Test("Live timeline snapshots keep ActivityKit content fresh")
    func liveTimelineSnapshotKeepsActivityFresh() {
        let now = Date(timeIntervalSinceReferenceDate: 900_000_000)
        let snapshot = LiveActivityRecipes.delivery.states[3].liveTimelineSnapshot(now: now)

        #expect(snapshot.timeline.startedAt == now)
        #expect(snapshot.timeline.estimatedEnd > now)
    }
}
