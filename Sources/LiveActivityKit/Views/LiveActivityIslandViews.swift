import SwiftUI

public struct LiveActivityCompactLeadingView: View {
    public var model: LiveActivityContentModel

    public init(model: LiveActivityContentModel) {
        self.model = model
    }

    public var body: some View {
        Image(systemName: model.scenario.systemImage)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(model.accent.color)
            .accessibilityLabel(model.scenario.title)
    }
}

public struct LiveActivityCompactTrailingView: View {
    public var model: LiveActivityContentModel

    public init(model: LiveActivityContentModel) {
        self.model = model
    }

    public var body: some View {
        Text(model.primaryValue)
            .font(.caption.weight(.bold))
            .foregroundStyle(.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.65)
            .monospacedDigit()
            .accessibilityLabel(model.primaryValue)
    }
}

public struct LiveActivityMinimalView: View {
    public var model: LiveActivityContentModel

    public init(model: LiveActivityContentModel) {
        self.model = model
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(model.accent.color.opacity(0.28), lineWidth: 2.5)
            Circle()
                .trim(from: 0, to: model.progress.fraction)
                .stroke(
                    model.accent.color,
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Image(systemName: model.scenario.systemImage)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(model.accent.color)
        }
        .accessibilityLabel(model.accessibilitySummary)
    }
}

public struct LiveActivityExpandedIslandView: View {
    public var model: LiveActivityContentModel
    public var theme: LiveActivityTheme

    @Environment(\.colorScheme) private var colorScheme

    public init(
        model: LiveActivityContentModel,
        theme: LiveActivityTheme = .porcelain
    ) {
        self.model = model
        self.theme = theme
    }

    public var body: some View {
        let palette = theme.palette(for: model.accent, colorScheme: colorScheme)

        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 10) {
                Image(systemName: model.scenario.systemImage)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(palette.accent)
                    .frame(width: 28, height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(palette.accent.opacity(0.18))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(model.title)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    Text(model.subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .layoutPriority(1)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(model.primaryValue)
                        .font(.headline.weight(.bold))
                        .monospacedDigit()
                        .lineLimit(1)
                    Text(model.secondaryValue)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            LiveActivityIslandProgressLine(model: model, palette: palette)
        }
        .padding(.horizontal, 2)
        .padding(.top, 1)
        .padding(.bottom, 3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(model.accessibilitySummary)
    }
}
