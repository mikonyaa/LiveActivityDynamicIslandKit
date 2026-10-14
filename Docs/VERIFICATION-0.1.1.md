# 0.1.1 release candidate verification

Baseline: `f577568f466136e28da427e55aa639170fafbac6` (public `0.1.0`).
This record separates controller fixtures, hosted rendering, simulator system calls, and physical-device acceptance. The final publication SHA, exact-SHA CI links, checksums and public consumer results are recorded in the [GitHub prerelease](https://github.com/mikonyaa/LiveActivityDynamicIslandKit/releases/tag/0.1.1-rc.2) and its `publication.json` asset.

## Identity and ordering contract

- Gallery selection and widget links change a preview and a single typed navigation destination. They never implicitly send ActivityKit updates.
- A session retains its original scenario and initial state identifier in immutable attributes. State actions update only a matching scenario.
- To change scenarios, explicitly **End** the old session, then **Start** the new one. While browsing a different recipe, status names the running scenario and explains this sequence.
- Restore validates both the immutable initial state identifier and dynamic content identifier against the scenario's four known states. Unknown/older identity remains available for End and reports an error; it cannot report restoration success or accept updates. This demo has no versioned schema field; future applications must define their own migration policy.
- End takes priority over queued updates. An update already awaiting ActivityKit completes at its safe point, then one End executes. Later update requests cannot clear that terminal intent.
- Events carry a system session identifier and observation generation. Cancelled old observers and delayed update completions cannot revive an ended session.
- Permission changes come from `activityEnablementUpdates` and foreground reconciliation. Disabling new activities retains a handle to any existing session so it can still be ended.
- Permission, stale, terminal, and failed states take precedence over transient messages. Final content uses explicit `staleDate: nil`; updates use the model deadline.

## Measured local evidence

Host toolchain: Apple Swift 6.4, Xcode 27.0 (`27A266a`), Swift tools 6.0, XcodeGen 2.45.4, SwiftLint 0.65.0. Targets remain iOS 17 / macOS 14. Task-owned iPhone 18 Pro / iOS 27.0 and iPhone 16 / iOS 26.5 simulators were created; no existing simulator or project was reused or erased.

Before fixes, six controller scenarios failed with ten assertions, and the ambiguous URL regression failed. A real cold/warm URL UI test failed against the old navigation implementation. The original six package tests passed; new model regressions then failed before their fixes.

`swift test` passed 17 tests. The final demo suite contains 26 controller/route/payload tests and four simulator UI tests; both local iOS 27.0 and iOS 26.5 runs are retained with their actual completion status in the accompanying verification evidence. SwiftLint strict mode found zero violations. A generic simulator build and an unsigned Release device build passed. The unsigned build is suitable for selecting a team and signing in Xcode; it is not an installed-device test.

One iOS 27 repeat was interrupted after an unexpected UI test exit and a scene-create watchdog; the app's triggered stack was loading UIKit accessibility bundles through dyld. The failure log and extracted diagnostic are retained. This run is not counted as a pass. The first retry was cancelled by cleanup of a still-live previous runner; it is also excluded from passing evidence. After all earlier runners exited, the subsequent serial iOS 27 run passed all 29 demo/UI tests on the restarted task-owned simulator. Its stable Home attachment visibly shows the actual compact Dynamic Island; this does not certify other system sizes or physical hardware.

Final counts, exit codes, SDK/OS identifiers, logs, and `.xcresult` attachments are in the accompanying verification evidence. Fake adapter tests measure the real controller's output and visible/result state while controlling the timing of external operations; they do not call ActivityKit. Hosted bitmap tests exercise SwiftUI rendering on macOS and compare unknown fractions across light/dark surfaces; they do not measure VoiceOver speech.

The UI target opens URLs through `XCUIDevice.shared.system.open`, including after terminating the app, rather than calling the parser directly. For every one of the six scenarios × four actual IDs, it checks cold entry, warm entry, repeated entry and one Back action returning to the gallery. It also checks a malformed URL without a false state change. The production adapter UI scenario exercises local Start, Update, app termination/relaunch, explicit scenario replacement and End. Screenshots attached to those tests preserve their provenance.

The first branch CI at `8ca1aa0e570818f9eba547a0b0f9930f6266f603` failed and is not counted as an overall pass. Both SDK jobs passed package tests, app unit tests and external consumers; the current SDK also passed all four UI tests. Xcode 16.4's direct `XCUIApplication.open` cold-launch fixture did not display the route, although its warm system-open cases passed. The follow-up uses the same system-open API for cold and warm entry and expands cold coverage to all 24 pairs. The first CI also exposed a generated navigator reference dependent on the checkout's basename. A relative package alias now preserves the real local package reference and gives byte-identical XcodeGen 2.45.4 output across checkout names. Final rerun outcomes are retained separately in the release evidence.

The complete branch CI at `3f1702708e87d617ee804c5d61791fca1a03a861` and its main CI passed both SDKs. A subsequent `0.1.1-rc.1` tag run exposed an additional UI interleaving on Xcode 16.4: the system's terminal event preceded completion of `end()`, leaving the Start button disabled. The draining flag influenced Start availability but was excluded from Observation. A deterministic held-End test registered observation after the terminal mutations and reproduced the missing notification (one failing assertion among 26 app tests). The flag is now observable; Start remains blocked until the in-flight operation completes, then its view is notified. The UI fixture waits for both button existence and enablement before replacement. This is a controller fix; the earlier passing runs do not negate that interleaving. Final `rc.2` evidence is scoped to its own source SHA.

## Integration and payloads

`Tools/check-external-consumer.sh` creates an independent Swift tools 6 consumer outside the repository. Remote mode resolves the exact public `0.1.0`; local mode uses the RC path. Its independent File transfer model composes Lock Screen, both compact views, minimal, and expanded views using only public imports. Evidence retains `Package.resolved`, tool versions, source hashes, command logs and probe output. A published RC consumer must separately resolve the prerelease tag.

The app adapter validates JSON-encoded attributes plus content state against 4096 bytes before request/update/end. All 24 actual demo snapshots are encoded in the payload tests; an oversized UTF-8 fixture produces `DemoActivityError.payloadTooLarge(bytes:)` without truncation. This is a conservative app preflight based on the two encoded values, not a claim about Apple's private serialization overhead. ActivityKit can still reject a request for other system reasons, which the UI reports.

## Public API and migration

`LiveActivityKit` remains a rendering boundary with no external dependencies. Public model/view signatures and existing Codable keys remain unchanged. Determinate accessibility summaries now include localized progress percentages, remaining text and route labels without exact duplicate fragments. Apps supply localized labels and may apply their own SwiftUI accessibility overrides. Indeterminate surfaces ignore the stored fraction and show a dashed unknown indicator.

Timeline public setters normalize the end to at least the start. `liveTimelineSnapshot` rebases a deterministic snapshot's planned duration for this demo; it does not extend a real business deadline or implement a running timer. Timer recipes remain predefined snapshots.

Expected SemVer category: patch (`0.1.1`), published as `0.1.1-rc.2`. The preceding `rc.1` tag remains as a superseded candidate without a GitHub Release.

## Remaining physical-device gates

These are pending, not inferred from unit tests or screenshots:

1. On a physical Dynamic Island iPhone and a physical iPhone without it, inspect all required fields on Lock Screen and compact/minimal/expanded system surfaces, including long labels, dark/light appearance and accessibility text sizes.
2. Listen to actual VoiceOver output for a transfer showing 12 MB, 25%, 90 seconds and a route, plus unknown progress without a false percentage. Check focus and spoken order on every system surface.
3. In the user's Settings, disable/enable Live Activities, return to the app and confirm action/status recovery; lock/unlock, system dismissal, and force-quit/relaunch must preserve or terminate the correct system identity.
4. Build/sign with an explicitly chosen development team and install on those devices. The project retains automatic signing with an empty team; this work does not alter the user's signing account or settings.

No APNs, backend or remote update evidence is claimed. System dismissal can remove the Activity independently of the application's business event.

## Primary references checked

- [Apple: Displaying live data with Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities) — immutable/dynamic contract, combined 4 KB budget, end/dismissal and authorization streams.
- [Apple: ActivityAttributes](https://developer.apple.com/documentation/activitykit/activityattributes).
- [Apple: ActivityAuthorizationInfo](https://developer.apple.com/documentation/activitykit/activityauthorizationinfo).
- [Apple: Understanding the navigation stack](https://developer.apple.com/documentation/swiftui/understanding-the-navigation-stack).
- [Swift PackageDescription](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html).

ActivityKit case availability was also checked in the installed Xcode 27 SDK. The `pending` case and native glass controls retain compiler guards for older SDKs; CI builds/tests with Xcode 16.4 and 26.5.
