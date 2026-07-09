import Foundation

public struct LiveActivityContentModel: Codable, Hashable, Identifiable, Sendable {
    public var id: String
    public var scenario: LiveActivityScenario
    public var phase: LiveActivityPhase
    public var title: String
    public var subtitle: String
    public var primaryValue: String
    public var secondaryValue: String
    public var footnote: String
    public var progress: LiveActivityProgress
    public var timeline: LiveActivityTimeline
    public var leadingLabel: String
    public var trailingLabel: String
    public var accent: LiveActivityAccent

    public init(
        id: String,
        scenario: LiveActivityScenario,
        phase: LiveActivityPhase,
        title: String,
        subtitle: String,
        primaryValue: String,
        secondaryValue: String,
        footnote: String,
        progress: LiveActivityProgress,
        timeline: LiveActivityTimeline,
        leadingLabel: String,
        trailingLabel: String,
        accent: LiveActivityAccent
    ) {
        self.id = id
        self.scenario = scenario
        self.phase = phase
        self.title = title
        self.subtitle = subtitle
        self.primaryValue = primaryValue
        self.secondaryValue = secondaryValue
        self.footnote = footnote
        self.progress = progress
        self.timeline = timeline
        self.leadingLabel = leadingLabel
        self.trailingLabel = trailingLabel
        self.accent = accent
    }

    public var accessibilitySummary: String {
        [
            scenario.title,
            title,
            subtitle,
            primaryValue,
            secondaryValue,
            footnote
        ]
        .filter { !$0.isEmpty }
        .joined(separator: ". ")
    }

    public func liveTimelineSnapshot(
        now: Date = Date(),
        minimumDuration: TimeInterval = 90
    ) -> LiveActivityContentModel {
        let plannedDuration = max(
            timeline.estimatedEnd.timeIntervalSince(timeline.startedAt),
            minimumDuration
        )
        var copy = self
        copy.timeline = LiveActivityTimeline(
            startedAt: now,
            estimatedEnd: now.addingTimeInterval(plannedDuration),
            remainingText: timeline.remainingText
        )
        return copy
    }
}

public struct LiveActivityProgress: Codable, Hashable, Sendable {
    public var fraction: Double
    public var label: String
    public var isIndeterminate: Bool

    public init(
        fraction: Double,
        label: String,
        isIndeterminate: Bool = false
    ) {
        self.fraction = min(max(fraction, 0), 1)
        self.label = label
        self.isIndeterminate = isIndeterminate
    }
}

public struct LiveActivityTimeline: Codable, Hashable, Sendable {
    public var startedAt: Date
    public var estimatedEnd: Date
    public var remainingText: String

    public init(
        startedAt: Date,
        estimatedEnd: Date,
        remainingText: String
    ) {
        self.startedAt = startedAt
        self.estimatedEnd = estimatedEnd
        self.remainingText = remainingText
    }
}

public struct LiveActivityDeepLink: Codable, Hashable, Sendable {
    public var scenario: LiveActivityScenario
    public var stateID: String

    public init(scenario: LiveActivityScenario, stateID: String) {
        self.scenario = scenario
        self.stateID = stateID
    }

    public var url: URL {
        URL(string: "liveactivitydemo://scenario/\(scenario.rawValue)?state=\(stateID)")!
    }
}
