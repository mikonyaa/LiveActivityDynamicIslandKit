# Live Activity & Dynamic Island Kit

![Live Activity and Dynamic Island Kit demo screenshot](Assets/Screenshots/demo-recipes.png)

[![Swift](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)](#)
[![iOS](https://img.shields.io/badge/iOS-17%2B-111111?logo=apple&logoColor=white)](#)
[![CI](https://img.shields.io/badge/CI-ready-34C759)](#)
[![License](https://img.shields.io/badge/License-MIT-007AFF)](LICENSE)

A focused SwiftUI rendering kit for Live Activities and Dynamic Island, paired with a complete ActivityKit demo that shows where product-specific models, lifecycle code, and deep links belong.

Part of the Apple Design Templates collection.

## Scenarios

The template includes six practical scenarios:

| Scenario | Good for |
| --- | --- |
| Delivery | courier, food, package, marketplace tracking |
| Ride | taxi, pickup, driver arrival, shared transport |
| Timer | focus, workout, meditation, cooking, study sessions |
| Sports | live score, match clock, period-based status |
| Download | file transfer, media sync, offline maps, imports |
| Trip | boarding, gate, route progress, travel timeline |

## What is inside

- Reusable SwiftUI components for Lock Screen cards, compact Dynamic Island, minimal Dynamic Island, and expanded Dynamic Island.
- A domain-neutral presentation model that carries its own symbol, accent, and accessibility text.
- App-specific ActivityKit attributes and lifecycle code contained in the demo instead of the package API.
- Runtime timeline snapshots keep real Live Activities fresh even when the static demo data is reused later.
- Deterministic recipe data for six scenarios, so designers and developers can iterate without backend setup.
- A complete Xcode demo app with a WidgetKit extension.
- Package tests for presentation metadata, timeline snapshots, accessibility summaries, and safe progress decoding.
- A real simulator screenshot for the public preview and reproducible component preview assets produced with `Tools/render_preview_assets.py`.

## Run the demo

Requirements:

- Xcode 26 or newer
- iOS 17 or newer simulator/device
- Swift 6

Open:

```bash
open Examples/LiveActivityDemo/LiveActivityDemo.xcodeproj
```

Choose the `LiveActivityDemo` scheme and run on an iPhone simulator or device. In the app, choose a scenario, start the Live Activity, and move through the timeline states.

Optional: regenerate the Xcode project with XcodeGen:

```bash
cd Examples/LiveActivityDemo
xcodegen generate
open LiveActivityDemo.xcodeproj
```

XcodeGen is not required. The checked-in `.xcodeproj` remains ready to open directly.

Run package tests:

```bash
swift test
```

Compile the demo app from Terminal:

```bash
xcodebuild \
  -project Examples/LiveActivityDemo/LiveActivityDemo.xcodeproj \
  -scheme LiveActivityDemo \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Add the package

After the `0.1.0` release is published, add the package dependency in Xcode or in `Package.swift`:

```swift
dependencies: [
    .package(
        url: "https://github.com/mikonyaa/LiveActivityDynamicIslandKit.git",
        from: "0.1.0"
    )
]
```

Then add the product to both your app and widget targets:

```swift
.product(name: "LiveActivityKit", package: "LiveActivityDynamicIslandKit")
```

Until the first release is published, clone the repository and use the local package path. This avoids presenting an unreleased tag as installable.

## Integrate into your app

1. Add the `LiveActivityKit` product to your app and widget extension.
2. Define your own `ActivityAttributes` in a source file shared by those two targets.
3. Add `NSSupportsLiveActivities` to the app target.
4. Map your domain state into `LiveActivityContentModel`.
5. Keep Live Activity updates short, glanceable, and state-driven.

Detailed integration notes are in [Docs/INTEGRATION.md](Docs/INTEGRATION.md).

## Structure

```text
Sources/LiveActivityKit/
  Models/      domain-neutral content and porcelain palette
  Views/       Lock Screen and Dynamic Island SwiftUI surfaces

Examples/LiveActivityDemo/
  LiveActivityDemo/         demo app and local controller
  LiveActivityDemoWidgets/  real WidgetKit ActivityConfiguration
  Shared/                   demo-only scenario and ActivityAttributes

Docs/
  ARCHITECTURE.md
  CUSTOMIZATION.md
  INTEGRATION.md
  MIGRATION-0.1.md
```

## Design principles

- One state model drives every surface.
- The Lock Screen card carries context; the island surfaces stay glanceable.
- Motion and progress are calm, not decorative.
- The visual system uses one porcelain palette by default, so the demo stays stable and easy to adapt.
- The demo data is realistic enough for product work but small enough for beginners to understand.

Official Apple references:

- [ActivityKit](https://developer.apple.com/documentation/activitykit)
- [Displaying live data with Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)
- [DynamicIsland](https://developer.apple.com/documentation/widgetkit/dynamicisland)
- [Launching your app from a Live Activity](https://developer.apple.com/documentation/activitykit/launching-your-app-from-a-live-activity)

## License

MIT. Use it in personal, commercial, and open-source projects.
