# Migrating pre-release integrations

The `0.1.0` package keeps reusable rendering state and views in `LiveActivityKit`. Demo scenarios and ActivityKit identity now belong to the integrating app.

## Replace package-owned scenarios

Remove uses of `LiveActivityScenario`, `LiveActivityRecipe`, and `LiveActivityRecipes` from package integrations. Keep equivalent domain types in your app or map existing product state directly into `LiveActivityContentModel`.

Replace the old `scenario:` model argument with:

```swift
symbolName: "shippingbox.fill",
accessibilityTitle: "Package delivery"
```

## Own ActivityAttributes

Copy the pattern from `Examples/LiveActivityDemo/Shared/LiveActivityAttributes.swift` into a file included in both your app target and widget extension. Keep product identifiers in that type.

## Own deep links

Build URLs in your app with `URLComponents` and pass them to `widgetURL`. The package no longer assumes the sample `liveactivitydemo` scheme.

This is a pre-release breaking change. No published `0.x` tag is being rewritten.
