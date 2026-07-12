# ``LiveActivityKit``

Build consistent Lock Screen and Dynamic Island presentations from one domain-neutral content model.

## Overview

LiveActivityKit is a rendering package. It deliberately leaves `ActivityAttributes`, lifecycle ownership, routing, and side effects in the integrating app.

Create a ``LiveActivityContentModel`` for the current product state, then compose the appropriate surface inside your WidgetKit `ActivityConfiguration`.

```swift
LiveActivityLockScreenCard(model: model, theme: .porcelain)
```

For branded light and dark palettes, provide a ``LiveActivityAppearance`` instead of modifying package source.

## Topics

### Content

- ``LiveActivityContentModel``
- ``LiveActivityProgress``
- ``LiveActivityTimeline``
- ``LiveActivityPhase``
- ``LiveActivityAccent``

### Appearance

- ``LiveActivityAppearance``
- ``LiveActivityPalette``
- ``LiveActivityTheme``

### System surfaces

- ``LiveActivityLockScreenCard``
- ``LiveActivityCompactLeadingView``
- ``LiveActivityCompactTrailingView``
- ``LiveActivityMinimalView``
- ``LiveActivityExpandedIslandView``
- ``LiveActivityPreviewPanel``
