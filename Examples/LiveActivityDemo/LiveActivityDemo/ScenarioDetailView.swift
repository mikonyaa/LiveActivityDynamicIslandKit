import LiveActivityKit
import SwiftUI

struct ScenarioDetailView: View {
    @Bindable var controller: LiveActivityDemoController
    var scenario: LiveActivityScenario

    @State private var selectedSurface: DemoSurface = .lockScreen

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ScenarioOverview(scenario: scenario, model: controller.currentModel)
                ActivityStatusCard(message: controller.statusMessage)
                    .transaction { $0.animation = nil }
                surfaceLab
                stateTimeline
                DemoLifecycleNote()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 118)
        }
        .background(DemoBackground())
        .navigationTitle(scenario.title)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            controlDock
        }
        .onAppear {
            guard controller.selectedScenario != scenario else { return }
            controller.select(scenario)
        }
    }

    private var surfaceLab: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Surface lab")
                        .font(.title3.bold())
                    Text("Preview the exact state at every system size.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(controller.selectedStateIndex + 1)/\(controller.selectedRecipe.states.count)")
                    .font(.caption.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(DemoSurface.allCases) { surface in
                        Button {
                            selectedSurface = surface
                        } label: {
                            Label(surface.title, systemImage: surface.symbolName)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 9)
                                .foregroundStyle(selectedSurface == surface ? .white : .primary)
                                .background(
                                    selectedSurface == surface ? scenario.accent.color : Color.secondary.opacity(0.10),
                                    in: Capsule()
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollIndicators(.hidden)

            DemoSurfacePreview(surface: selectedSurface, model: controller.currentModel)
                .id(selectedSurface)
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
        }
        .padding(16)
        .background(.background.opacity(0.80), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.separator.opacity(0.28), lineWidth: 1)
        }
        .animation(.snappy(duration: 0.3), value: selectedSurface)
    }

    private var stateTimeline: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lifecycle timeline")
                .font(.title3.bold())

            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(Array(controller.selectedRecipe.states.enumerated()), id: \.element.id) { index, state in
                        Button {
                            controller.selectState(at: index)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("0\(index + 1)")
                                        .font(.caption2.weight(.bold))
                                        .monospacedDigit()
                                    Spacer()
                                    Circle()
                                        .fill(state.accent.color)
                                        .frame(width: 7, height: 7)
                                }
                                Text(state.title)
                                    .font(.subheadline.weight(.semibold))
                                    .lineLimit(1)
                                Text(state.secondaryValue)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            .foregroundStyle(.primary)
                            .frame(width: 132, alignment: .leading)
                            .padding(13)
                            .background(
                                controller.selectedStateIndex == index
                                    ? state.accent.color.opacity(0.12)
                                    : Color.secondary.opacity(0.07),
                                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(
                                        controller.selectedStateIndex == index
                                            ? state.accent.color.opacity(0.55)
                                            : Color.clear,
                                        lineWidth: 1
                                    )
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private var controlDock: some View {
        HStack(spacing: 10) {
            Button {
                controller.previousState()
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.bordered)
            .disabled(!controller.canMoveBackward || controller.lifecycle.isBusy)
            .accessibilityLabel("Previous state")

            if controller.canEndActivity {
                endButton
            } else {
                startButton
            }

            Button {
                controller.nextState()
            } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.bordered)
            .disabled(!controller.canMoveForward || controller.lifecycle.isBusy)
            .accessibilityLabel("Next state")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) { Divider() }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    @ViewBuilder
    private var startButton: some View {
#if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            Button {
                Task { await controller.startActivity() }
            } label: {
                Label("Start", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .disabled(!controller.canStartActivity)
            .accessibilityLabel("Start Live Activity")
        } else {
            Button {
                Task { await controller.startActivity() }
            } label: {
                Label("Start", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!controller.canStartActivity)
            .accessibilityLabel("Start Live Activity")
        }
#else
        fallbackStartButton
#endif
    }

    @ViewBuilder
    private var endButton: some View {
#if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            Button(role: .destructive) {
                Task { await controller.endActivity() }
            } label: {
                Label("End", systemImage: "stop.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .accessibilityLabel("End Live Activity")
        } else {
            Button(role: .destructive) {
                Task { await controller.endActivity() }
            } label: {
                Label("End", systemImage: "stop.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel("End Live Activity")
        }
#else
        fallbackEndButton
#endif
    }

    private var fallbackStartButton: some View {
        Button {
            Task { await controller.startActivity() }
        } label: {
            Label("Start", systemImage: "play.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled(!controller.canStartActivity)
        .accessibilityLabel("Start Live Activity")
    }

    private var fallbackEndButton: some View {
        Button(role: .destructive) {
            Task { await controller.endActivity() }
        } label: {
            Label("End", systemImage: "stop.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .accessibilityLabel("End Live Activity")
    }
}

private struct ScenarioOverview: View {
    var scenario: LiveActivityScenario
    var model: LiveActivityContentModel

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: scenario.systemImage)
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(scenario.accent.color)
                .frame(width: 50, height: 50)
                .background(scenario.accent.color.opacity(0.13), in: RoundedRectangle(cornerRadius: 17))

            VStack(alignment: .leading, spacing: 4) {
                Text(model.title)
                    .font(.title2.bold())
                    .contentTransition(.numericText())
                Text(model.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }
}

private struct DemoLifecycleNote: View {
    var body: some View {
        Label {
            Text("Start creates a real local ActivityKit session. State changes update the system UI; End uses a 30-second dismissal window.")
        } icon: {
            Image(systemName: "info.circle")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 2)
    }
}

private enum DemoSurface: String, CaseIterable, Identifiable {
    case lockScreen
    case compact
    case minimal
    case expanded

    var id: String { rawValue }

    var title: String {
        switch self {
        case .lockScreen: "Lock Screen"
        case .compact: "Compact"
        case .minimal: "Minimal"
        case .expanded: "Expanded"
        }
    }

    var symbolName: String {
        switch self {
        case .lockScreen: "lock.rectangle"
        case .compact: "capsule"
        case .minimal: "circle"
        case .expanded: "rectangle.inset.filled"
        }
    }
}

private struct DemoSurfacePreview: View {
    var surface: DemoSurface
    var model: LiveActivityContentModel

    var body: some View {
        Group {
            switch surface {
            case .lockScreen:
                LiveActivityLockScreenCard(model: model)
                    .padding(8)
            case .compact:
                HStack(spacing: 14) {
                    LiveActivityCompactLeadingView(model: model)
                    Spacer(minLength: 20)
                    LiveActivityCompactTrailingView(model: model)
                }
                .padding(.horizontal, 18)
                .frame(width: 190, height: 42)
                .background(Color.black, in: Capsule())
                .foregroundStyle(.white)
            case .minimal:
                LiveActivityMinimalView(model: model)
                    .frame(width: 34, height: 34)
                    .padding(7)
                    .background(Color.black, in: Circle())
            case .expanded:
                LiveActivityExpandedIslandView(model: model)
                    .padding(16)
                    .background(Color.black, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 156)
        .background(Color.black.opacity(surface == .lockScreen ? 0.035 : 0.0), in: RoundedRectangle(cornerRadius: 22))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(surface.title) preview")
    }
}
