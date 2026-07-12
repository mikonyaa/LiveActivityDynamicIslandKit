import SwiftUI

public struct LiveActivityPreviewPanel: View {
    public var model: LiveActivityContentModel
    public var theme: LiveActivityTheme
    public var appearance: LiveActivityAppearance?

    public init(
        model: LiveActivityContentModel,
        theme: LiveActivityTheme = .porcelain
    ) {
        self.model = model
        self.theme = theme
        self.appearance = nil
    }

    /// Creates a complete surface preview using app-defined light and dark palettes.
    public init(model: LiveActivityContentModel, appearance: LiveActivityAppearance) {
        self.model = model
        self.theme = .porcelain
        self.appearance = appearance
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle("Lock Screen")
            lockScreenPreview

            sectionTitle("Dynamic Island")
            HStack(spacing: 14) {
                capsule("Compact") {
                    HStack(spacing: 10) {
                        LiveActivityCompactLeadingView(model: model)
                        LiveActivityCompactTrailingView(model: model)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                }

                capsule("Minimal") {
                    LiveActivityMinimalView(model: model)
                        .frame(width: 34, height: 34)
                        .padding(7)
                }
            }

            expandedPreview
        }
    }

    @ViewBuilder
    private var lockScreenPreview: some View {
        if let appearance {
            LiveActivityLockScreenCard(model: model, appearance: appearance)
        } else {
            LiveActivityLockScreenCard(model: model, theme: theme)
        }
    }

    private var expandedPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Expanded")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            expandedSurface
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.black)
                )
                .foregroundStyle(.white)
        }
    }

    @ViewBuilder
    private var expandedSurface: some View {
        if let appearance {
            LiveActivityExpandedIslandView(model: model, appearance: appearance)
        } else {
            LiveActivityExpandedIslandView(model: model, theme: theme)
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline.weight(.semibold))
    }

    private func capsule<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            content()
                .background(
                    Capsule()
                        .fill(Color.black)
                )
                .foregroundStyle(.white)
        }
    }
}
