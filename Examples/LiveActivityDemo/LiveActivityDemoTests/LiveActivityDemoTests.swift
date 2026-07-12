import Foundation
import Testing
@testable import LiveActivityDemo

@Suite("Live Activity demo")
struct LiveActivityDemoTests {
    @Test("Deep links round-trip exact scenario and state")
    func deepLinkRoundTrip() throws {
        let route = LiveActivityDemoRoute(scenario: .sports, stateID: "sports-final")
        let url = try #require(route.url)

        #expect(LiveActivityDemoRoute(url: url) == route)
    }

    @Test("Malformed or incomplete deep links are rejected")
    func malformedLinksAreRejected() throws {
        #expect(LiveActivityDemoRoute(url: try #require(URL(string: "https://example.com"))) == nil)
        #expect(LiveActivityDemoRoute(url: try #require(URL(string: "liveactivitydemo://scenario/ride"))) == nil)
        #expect(LiveActivityDemoRoute(url: try #require(URL(string: "liveactivitydemo://scenario/unknown?state=one"))) == nil)
    }

    @Test("Lifecycle exposes only valid user actions")
    func lifecycleActions() {
        #expect(LiveActivityDemoLifecycle.idle.canStart)
        #expect(!LiveActivityDemoLifecycle.starting.canStart)
        #expect(LiveActivityDemoLifecycle.active.canUpdate)
        #expect(LiveActivityDemoLifecycle.active.canEnd)
        #expect(LiveActivityDemoLifecycle.updating.isBusy)
        #expect(!LiveActivityDemoLifecycle.ended.canEnd)
    }

    @Test("Recipe state lookup rejects unknown deep-link states")
    func recipeStateLookup() {
        #expect(LiveActivityRecipes.stateIndex(for: .delivery, stateID: "delivery-1") == 0)
        #expect(LiveActivityRecipes.stateIndex(for: .delivery, stateID: "unknown") == nil)
    }
}
