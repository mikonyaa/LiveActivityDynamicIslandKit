import LiveActivityKit
import SwiftUI

struct DemoRootView: View {
    @Bindable var controller: LiveActivityDemoController

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    hero
                    ScenarioGalleryView(controller: controller)
                    ScenarioDetailView(controller: controller)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(DemoBackground())
            .overlay(alignment: .top) {
                if let message = controller.message {
                    MessageCard(message: message)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .allowsHitTesting(false)
                        .transition(.opacity)
                }
            }
            .navigationTitle("Live Activity Kit")
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Production-ready ActivityKit states")
                .font(.largeTitle.bold())
                .tracking(-1.2)
            Text("Study six local-first Live Activity recipes, preview every Dynamic Island size, and adapt the reusable SwiftUI surfaces to your product.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

        }
    }
}

struct DemoBackground: View {
    var body: some View {
        Color(red: 0.965, green: 0.961, blue: 0.945)
        .ignoresSafeArea()
    }
}

struct MessageCard: View {
    var message: DemoMessage

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: message.style == .success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(message.style == .success ? .green : .orange)
            VStack(alignment: .leading, spacing: 3) {
                Text(message.title)
                    .font(.subheadline.weight(.semibold))
                Text(message.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.background.opacity(0.94))
                .shadow(color: .black.opacity(0.12), radius: 24, y: 12)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.separator.opacity(0.35), lineWidth: 1)
        )
    }
}
