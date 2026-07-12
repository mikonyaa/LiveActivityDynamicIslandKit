import LiveActivityKit
import SwiftUI

struct ScenarioGalleryView: View {
    @Bindable var controller: LiveActivityDemoController
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var columns: [GridItem] {
        if dynamicTypeSize.isAccessibilitySize {
            [GridItem(.flexible())]
        } else {
            [GridItem(.adaptive(minimum: 150), spacing: 12)]
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Recipe library")
                    .font(.title2.bold())
                Text("Six practical state machines, each with four production-shaped snapshots.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(controller.recipes) { recipe in
                    NavigationLink(value: recipe.scenario) {
                        ScenarioCard(recipe: recipe)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct ScenarioCard: View {
    var recipe: LiveActivityRecipe

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Image(systemName: recipe.scenario.systemImage)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(recipe.scenario.accent.color)
                    .frame(width: 38, height: 38)
                    .background(recipe.scenario.accent.color.opacity(0.13), in: RoundedRectangle(cornerRadius: 13))
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.scenario.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(recipe.scenario.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2, reservesSpace: true)
            }

            Text("\(recipe.states.count) lifecycle states")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(recipe.scenario.accent.color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.background.opacity(0.82), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.separator.opacity(0.28), lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens the interactive recipe")
    }
}
