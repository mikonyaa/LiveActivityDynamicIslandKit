import SwiftUI

public struct LiveActivityStatusPill: View {
    public var text: String
    public var palette: LiveActivityPalette

    public init(
        text: String,
        palette: LiveActivityPalette
    ) {
        self.text = text
        self.palette = palette
    }

    public var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(palette.accent)
                .frame(width: 6, height: 6)
            Text(text)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
        }
        .foregroundStyle(palette.primaryText)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(palette.accent.opacity(0.12))
                .overlay(
                    Capsule().stroke(palette.accent.opacity(0.28), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
    }
}

public struct LiveActivityProgressRing: View {
    public var progress: LiveActivityProgress
    public var palette: LiveActivityPalette
    public var lineWidth: CGFloat

    public init(
        progress: LiveActivityProgress,
        palette: LiveActivityPalette,
        lineWidth: CGFloat = 6
    ) {
        self.progress = progress
        self.palette = palette
        self.lineWidth = lineWidth
    }

    public var body: some View {
        let ring = ZStack {
            Circle()
                .stroke(palette.separator.opacity(0.75), lineWidth: lineWidth)
            LiveActivityProgressArc(progress: progress, color: palette.accent, lineWidth: lineWidth)
            Text(progress.label)
                .font(.caption.weight(.bold))
                .minimumScaleFactor(0.7)
                .foregroundStyle(palette.primaryText)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(progress.label)

        if let percentage = progress.formattedPercentage {
            ring.accessibilityValue(percentage)
        } else {
            ring
        }
    }
}

public struct LiveActivityRouteLine: View {
    public var model: LiveActivityContentModel
    public var palette: LiveActivityPalette

    public init(
        model: LiveActivityContentModel,
        palette: LiveActivityPalette
    ) {
        self.model = model
        self.palette = palette
    }

    public var body: some View {
        HStack(spacing: 10) {
            label(model.leadingLabel, filled: true)
            LiveActivityProgressTrack(
                progress: model.progress,
                color: palette.accent,
                backgroundColor: palette.separator.opacity(0.85),
                minimumWidth: 12
            )
            .frame(height: 16)
            label(model.trailingLabel, filled: false)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(model.leadingLabel) to \(model.trailingLabel), \(model.progress.label)")
    }

    private func label(
        _ text: String,
        filled: Bool
    ) -> some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .lineLimit(1)
            .foregroundStyle(filled ? .white : palette.primaryText)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(filled ? palette.accent : palette.separator.opacity(0.65))
            )
    }
}

public struct LiveActivityIslandProgressLine: View {
    public var model: LiveActivityContentModel
    public var palette: LiveActivityPalette

    public init(
        model: LiveActivityContentModel,
        palette: LiveActivityPalette
    ) {
        self.model = model
        self.palette = palette
    }

    public var body: some View {
        LiveActivityProgressTrack(
            progress: model.progress,
            color: palette.accent,
            backgroundColor: Color.white.opacity(0.32),
            minimumWidth: 14
        )
        .frame(height: 8)
        .accessibilityLabel(model.progress.label)
    }
}

struct LiveActivityProgressArc: View {
    var progress: LiveActivityProgress
    var color: Color
    var lineWidth: CGFloat

    var body: some View {
        Group {
            if let fraction = progress.determinateFraction {
                Circle()
                    .trim(from: 0, to: fraction)
                    .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            } else {
                Circle()
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, dash: [lineWidth, lineWidth * 2])
                    )
            }
        }
        .rotationEffect(.degrees(-90))
    }
}

struct LiveActivityProgressTrack: View {
    var progress: LiveActivityProgress
    var color: Color
    var backgroundColor: Color
    var minimumWidth: CGFloat

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(backgroundColor)
                    .frame(height: 4)
                if let fraction = progress.determinateFraction {
                    Capsule()
                        .fill(color)
                        .frame(width: min(proxy.size.width, max(minimumWidth, proxy.size.width * fraction)), height: 4)
                } else {
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: proxy.size.height / 2))
                        path.addLine(to: CGPoint(x: proxy.size.width, y: proxy.size.height / 2))
                    }
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [2, 6]))
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
}
