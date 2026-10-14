import ActivityKit
import Foundation
import Testing
@testable import LiveActivityDemo

@Suite("ActivityKit payload boundary")
struct LiveActivityPayloadTests {
    @Test("Every actual demo state fits the combined attributes and content budget")
    func demoPayloadsFit() throws {
        for recipe in LiveActivityRecipes.all {
            for model in recipe.states {
                let attributes = LiveActivityAttributes(scenario: recipe.scenario, activityID: model.id)
                let content = ActivityContent(state: LiveActivityAttributes.ContentState(model: model.liveTimelineSnapshot()), staleDate: nil)
                let bytes = try DemoActivityPayload.byteCount(attributes: attributes, content: content)
                #expect(bytes < 4096)
                try DemoActivityPayload.validate(attributes: attributes, content: content)
            }
        }
    }

    @Test("Oversized UTF8 content has a predictable error without string truncation")
    func rejectsOversizedPayload() throws {
        var model = LiveActivityRecipes.delivery.states[0]
        model.subtitle = String(repeating: "界", count: 2000)
        let attributes = LiveActivityAttributes(scenario: .delivery, activityID: "delivery-1")
        let content = ActivityContent(state: LiveActivityAttributes.ContentState(model: model), staleDate: nil)
        do {
            try DemoActivityPayload.validate(attributes: attributes, content: content)
            Issue.record("Oversized data was accepted")
        } catch DemoActivityError.payloadTooLarge(let bytes) {
            #expect(bytes > 6000)
            #expect(content.state.model.subtitle.count == 2000)
        }
    }

    @Test("Production request boundary rejects oversized data before requesting a system session")
    @MainActor
    func productionBoundary() throws {
        var model = LiveActivityRecipes.delivery.states[0]
        model.title = String(repeating: "x", count: 5000)
        let adapter = SystemLiveActivityDemoAdapter()
        do {
            _ = try adapter.request(
                attributes: LiveActivityAttributes(scenario: .delivery, activityID: "delivery-1"),
                content: ActivityContent(state: .init(model: model), staleDate: nil)
            )
            Issue.record("Production adapter accepted oversized input")
        } catch DemoActivityError.payloadTooLarge(let bytes) {
            #expect(bytes > 5000)
        }
    }
}
