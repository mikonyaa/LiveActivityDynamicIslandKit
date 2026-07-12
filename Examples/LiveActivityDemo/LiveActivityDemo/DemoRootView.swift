import SwiftUI

struct DemoRootView: View {
    @Bindable var controller: LiveActivityDemoController
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    hero
                    ActivityStatusCard(message: controller.statusMessage)
                        .transaction { $0.animation = nil }
                    ScenarioGalleryView(controller: controller)
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 32)
            }
            .background(DemoBackground())
            .navigationTitle("Activity Lab")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: LiveActivityScenario.self) { scenario in
                ScenarioDetailView(controller: controller, scenario: scenario)
            }
        }
        .tint(controller.currentModel.accent.color)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label("ACTIVITYKIT · iOS 17+", systemImage: "waveform.path.ecg")
                .font(.caption2.weight(.bold))
                .tracking(0.7)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                Text("Live system surfaces,\nready to make yours.")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .tracking(-1.4)
                    .accessibilityAddTraits(.isHeader)
                Text("Explore complete local lifecycles, validate every Dynamic Island size, and adapt a small rendering core to your product.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(spacing: 12) {
                        metricRow("6", label: "recipes")
                        Divider()
                        metricRow("4", label: "surfaces")
                        Divider()
                        metricRow("0", label: "dependencies")
                    }
                    .padding(.horizontal, 16)
                } else {
                    HStack(spacing: 0) {
                        metric("6", label: "recipes")
                        Divider().frame(height: 34)
                        metric("4", label: "surfaces")
                        Divider().frame(height: 34)
                        metric("0", label: "dependencies")
                    }
                }
            }
            .padding(.vertical, 14)
            .background(.background.opacity(0.72), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(.separator.opacity(0.28), lineWidth: 1)
            }
        }
    }

    private func metricRow(_ value: String, label: String) -> some View {
        HStack {
            Text(value).font(.headline.weight(.bold)).monospacedDigit()
            Text(label).font(.body).foregroundStyle(.secondary)
            Spacer()
        }
        .accessibilityElement(children: .combine)
    }

    private func metric(_ value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.headline.weight(.bold)).monospacedDigit()
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

struct DemoBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Group {
            if colorScheme == .dark {
                Color(red: 0.055, green: 0.057, blue: 0.065)
            } else {
                Color(red: 0.965, green: 0.961, blue: 0.945)
            }
        }
        .ignoresSafeArea()
    }
}

struct ActivityStatusCard: View {
    var message: DemoMessage

    var body: some View {
        HStack(alignment: .center, spacing: 13) {
            Image(systemName: message.style.symbolName)
                .foregroundStyle(message.style.tint)
                .font(.body.weight(.bold))
                .frame(width: 34, height: 34)
                .background(message.style.tint.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(message.title)
                    .font(.subheadline.weight(.semibold))
                Text(message.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.separator.opacity(0.25), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }
}
