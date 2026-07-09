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
        ZStack {
            Circle()
                .stroke(palette.separator.opacity(0.75), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress.isIndeterminate ? 0.72 : progress.fraction)
                .stroke(
                    palette.accent,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Text(progress.label)
                .font(.caption.weight(.bold))
                .minimumScaleFactor(0.7)
                .foregroundStyle(palette.primaryText)
        }
        .accessibilityLabel(progress.isIndeterminate ? progress.label : "\(Int(progress.fraction * 100)) percent")
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
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(palette.separator.opacity(0.85))
                        .frame(height: 4)
                    Capsule()
                        .fill(palette.accent)
                        .frame(width: max(12, proxy.size.width * model.progress.fraction), height: 4)
                }
                .frame(maxHeight: .infinity)
            }
            .frame(height: 16)
            label(model.trailingLabel, filled: false)
        }
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
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.32))
                    .frame(height: 4)
                Capsule()
                    .fill(palette.accent)
                    .frame(width: max(14, proxy.size.width * model.progress.fraction), height: 4)
            }
            .frame(maxHeight: .infinity)
        }
        .frame(height: 8)
        .accessibilityLabel(model.progress.label)
    }
}
