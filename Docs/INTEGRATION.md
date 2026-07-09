# Integration

## 1. Add the kit

Use the Swift package or copy `Sources/LiveActivityKit` into your app.

If you copy the source, keep the folder split:

```text
Models/
Recipes/
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

## 4. Replace recipe data

Start with `LiveActivityRecipeData.swift`.

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

For production, move lifecycle work into a small service or actor that owns the active activity handle.

## 6. Test on device

The simulator is good for layout checks. Always validate final Live Activity behavior on a real device because Lock Screen, notification settings, and Dynamic Island behavior depend on system state.
