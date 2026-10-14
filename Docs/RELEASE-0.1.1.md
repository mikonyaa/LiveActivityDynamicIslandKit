# 0.1.1-rc.2 release notes

This candidate fixes local ActivityKit lifecycle and navigation defects while preserving the rendering package's public signatures and Codable keys.

- Browsing Sports during a Delivery session no longer sends Sports content with Delivery attributes. End, then Start, explicitly replaces the session.
- Widget URLs open the correct recipe and state through an app-owned navigation path; repeated URLs keep one destination.
- End is retained during an awaited update, queued updates coalesce, and stale observers cannot reactivate an ended session. Start availability also notifies SwiftUI when a terminal system event precedes completion of the awaited End operation.
- Restore rejects incompatible scenario/state identities without a success message. Foreground and authorization-stream updates recover usable actions after Settings changes.
- Status follows permission, system dismissal, stale content and errors. Final content intentionally has no stale date.
- Accessibility includes progress, remaining time and route labels; unknown progress has consistent non-numeric indicators. Timeline mutation preserves valid date bounds.
- The demo preflights the combined 4 KB attributes/content budget and reports oversized data without truncation.
- CI tests Xcode 16.4 and 26.5, external public API consumers, UI routes/lifecycle, and pinned XcodeGen regeneration. Actual SemVer tags now trigger CI.

See [verification and pending device gates](VERIFICATION-0.1.1.md) and [asset provenance](../Assets/Screenshots/PROVENANCE.md). Simulator and fake-controller evidence are distinct; this prerelease does not certify physical Dynamic Island, Lock Screen or VoiceOver acceptance.
