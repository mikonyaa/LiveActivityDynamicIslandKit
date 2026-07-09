import LiveActivityKit
import SwiftUI

struct ScenarioGalleryView: View {
    @Bindable var controller: LiveActivityDemoController

    private let columns = [
        GridItem(.adaptive(minimum: 152), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recipes")
                .font(.title2.bold())

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(controller.recipes) { recipe in
                    ScenarioCard(
                        recipe: recipe,
                        isSelected: recipe.scenario == controller.selectedScenario
                    ) {
                        controller.select(recipe.scenario)
                    }
                }
            }
        }
    }
}

struct ScenarioCard: View {
    var recipe: LiveActivityRecipe
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: recipe.scenario.systemImage)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(recipe.scenario.accent.color)
                        .frame(width: 38, height: 38)
                        .background(
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .fill(recipe.scenario.accent.color.opacity(0.14))
                        )
                    Spacer()
                    Text("\(recipe.states.count)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.scenario.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(recipe.scenario.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.background.opacity(0.86))
                    .shadow(color: .black.opacity(isSelected ? 0.10 : 0.05), radius: isSelected ? 18 : 8, y: isSelected ? 10 : 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(isSelected ? recipe.scenario.accent.color.opacity(0.7) : Color(.separator).opacity(0.35), lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(recipe.scenario.title)
    }
}
