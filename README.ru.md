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

Нужны Xcode 16.4+, Swift 6 и iOS 17+ simulator. Xcode 26 включает native Liquid Glass controls; на более ранних поддерживаемых версиях используются fallback controls.

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


## Проверка кандидата 0.1.1-rc.2

Просмотр другой recipe и widget URL меняют только preview. State actions обновляют Activity с соответствующим scenario; для смены сначала нажми **End**, затем **Start**. Контроллер сохраняет End во время update, проверяет identity при restore и восстанавливает доступность после возвращения из Settings.

[Результаты проверки и внешние gates](Docs/VERIFICATION-0.1.1.md) различают fake-adapter, hosted SwiftUI и настоящие system calls в симуляторе. Проверки на физических iPhone, фактический VoiceOver и permission Settings остаются отдельной приёмкой. [Release notes](Docs/RELEASE-0.1.1.md) и [происхождение изображений](Assets/Screenshots/PROVENANCE.md) не приписывают embedded previews свойства system capture.

`liveTimelineSnapshot` — rebasing helper для заранее заданных demo snapshots, не настоящий бизнес-таймер. App adapter проверяет общий бюджет 4 KB для attributes + content и возвращает понятную ошибку без обрезки строк; rendering package сохраняет свободу внешней модели.
