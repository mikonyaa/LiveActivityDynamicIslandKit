# Integrating the rendering kit

Share your app-owned `ActivityAttributes` between the app and widget targets. Store a ``LiveActivityContentModel`` in its content state, then use the package views in `ActivityConfiguration`.

The app remains responsible for these operations:

- checking and observing authorization, and starting an activity;
- restoring existing sessions through `Activity<Attributes>.activities`;
- serializing updates and preventing duplicate starts;
- applying exact deep-link routes;
- ending the activity when the represented event ends.

The included Activity Lab is a complete local reference for those boundaries.


The demo separates preview selection from immutable session identity. Widget links use a typed navigation path and do not issue updates. End is retained during an awaited update, and the controller filters old session events. Foreground reconciliation and the official authorization enablement stream recover actions without dropping an existing handle.

ActivityKit limits static attributes and dynamic content to a combined 4 KB. Validate at your app adapter boundary and report oversized input rather than truncating it. The package imposes no external-string limit.

``LiveActivityContentModel/liveTimelineSnapshot(now:minimumDuration:)`` rebases deterministic demo snapshots; it does not implement a business timer or update real deadlines. Accessibility composition includes localized determinate progress, remaining text and route labels. Unknown progress ignores its fraction on every surface. Physical Lock Screen, Dynamic Island and actual VoiceOver acceptance require separate device testing.
