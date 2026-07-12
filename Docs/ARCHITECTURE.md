# Architecture

The repository is split into a reusable rendering package and an app-specific demo.

## State

`LiveActivityContentModel` is the source of truth for the UI. It contains:

- SF Symbol name and accessibility title supplied by the app
- phase
- title and subtitle
- progress
- timeline
- detail rows
- accessibility summary

The package deliberately does not define `ActivityAttributes`. Attribute identity belongs to the integrating app and must be shared with its widget extension.

## Demo domain

`LiveActivityRecipe`, `LiveActivityScenario`, `LiveActivityAttributes`, and the URL scheme live under `Examples/LiveActivityDemo`. They are intentionally deterministic so the demo remains useful without turning the package into a closed list of sample businesses.

Replace the demo domain with your own attributes and state mapping when adapting the template.

## Surfaces

The UI layer contains separate views for each system surface:

- `LiveActivityLockScreenCard`
- `LiveActivityCompactLeadingView`
- `LiveActivityCompactTrailingView`
- `LiveActivityMinimalView`
- `LiveActivityExpandedIslandView`
- `LiveActivityPreviewPanel`

Each view accepts a model and either the adaptive Porcelain theme or an app-defined `LiveActivityAppearance`. No view owns business state.

## Demo app

The demo app is a local control surface. It lets you pick a scenario, start the Live Activity, move between states, restore an active session after relaunch, and end the activity. Its explicit lifecycle states prevent overlapping mutations and duplicate starts.

The WidgetKit extension contains the real `ActivityConfiguration` used by the system.
