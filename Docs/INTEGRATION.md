# Integration

## 1. Add the kit

Use the Swift package or copy `Sources/LiveActivityKit` into your app. Link `LiveActivityKit` to both the app target and widget extension.

If you copy the source, keep the folder split:

```text
Models/
Views/
```

## 2. Add a widget extension

Live Activities render through WidgetKit. Your app target starts and updates the activity; your widget extension defines the system surfaces.

Use `LiveActivityDemoWidgets.swift` as the reference implementation.

## 3. Enable Live Activities

Add this key to the app target Info.plist:

```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

## 4. Own the ActivityKit contract

Define your app's `ActivityAttributes` in a source file shared by the app and widget extension. Keep business identifiers and deep-link routing there; the package only renders `LiveActivityContentModel`.

Use the files in `Examples/LiveActivityDemo/Shared` as a concrete reference, then map each product state into a model with an SF Symbol, accessibility title, content, progress, and accent.

For a real product, keep these rules:

- Use short titles.
- Use progress only when the user understands what is progressing.
- Keep detail rows stable across states.
- Use deep links that land on the exact screen represented by the activity.

## 5. Start, update, and end

The demo controller shows the local lifecycle:

- `Activity.request(...)`
- `activity.update(...)`
- `activity.end(...)`

Before sending content to ActivityKit, convert static/demo timeline data into a live snapshot. `LiveActivityContentModel.liveTimelineSnapshot()` resets `startedAt` to the current time and keeps `staleDate` in the future. If `staleDate` is already in the past, iOS can create the activity and immediately mark it stale, which makes the Dynamic Island and Lock Screen surfaces look like they did not start.

For production, move lifecycle work into a small service or actor that owns the active activity handle. Restore existing sessions from `Activity<YourAttributes>.activities`, serialize mutations, and prevent duplicate starts. The package does not prescribe that service because its lifetime and update source are app-specific.

## 6. Verify system behavior

The simulator supports repeatable layout, lifecycle, Lock Screen, Dynamic Island, deep-link, color-scheme, and accessibility checks. Before shipping a production app to customers, also validate on every supported hardware class because notification settings and system state differ from a simulator.
