import SwiftUI

public struct LiveActivityPreviewPanel: View {
    public var model: LiveActivityContentModel
    public var theme: LiveActivityTheme

    public init(
        model: LiveActivityContentModel,
        theme: LiveActivityTheme
    ) {
        self.model = model
        self.theme = theme
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle("Lock Screen")
            LiveActivityLockScreenCard(model: model, theme: theme)

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

    private var expandedPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Expanded")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            LiveActivityExpandedIslandView(model: model, theme: theme)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.black)
                )
                .foregroundStyle(.white)
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
