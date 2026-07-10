# Live Activity & Dynamic Island Kit

Сфокусированный SwiftUI rendering kit для Live Activities и Dynamic Island с полноценным demo app и WidgetKit extension.

## Что внутри

- 6 практичных сценариев: доставка, такси, таймер, спорт, загрузка, поездка.
- Reusable SwiftUI views для Lock Screen, compact/minimal/expanded Dynamic Island.
- Domain-neutral presentation model; app-specific scenarios и `ActivityAttributes` остаются в demo.
- ActivityKit lifecycle: start, update, end.
- Runtime timeline snapshot, чтобы настоящая Live Activity не становилась stale из-за статичных demo-дат.
- Реальный Xcode demo project.
- Тесты presentation metadata, timeline snapshots, безопасного progress decoding и accessibility.

## Как запустить

```bash
open Examples/LiveActivityDemo/LiveActivityDemo.xcodeproj
```

Выбери схему `LiveActivityDemo`, запусти на iPhone simulator/device, выбери scenario и нажми Start.

Опционально можно пересобрать Xcode project через XcodeGen:

```bash
cd Examples/LiveActivityDemo
xcodegen generate
open LiveActivityDemo.xcodeproj
```

Проверка пакета:

```bash
swift test
```
