# CLAUDE.md - Шаблон для iOS/Swift проекта

> **Назначение:** Wiki проекта для AI. Первый день нового сотрудника - какой стек, где что лежит, как собирать.

---

## Шаблон

```markdown
# [Project Name]

## Context
- **Project:** [Что разрабатываем - описание приложения/фреймворка]
- **Language:** Swift
- **Platform:** [iOS / macOS / multiplatform]
- **Min deployment target:** [iOS 15.0 / iOS 16.0 / etc.]

## Tech Stack

| Категория | Технология |
|-----------|------------|
| UI | [SwiftUI / UIKit / Hybrid] |
| Architecture | [MVVM / VIPER / TCA / MVC] |
| Networking | [URLSession / Alamofire / Moya] |
| Storage | [CoreData / SwiftData / Realm / UserDefaults] |
| DI | [Swinject / Factory / Manual] |
| Concurrency | [Swift Concurrency / Combine / RxSwift] |
| Testing | [XCTest / swift-testing / Quick+Nimble] |
| Package Manager | [SPM / CocoaPods / Carthage] |
| Linting | [SwiftLint / SwiftFormat / нет] |

## Project Structure

```text
[Реальная структура проекта]
```

## Build & Run

| Действие | Команда |
|----------|---------|
| Build | `[swift build / xcodebuild -scheme ...]` |
| Test | `[swift test / xcodebuild test -scheme ...]` |
| Lint | `[swiftlint / swift-format lint / нет]` |

## Swift Conventions

- Используй `let` вместо `var` где возможно
- Предпочитай value types (struct, enum) над reference types (class)
- Используй `async/await` вместо completion handlers
- Используй structured concurrency (TaskGroup, async let) вместо Task {}
- Помечай типы как `Sendable` где возможно
- Используй `@MainActor` для UI-кода
- Обрабатывай ошибки через `throws` / `Result`
- Используй `guard` для раннего выхода
- Предпочитай `[weak self]` в escaping closures
- Не используй force unwrap (`!`) кроме IBOutlet и тестов

## Naming

- Типы и протоколы: UpperCamelCase
- Переменные, функции: lowerCamelCase
- Булевые: `isEnabled`, `hasContent`, `shouldReload`

## Safety Protocols

FORBIDDEN: `git reset --hard`, `git clean -fd`, удаление веток
MANDATORY: Backup перед деструктивными операциями
```

---

## Расположение файла

```
project-root/
└── CLAUDE.md    # В корне проекта
```
