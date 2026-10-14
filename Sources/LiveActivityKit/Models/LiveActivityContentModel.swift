import Foundation

public struct LiveActivityContentModel: Codable, Hashable, Identifiable, Sendable {
    public var id: String
    /// The SF Symbol rendered by the reusable Lock Screen and Dynamic Island views.
    public var symbolName: String
    /// A short, app-provided description of the activity for assistive technologies.
    public var accessibilityTitle: String
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
        symbolName: String,
        accessibilityTitle: String,
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
        self.symbolName = symbolName
        self.accessibilityTitle = accessibilityTitle
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
        var included = Set<String>()
        return [
            accessibilityTitle,
            title,
            subtitle,
            primaryValue,
            secondaryValue,
            progress.label,
            progress.formattedPercentage ?? "",
            timeline.remainingText,
            leadingLabel,
            trailingLabel,
            footnote
        ]
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter {
            let key = $0.split(whereSeparator: \.isWhitespace).joined(separator: " ")
                .lowercased()
                .replacingOccurrences(of: " %", with: "%")
                .replacingOccurrences(of: " ٪", with: "٪")
            return !$0.isEmpty && included.insert(key).inserted
        }
        .joined(separator: ". ")
    }

    /// Rebases a presentation snapshot to `now` while retaining its planned duration.
    /// This demo helper does not track elapsed business time or update a real deadline.
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
    public private(set) var fraction: Double
    /// App-provided, localized progress text. Use a status such as "Waiting" when the fraction is unknown.
    public var label: String
    /// When true, every progress surface ignores `fraction` and presents an unknown amount.
    public var isIndeterminate: Bool

    var determinateFraction: Double? { isIndeterminate ? nil : fraction }
    var formattedPercentage: String? {
        determinateFraction?.formatted(.percent.precision(.fractionLength(0)))
    }

    public init(
        fraction: Double,
        label: String,
        isIndeterminate: Bool = false
    ) {
        self.fraction = Self.normalized(fraction)
        self.label = label
        self.isIndeterminate = isIndeterminate
    }

    private static func normalized(_ fraction: Double) -> Double {
        if fraction.isNaN || fraction == -.infinity { return 0 }
        if fraction == .infinity { return 1 }
        return min(max(fraction, 0), 1)
    }

    private enum CodingKeys: String, CodingKey {
        case fraction
        case label
        case isIndeterminate
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            fraction: try container.decode(Double.self, forKey: .fraction),
            label: try container.decode(String.self, forKey: .label),
            isIndeterminate: try container.decode(Bool.self, forKey: .isIndeterminate)
        )
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fraction, forKey: .fraction)
        try container.encode(label, forKey: .label)
        try container.encode(isIndeterminate, forKey: .isIndeterminate)
    }
}

public struct LiveActivityTimeline: Codable, Hashable, Sendable {
    public var startedAt: Date {
        didSet {
            if estimatedEnd < startedAt { estimatedEnd = startedAt }
        }
    }
    public var estimatedEnd: Date {
        didSet {
            if estimatedEnd < startedAt { estimatedEnd = startedAt }
        }
    }
    public var remainingText: String

    public init(
        startedAt: Date,
        estimatedEnd: Date,
        remainingText: String
    ) {
        self.startedAt = startedAt
        self.estimatedEnd = max(startedAt, estimatedEnd)
        self.remainingText = remainingText
    }

    private enum CodingKeys: String, CodingKey {
        case startedAt
        case estimatedEnd
        case remainingText
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            startedAt: try container.decode(Date.self, forKey: .startedAt),
            estimatedEnd: try container.decode(Date.self, forKey: .estimatedEnd),
            remainingText: try container.decode(String.self, forKey: .remainingText)
        )
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(startedAt, forKey: .startedAt)
        try container.encode(estimatedEnd, forKey: .estimatedEnd)
        try container.encode(remainingText, forKey: .remainingText)
    }
}
