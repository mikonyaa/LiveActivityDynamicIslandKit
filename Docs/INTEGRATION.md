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

The demo's `liveTimelineSnapshot()` rebases the planned duration of a fixed recipe snapshot to now. Use it only for deterministic demo snapshots. An application with a real deadline should send that deadline unchanged and derive its own remaining text; the helper is not a business timer.

The demo's small `LiveActivityDemoAdapter` protocol stays in the app layer. Its production implementation calls ActivityKit and observes activity state plus authorization enablement. The controller retains fixed session attributes, accepts terminal End during an update, coalesces subsequent updates and rejects events from old observation generations. Browsing and URLs only select previews; state actions can update a matching session. Explicitly End the current scenario before starting another.

Restore validates scenario and both state identifiers. Unknown identity is visible as an error and can still be ended. The system may mark content stale, end or dismiss it independently of the business event. Always reconcile after foregrounding and keep status subordinate to permission/system transitions.

Static attributes and dynamic content must fit Apple's combined **4 KB** limit. The demo adapter encodes both values and preflights 4096 bytes for request/update/end, returning `DemoActivityError.payloadTooLarge(bytes:)` without truncating strings. Budget checks belong to the integrating app; the pure rendering API imposes no arbitrary string cap. Leave margin for your own metadata and validate real ActivityKit requests as well.

Applications supply localized progress and remaining-time labels. The composed summary includes numeric progress only when determinate, remaining text and route labels, removing duplicate fragments. Apply an app-provided SwiftUI accessibility override if its wording needs domain-specific localization. Public timeline setters normalize invalid date bounds.

## 6. Verify system behavior

Use simulator system calls for repeatable integration checks and embedded previews for rendering checks. Neither proves physical VoiceOver speech, hardware clipping or Settings behavior. The [RC verification record](VERIFICATION-0.1.1.md) lists concrete physical-device gates and separates every evidence level.
