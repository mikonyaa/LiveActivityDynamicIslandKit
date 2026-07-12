# Integrating the rendering kit

Share your app-owned `ActivityAttributes` between the app and widget targets. Store a ``LiveActivityContentModel`` in its content state, then use the package views in `ActivityConfiguration`.

The app remains responsible for these operations:

- requesting authorization and starting an activity;
- restoring existing sessions through `Activity<Attributes>.activities`;
- serializing updates and preventing duplicate starts;
- applying exact deep-link routes;
- ending the activity when the represented event ends.

The included Activity Lab is a complete local reference for those boundaries.
