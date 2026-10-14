import Foundation
import SwiftUI
import Testing
@testable import LiveActivityKit

@Suite("Model contracts")
struct ModelContractTests {
    @Test("Accessibility includes visible progress, remaining time, and both route labels")
    func accessibilityIncludesEssentialVisibleContent() {
        let summary = makeTransfer().accessibilitySummary

        #expect(summary.contains("12 MB"))
        #expect(summary.contains("25%"))
        #expect(summary.contains("90 seconds"))
        #expect(summary.contains("This Mac"))
        #expect(summary.contains("Archive"))
    }

    @Test("Accessibility omits blank labels and repeated phrases")
    func accessibilityDeduplicatesContent() {
        var model = makeTransfer()
        model.accessibilityTitle = "  File transfer  "
        model.title = "File transfer"
        model.subtitle = "file TRANSFER"
        model.secondaryValue = "12 MB"
        model.footnote = " \n "
        model.leadingLabel = "This Mac"
        model.trailingLabel = " this mac "

        #expect(model.accessibilitySummary == "File transfer. 12 MB. 25%. 90 seconds. This Mac")
    }

    @Test("Indeterminate accessibility uses the supplied status without deriving a percentage")
    func indeterminateAccessibilityUsesStatus() {
        var model = makeTransfer()
        model.progress = LiveActivityProgress(fraction: 0.25, label: "Waiting", isIndeterminate: true)

        #expect(model.accessibilitySummary.contains("Waiting"))
        #expect(!model.accessibilitySummary.contains("25%"))
        #expect(!model.accessibilitySummary.contains("percent"))
        #expect(model.progress.fraction == 0.25)
    }

    @Test("Determinate accessibility includes the visible fraction with textual or empty labels", arguments: ["Uploading", ""])
    func determinateAccessibilityIncludesFraction(label: String) {
        var model = makeTransfer()
        model.progress = LiveActivityProgress(fraction: 0.25, label: label)
        let percentage = 0.25.formatted(.percent.precision(.fractionLength(0)))

        #expect(model.accessibilitySummary.contains("12 MB"))
        #expect(model.accessibilitySummary.contains(percentage))
        #expect(model.accessibilitySummary.contains("90 seconds"))
        #expect(model.accessibilitySummary.contains("This Mac"))
        #expect(model.accessibilitySummary.contains("Archive"))
    }

    @Test("The composed fraction does not duplicate an app-provided percentage")
    func determinateAccessibilityDeduplicatesPercentage() {
        var model = makeTransfer()
        let percentage = 0.25.formatted(.percent.precision(.fractionLength(0)))
        model.progress.label = percentage

        #expect(model.accessibilitySummary.components(separatedBy: percentage).count == 2)
    }

    @Test("Unknown progress has no numeric accessible value")
    func indeterminateProgressHasNoPercentage() {
        var progress = LiveActivityProgress(fraction: 0.25, label: "Uploading")
        #expect(progress.formattedPercentage == 0.25.formatted(.percent.precision(.fractionLength(0))))
        progress.isIndeterminate = true
        #expect(progress.formattedPercentage == nil)
    }

    @Test("Moving a timeline start past its end preserves a valid interval")
    func timelineMutationNormalizesStart() {
        var timeline = makeTransfer().timeline
        timeline.startedAt = timeline.estimatedEnd.addingTimeInterval(30)

        #expect(timeline.estimatedEnd == timeline.startedAt)
    }

    @Test("Moving a timeline end before its start preserves a valid interval")
    func timelineMutationNormalizesEnd() {
        var timeline = makeTransfer().timeline
        timeline.estimatedEnd = timeline.startedAt.addingTimeInterval(-30)

        #expect(timeline.estimatedEnd == timeline.startedAt)
    }

    @Test("Normalizing mutations retains a valid original deadline and round trips the existing wire format")
    func timelineMutationRoundTrips() throws {
        var timeline = makeTransfer().timeline
        let deadline = timeline.estimatedEnd
        timeline.startedAt = timeline.startedAt.addingTimeInterval(-30)
        #expect(timeline.estimatedEnd == deadline)
        timeline.estimatedEnd = timeline.startedAt.addingTimeInterval(-30)

        let data = try JSONEncoder().encode(timeline)
        let decoded = try JSONDecoder().decode(LiveActivityTimeline.self, from: data)
        #expect(decoded == timeline)
        let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(Set(object.keys) == ["startedAt", "estimatedEnd", "remainingText"])
    }

    @Test("Content and indeterminate progress retain the original Codable keys")
    func contentWireFormatIsUnchanged() throws {
        var model = makeTransfer()
        model.progress.isIndeterminate = true
        let data = try JSONEncoder().encode(model)
        let decoded = try JSONDecoder().decode(LiveActivityContentModel.self, from: data)
        #expect(decoded == model)
        #expect(decoded.progress.fraction == 0.25)
        #expect(decoded.progress.isIndeterminate)

        let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(Set(object.keys) == [
            "id", "symbolName", "accessibilityTitle", "phase", "title", "subtitle", "primaryValue",
            "secondaryValue", "footnote", "progress", "timeline", "leadingLabel", "trailingLabel", "accent"
        ])
        let progress = try #require(object["progress"] as? [String: Any])
        #expect(Set(progress.keys) == ["fraction", "label", "isIndeterminate"])
    }

    @Test("Unknown progress ignores the stored fraction on each rendered surface", arguments: ProgressSurface.allCases, [false, true])
    @MainActor
    func indeterminateSurfacesIgnoreFraction(surface: ProgressSurface, dark: Bool) throws {
        var low = makeTransfer()
        low.progress = LiveActivityProgress(fraction: 0.1, label: "Waiting", isIndeterminate: true)
        var high = low
        high.progress = LiveActivityProgress(fraction: 0.9, label: "Waiting", isIndeterminate: true)

        let unknownLow = try raster(surface: surface, model: low, dark: dark)
        let unknownHigh = try raster(surface: surface, model: high, dark: dark)
        #expect(unknownLow == unknownHigh)

        low.progress.isIndeterminate = false
        high.progress.isIndeterminate = false
        let knownLow = try raster(surface: surface, model: low, dark: dark)
        let knownHigh = try raster(surface: surface, model: high, dark: dark)
        #expect(knownLow != knownHigh)
    }

    enum ProgressSurface: String, CaseIterable, Sendable {
        case ring, minimal, route, islandLine
    }

    @MainActor
    private func raster(surface: ProgressSurface, model: LiveActivityContentModel, dark: Bool) throws -> Data {
        let renderer = ImageRenderer(
            content: renderedSurface(surface: surface, model: model, dark: dark)
                .frame(width: 260, height: 48)
                .environment(\.colorScheme, dark ? .dark : .light)
        )
        renderer.scale = 1
        let image = try #require(renderer.cgImage)
        return try #require(image.dataProvider?.data) as Data
    }

    @MainActor
    @ViewBuilder
    private func renderedSurface(surface: ProgressSurface, model: LiveActivityContentModel, dark: Bool) -> some View {
        let palette = LiveActivityTheme.porcelain.palette(for: model.accent, colorScheme: dark ? .dark : .light)
        switch surface {
        case .ring:
            LiveActivityProgressRing(progress: model.progress, palette: palette)
                .frame(width: 44, height: 44)
        case .minimal:
            LiveActivityMinimalView(model: model)
                .frame(width: 34, height: 34)
        case .route:
            LiveActivityRouteLine(model: model, palette: palette)
        case .islandLine:
            LiveActivityIslandProgressLine(model: model, palette: palette)
        }
    }

    private func makeTransfer() -> LiveActivityContentModel {
        LiveActivityContentModel(
            id: "transfer-1",
            symbolName: "arrow.up.doc.fill",
            accessibilityTitle: "File transfer",
            phase: .active,
            title: "Uploading",
            subtitle: "Backup.zip",
            primaryValue: "12 MB",
            secondaryValue: "In progress",
            footnote: "Keep this app open",
            progress: LiveActivityProgress(fraction: 0.25, label: "25%"),
            timeline: LiveActivityTimeline(
                startedAt: Date(timeIntervalSinceReferenceDate: 800_000_000),
                estimatedEnd: Date(timeIntervalSinceReferenceDate: 800_000_090),
                remainingText: "90 seconds"
            ),
            leadingLabel: "This Mac",
            trailingLabel: "Archive",
            accent: .blue
        )
    }
}
