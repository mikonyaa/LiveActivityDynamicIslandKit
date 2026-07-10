import LiveActivityKit
import SwiftUI

struct ScenarioDetailView: View {
    @Bindable var controller: LiveActivityDemoController

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header
            controls
            stateTimeline
            LiveActivityPreviewPanel(
                model: controller.currentModel,
                theme: .porcelain
            )
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.background.opacity(0.88))
                .shadow(color: .black.opacity(0.08), radius: 24, y: 14)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(.separator.opacity(0.35), lineWidth: 1)
        )
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: controller.currentModel.symbolName)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(controller.currentModel.accent.color)
                .frame(width: 46, height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(controller.currentModel.accent.color.opacity(0.14))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(controller.currentModel.title)
                    .font(.title2.bold())
                Text(controller.currentModel.subtitle)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private var controls: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button {
                    Task { await controller.startActivity() }
                } label: {
                    Label("Start", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    Task { await controller.endActivity() }
                } label: {
                    Label("End", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: 10) {
                Button {
                    controller.previousState()
                } label: {
                    Label("Previous", systemImage: "chevron.left")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(!controller.canMoveBackward)

                Button {
                    controller.nextState()
                } label: {
                    Label("Next state", systemImage: "chevron.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(!controller.canMoveForward)

                Button {
                    controller.reset()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var stateTimeline: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Local timeline")
                .font(.headline.weight(.semibold))

            ForEach(Array(controller.selectedRecipe.states.enumerated()), id: \.element.id) { index, state in
                Button {
                    controller.selectedStateIndex = index
                    Task { await controller.updateActivity() }
                } label: {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(index == controller.selectedStateIndex ? state.accent.color : Color.secondary.opacity(0.25))
                            .frame(width: 10, height: 10)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(state.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                            Text(state.secondaryValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(state.primaryValue)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(index == controller.selectedStateIndex ? state.accent.color.opacity(0.08) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
