# 0.1.0 release record

Release candidate verified on July 13, 2026. This record contains simulator evidence only and makes no physical-device claim.

## Automated gates

- `swift test`: package tests passed.
- `xcodebuild test`: demo route and lifecycle-policy tests passed on iPhone 17 Pro / iOS 26.5 simulator.
- SwiftLint strict mode: passed.
- XcodeGen `2.45.4`: checked-in project reproduced without diff.
- Generic iOS Simulator build: passed.
- Repository hygiene, documentation links, and publication scan: passed.

## Runtime matrix

### iPhone 17 Pro / iOS 26.5 simulator

- Start, state update, and 30-second end/dismissal flow passed.
- Compact and expanded Dynamic Island rendering passed.
- Lock Screen rendering passed.
- Deep-link return selected the exact recipe state.
- Active session recovery after terminating and relaunching the app passed.
- Light, dark, and accessibility Dynamic Type layout review passed.

### iPhone 12 / iOS 26.2 simulator

- Start, state update, Lock Screen rendering, and end passed.
- The no-Dynamic-Island hardware class behaved correctly without an island surface.

## Publication decision

The open-source template release is approved from simulator evidence. Integrating applications should still complete hardware-specific QA before their own customer release.
