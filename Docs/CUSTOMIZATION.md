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

Edit `LiveActivityTheme`.

The template ships with one Porcelain visual style: light, calm, product-friendly, and stable across the demo app, Lock Screen card, and Dynamic Island surfaces.

If your product needs a different look, change the palette values in `LiveActivityPalette.porcelain(accent:)` or add a new theme deliberately after the base flow is working.

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
