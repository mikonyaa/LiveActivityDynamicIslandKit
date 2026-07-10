import Foundation
import Testing
@testable import LiveActivityKit

@Suite("LiveActivityKit")
struct LiveActivityKitTests {
    @Test("Content stays domain-neutral and carries presentation metadata")
    func contentCarriesPresentationMetadata() {
        let model = makeModel()

        #expect(model.symbolName == "shippingbox.fill")
        #expect(model.accessibilityTitle == "Package delivery")
        #expect(model.accessibilitySummary.contains("Package delivery"))
        #expect(model.accessibilitySummary.contains(model.primaryValue))
    }

    @Test("Progress clamps initializer input")
    func progressClampsInitializerInput() {
        #expect(LiveActivityProgress(fraction: -1, label: "low").fraction == 0)
        #expect(LiveActivityProgress(fraction: 2, label: "high").fraction == 1)
    }

    @Test("Progress clamps decoded input")
    func progressClampsDecodedInput() throws {
        let decoded = try JSONDecoder().decode(
            LiveActivityProgress.self,
            from: Data(#"{"fraction":4.5,"label":"high","isIndeterminate":false}"#.utf8)
        )

        #expect(decoded.fraction == 1)
    }

    @Test("Live timeline snapshots keep ActivityKit content fresh")
    func liveTimelineSnapshotKeepsActivityFresh() {
        let now = Date(timeIntervalSinceReferenceDate: 900_000_000)
        let snapshot = makeModel().liveTimelineSnapshot(now: now)

        #expect(snapshot.timeline.startedAt == now)
        #expect(snapshot.timeline.estimatedEnd > now)
    }

    private func makeModel() -> LiveActivityContentModel {
        LiveActivityContentModel(
            id: "delivery-1",
            symbolName: "shippingbox.fill",
            accessibilityTitle: "Package delivery",
            phase: .active,
            title: "On the way",
            subtitle: "Courier is moving through the city",
            primaryValue: "8:22",
            secondaryValue: "En route",
            footnote: "Three stops before you",
            progress: LiveActivityProgress(fraction: 0.54, label: "54%"),
            timeline: LiveActivityTimeline(
                startedAt: Date(timeIntervalSinceReferenceDate: 800_000_000),
                estimatedEnd: Date(timeIntervalSinceReferenceDate: 800_001_200),
                remainingText: "22 min"
            ),
            leadingLabel: "Pickup",
            trailingLabel: "Home",
            accent: .blue
        )
    }
}
