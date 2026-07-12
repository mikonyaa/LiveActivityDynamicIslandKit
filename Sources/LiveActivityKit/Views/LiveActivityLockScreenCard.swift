import SwiftUI

public struct LiveActivityLockScreenCard: View {
    public var model: LiveActivityContentModel
    public var theme: LiveActivityTheme
    public var appearance: LiveActivityAppearance?

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        model: LiveActivityContentModel,
        theme: LiveActivityTheme = .porcelain
    ) {
        self.model = model
        self.theme = theme
        self.appearance = nil
    }

    /// Creates a Lock Screen surface using app-defined light and dark palettes.
    public init(model: LiveActivityContentModel, appearance: LiveActivityAppearance) {
        self.model = model
        self.theme = .porcelain
        self.appearance = appearance
    }

    public var body: some View {
        let palette = appearance?.palette(for: colorScheme)
            ?? theme.palette(for: model.accent, colorScheme: colorScheme)

        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                symbol(palette: palette)

                VStack(alignment: .leading, spacing: 3) {
                    Text(model.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(palette.primaryText)
                        .lineLimit(1)
                    Text(model.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(palette.secondaryText)
                        .lineLimit(1)
                }
                .layoutPriority(1)

                Spacer(minLength: 28)
            }
            .padding(.trailing, 18)

            LiveActivityRouteLine(model: model, palette: palette)

            HStack(alignment: .center, spacing: 11) {
                LiveActivityProgressRing(progress: model.progress, palette: palette, lineWidth: 4.5)
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 5) {
                    LiveActivityStatusPill(text: model.secondaryValue, palette: palette)
                    Text(model.footnote)
                        .font(.caption)
                        .foregroundStyle(palette.secondaryText)
                        .lineLimit(1)
                }
                .layoutPriority(1)

                Spacer()

                Text(model.timeline.remainingText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.primaryText)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(palette.separator.opacity(0.45))
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 15)
        .padding(.bottom, 16)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(palette.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(palette.separator, lineWidth: 1)
                )
        )
        .animation(reduceMotion ? nil : .smooth(duration: 0.35), value: model)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(model.accessibilitySummary)
    }

    private func symbol(palette: LiveActivityPalette) -> some View {
        Image(systemName: model.symbolName)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(palette.accent)
            .frame(width: 36, height: 36)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(palette.accent.opacity(0.14))
            )
    }
}
