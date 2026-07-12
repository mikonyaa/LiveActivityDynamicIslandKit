# Live Activity & Dynamic Island Kit

Сфокусированный SwiftUI rendering kit для Live Activities и Dynamic Island с полноценной локальной ActivityKit-лабораторией.

## Что внутри

- Reusable Lock Screen, compact, minimal и expanded Dynamic Island surfaces.
- Один domain-neutral content model с progress, timeline, symbol, accent и accessibility text.
- Адаптивная Porcelain-тема и public light/dark palettes для брендинга без форка.
- Настоящий demo app + WidgetKit extension: start, update, recovery после relaunch, точный deep link и end.
- 6 практичных сценариев без backend setup.
- Swift 6, iOS 17+, zero runtime dependencies, package/demo tests и strict SwiftLint.

## Запуск

Нужны Xcode 26+, Swift 6 и iOS 17+ simulator.

```bash
open Examples/LiveActivityDemo/LiveActivityDemo.xcodeproj
```

Запусти схему `LiveActivityDemo`, открой recipe и нажми **Start**. Переходы по lifecycle timeline обновляют реальную системную Live Activity.

## Подключение

Добавь package URL:

```text
https://github.com/mikonyaa/LiveActivityDynamicIslandKit.git
```

Версия: `0.1.0`. Product `LiveActivityKit` нужно подключить одновременно к app target и widget extension.

App-specific `ActivityAttributes`, routing и lifecycle остаются в твоём приложении; package отвечает только за модель представления и reusable SwiftUI surfaces.

Каноническая и наиболее полная документация — [README.md](README.md).
