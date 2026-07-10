# 0.1.0 release gate

The release may be published only after every automated check and the physical-device gate are complete.

## Automated

- `swift test`
- XcodeGen `2.45.4` clean reproduction
- generic iOS Simulator demo build
- documentation and publication-artifact scan

## Physical device

Record the device model, iOS version, date, and result for:

- start from the demo app
- update through multiple states
- Lock Screen rendering
- Dynamic Island compact, minimal, and expanded rendering on supported hardware
- deep-link return to the selected scenario/state
- end and dismissal behavior

Current status: **blocked pending recorded physical-device evidence**.
