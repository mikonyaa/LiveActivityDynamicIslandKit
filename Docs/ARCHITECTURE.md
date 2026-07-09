# Architecture

The kit is split into three layers: state, recipes, and surfaces.

## State

`LiveActivityContentModel` is the source of truth for the UI. It contains:

- scenario
- phase
- title and subtitle
- progress
- timeline
- detail rows
- deep link
- accessibility summary

`LiveActivityAttributes` wraps that model for ActivityKit. The app uses the same attributes as the widget extension, so both targets speak the same language.

## Recipes

`LiveActivityRecipe` describes one domain scenario and its timeline states. Recipes are intentionally deterministic. That makes the template easy to preview, test, and customize without a backend.

Replace recipe data first when adapting the template to a real product.

## Surfaces

The UI layer contains separate views for each system surface:

- `LiveActivityLockScreenCard`
- `LiveActivityCompactLeadingView`
- `LiveActivityCompactTrailingView`
- `LiveActivityMinimalView`
- `LiveActivityExpandedIslandView`
- `LiveActivityPreviewPanel`

Each view accepts a model and the shared Porcelain visual style. No view owns business state.

## Demo app

The demo app is a local control surface. It lets you pick a scenario, start the Live Activity, move between states, and end the activity.

The WidgetKit extension contains the real `ActivityConfiguration` used by the system.
