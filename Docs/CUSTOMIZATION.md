# Customization

## Change scenarios

The sample scenarios live in `Examples/LiveActivityDemo/Shared/LiveActivityScenario.swift`. They are demo fixtures, not package API. Each scenario owns:

- title
- subtitle
- system image
- accent color

Then update the demo recipes. A production app should map its own domain model directly into `LiveActivityContentModel`.

## Change content states

Edit `Examples/LiveActivityDemo/LiveActivityDemo/LiveActivityRecipeData.swift`.

A state should describe one meaningful moment in the activity timeline. Avoid creating states for tiny visual changes only.

## Change visual style

The template ships with an adaptive Porcelain appearance. For product branding, create a `LiveActivityAppearance` with independent light and dark `LiveActivityPalette` values and pass it to the Lock Screen, expanded-island, or preview initializers.

The original `theme: .porcelain` initializers remain available. Prefer an appearance value over editing package source so upgrades stay straightforward.

Keep contrast high. Live Activities are glanced at quickly and often appear in bright or dark environments.

## Change views

Start with these files:

- `LiveActivityLockScreenCard.swift`
- `LiveActivityIslandViews.swift`
- `LiveActivityStatusPill.swift`

Use the same model across every surface. That prevents the Lock Screen, compact island, and expanded island from drifting apart.

## Change preview assets

Run:

```bash
python3 Tools/render_preview_assets.py
```

This regenerates the component preview:

- `Assets/Screenshots/preview-porcelain.png`
