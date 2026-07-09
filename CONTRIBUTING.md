# Contributing

Keep contributions focused on reusable Apple interface patterns.

Before opening a pull request:

```bash
swift test
xcodebuild \
  -project Examples/LiveActivityDemo/LiveActivityDemo.xcodeproj \
  -scheme LiveActivityDemo \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Guidelines:

- Keep examples practical and easy to customize.
- Avoid adding backend dependencies.
- Avoid decorative motion that does not explain state.
- Keep README content concise; put deeper explanations in `Docs/`.
