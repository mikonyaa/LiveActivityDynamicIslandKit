import ActivityKit
import LiveActivityKit
import SwiftUI
import WidgetKit

@main
struct LiveActivityDemoWidgets: WidgetBundle {
    var body: some Widget {
        LiveActivityDemoActivityWidget()
    }
}

struct LiveActivityDemoActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivityAttributes.self) { context in
            LiveActivityLockScreenCard(
                model: context.state.model,
                theme: .porcelain
            )
            .activityBackgroundTint(Color(red: 0.965, green: 0.961, blue: 0.945))
            .activitySystemActionForegroundColor(context.state.model.accent.color)
            .widgetURL(deepLink(for: context.state.model))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    leadingExpanded(context.state.model)
                        .padding(.leading, 6)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    trailingExpanded(context.state.model)
                        .padding(.trailing, 6)
                }
                DynamicIslandExpandedRegion(.center) {
                    centerExpanded(context.state.model)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    LiveActivityExpandedIslandView(
                        model: context.state.model,
                        theme: .porcelain
                    )
                    .padding(.horizontal, 6)
                    .padding(.bottom, 4)
                }
            } compactLeading: {
                LiveActivityCompactLeadingView(model: context.state.model)
            } compactTrailing: {
                LiveActivityCompactTrailingView(model: context.state.model)
            } minimal: {
                LiveActivityMinimalView(model: context.state.model)
            }
            .widgetURL(deepLink(for: context.state.model))
            .keylineTint(context.state.model.accent.color)
        }
    }

    private func leadingExpanded(_ model: LiveActivityContentModel) -> some View {
        Text(model.leadingLabel)
            .font(.headline.weight(.bold))
            .lineLimit(1)
            .minimumScaleFactor(0.72)
    }

    private func trailingExpanded(_ model: LiveActivityContentModel) -> some View {
        Text(model.trailingLabel)
            .font(.headline.weight(.bold))
            .lineLimit(1)
            .minimumScaleFactor(0.72)
    }

    private func centerExpanded(_ model: LiveActivityContentModel) -> some View {
        Text(model.timeline.remainingText)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
    }

    private func deepLink(for model: LiveActivityContentModel) -> URL {
        LiveActivityDeepLink(
            scenario: model.scenario,
            stateID: model.id
        ).url
    }
}

#Preview("Delivery", as: .content, using: LiveActivityAttributes(scenario: .delivery, activityID: "preview")) {
    LiveActivityDemoActivityWidget()
} contentStates: {
    LiveActivityAttributes.ContentState(model: LiveActivityRecipes.delivery.states[1])
    LiveActivityAttributes.ContentState(model: LiveActivityRecipes.delivery.states[2])
}
