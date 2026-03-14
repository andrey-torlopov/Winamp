# iOS/Swift Patterns - Справочник для /repo-scout

## Project Files

| Файл | Назначение |
|------|-----------|
| `Package.swift` | SPM - модули, зависимости, таргеты |
| `Package.resolved` | SPM - зафиксированные версии зависимостей |
| `*.xcodeproj` | Xcode project (targets, schemes, build settings) |
| `*.xcworkspace` | Xcode workspace (multi-project) |
| `Podfile` / `Podfile.lock` | CocoaPods зависимости |
| `Cartfile` / `Cartfile.resolved` | Carthage зависимости |
| `.swiftlint.yml` | SwiftLint конфигурация |
| `.swiftformat` | SwiftFormat конфигурация |

## Architecture Detection Patterns

### UI Framework

| Паттерн | Фреймворк |
|---------|-----------|
| `import SwiftUI` | SwiftUI |
| `import UIKit` | UIKit |
| `import AppKit` | macOS (AppKit) |
| Оба SwiftUI и UIKit | Hybrid |

### Architecture Patterns

| Паттерн (Grep) | Архитектура |
|----------------|-------------|
| `ViewModel`, `ObservableObject`, `@Published` | MVVM |
| `Presenter`, `Interactor`, `Router`, `Assembly` | VIPER |
| `Store`, `Reducer`, `Effect`, `import ComposableArchitecture` | TCA |
| `Coordinator`, `CoordinatorProtocol` | Coordinator pattern |
| `Controller` (без ViewModel) | MVC |

### Networking

| Паттерн | Библиотека |
|---------|-----------|
| `URLSession` | Native URLSession |
| `import Alamofire` | Alamofire |
| `import Moya` | Moya (Alamofire wrapper) |
| `import Apollo` | Apollo (GraphQL) |

### Storage

| Паттерн | Технология |
|---------|-----------|
| `import CoreData`, `NSManagedObject` | CoreData |
| `import SwiftData`, `@Model` | SwiftData |
| `import RealmSwift` | Realm |
| `import GRDB` | GRDB |
| `UserDefaults` | UserDefaults |

### Concurrency

| Паттерн | Подход |
|---------|-------|
| `actor `, `@MainActor`, `async/await` | Swift Concurrency |
| `DispatchQueue`, `DispatchGroup` | GCD |
| `import RxSwift`, `Observable` | RxSwift |
| `import Combine`, `Publisher` | Combine |
| `import ReactiveSwift` | ReactiveSwift |

### DI

| Паттерн | Фреймворк |
|---------|-----------|
| `import Swinject` | Swinject |
| `import Factory` | Factory |
| `import Needle` | Needle |
| Manual init injection | Ручной DI |

## Test Patterns

| Тип | Признаки |
|-----|----------|
| **Unit** | `XCTestCase`, `@Test`, без UI/Network imports |
| **UI** | `XCUIApplication`, `XCUIElement`, `launch()` |
| **Snapshot** | `import SnapshotTesting`, `assertSnapshot` |
| **Performance** | `measure {}`, `XCTMetric` |

### Test Frameworks

| Библиотека | Назначение |
|-----------|-----------|
| `XCTest` | Apple native testing |
| `Testing` (swift-testing) | Modern Swift testing (Swift 5.9+) |
| `Quick` | BDD-style specs |
| `Nimble` | Matchers |
| `SnapshotTesting` | Snapshot tests (Point-Free) |
| `OHHTTPStubs` / `Mocker` | Network mocking |
| `ViewInspector` | SwiftUI view testing |

## Infrastructure Markers

| Glob | Что это |
|------|---------|
| `.github/workflows/*.yml` | GitHub Actions CI/CD |
| `.gitlab-ci.yml` | GitLab CI |
| `fastlane/Fastfile` | Fastlane automation |
| `.bitrise.yml` | Bitrise CI |
| `Jenkinsfile` | Jenkins pipeline |
| `Gemfile` | Ruby deps (обычно для Fastlane/CocoaPods) |
| `.ruby-version` | Ruby version manager |

## Code Generation

| Glob | Инструмент |
|------|-----------|
| `**/*.generated.swift` | Sourcery / SwiftGen output |
| `**/Sourcery/**`, `*.sourcery.yml` | Sourcery templates |
| `**/swiftgen.yml` | SwiftGen config |
| `**/*.strings` | Localization strings |
| `**/*.xcassets` | Asset catalogs |

## AI Setup Files

| Файл | Инструмент |
|------|-----------|
| `CLAUDE.md` | Claude Code |
| `.claude/skills/*/SKILL.md` | Claude Code Skills |
| `.claude/commands/*.md` | Claude Code Commands |
| `.claude/agents/*.md` | Claude Code Agents |
| `AGENTS.md` | Zed/Cline/Continue.dev |
| `.cursor/rules/*.mdc` | Cursor IDE |
| `.github/copilot-instructions.md` | GitHub/VS Code Copilot |
