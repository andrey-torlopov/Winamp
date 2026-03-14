# Шаблон отчета repo-scout-report.md

```markdown
# Repo Scout Report: {project-name}

> Сгенерировано: {дата} | Скилл: /repo-scout

## 1. Project Profile

| Параметр | Значение |
|----------|----------|
| Project | {название из Package.swift / xcodeproj} |
| Type | {App / Framework / SPM Package / Workspace} |
| Platforms | {iOS 15+, macOS 13+, etc.} |
| Swift Version | {из Package.swift или build settings} |
| Package Manager | {SPM / CocoaPods / Carthage / Mixed} |
| Source Files | {N .swift файлов} |
| Test Files | {N тестовых .swift файлов} |

## 2. Module Structure

| Модуль/Target | Тип | Swift файлов | Описание |
|--------------|-----|:------------:|----------|
| {target name} | {library/executable/test} | {N} | {краткое описание} |

## 3. Dependencies Catalog

### SPM Dependencies

| # | Пакет | Версия | Категория |
|---|-------|--------|-----------|
| 1 | {package} | {version/branch} | {UI/Networking/Storage/Testing/Utilities} |

### CocoaPods (если есть)

| # | Pod | Версия | Категория |
|---|-----|--------|-----------|
| 1 | {pod} | {version} | {категория} |

**Итого:** {N} зависимостей ({X} SPM + {Y} Pods)

## 4. Architecture Summary

| Аспект | Значение | Детали |
|--------|----------|--------|
| UI Framework | {SwiftUI / UIKit / Hybrid} | {процент файлов} |
| Architecture | {MVVM / VIPER / TCA / MVC / Mixed} | {обоснование} |
| Networking | {URLSession / Alamofire / Moya} | {детали} |
| Storage | {CoreData / SwiftData / Realm / UserDefaults} | {детали} |
| Concurrency | {Swift Concurrency / GCD / Combine / RxSwift} | {детали} |
| DI | {Swinject / Factory / Manual / нет} | {детали} |
| Navigation | {NavigationStack / Coordinator / Storyboard} | {детали} |

## 5. Test Coverage

| Тип | Файлов | Расположение | Фреймворк |
|-----|:------:|-------------|-----------|
| Unit | {N} | {путь} | {XCTest / swift-testing} |
| UI | {N} | {путь} | {XCUITest} |
| Snapshot | {N} | {путь} | {SnapshotTesting} |
| Integration | {N} | {путь} | {фреймворк} |

## 6. Infrastructure

| Компонент | Наличие | Детали |
|-----------|:-------:|--------|
| CI/CD | {есть/нет} | {GitHub Actions / GitLab CI / Fastlane / Bitrise} |
| SwiftLint | {есть/нет} | {кол-во правил} |
| SwiftFormat | {есть/нет} | {детали} |
| Code Generation | {есть/нет} | {Sourcery / SwiftGen} |
| Localization | {есть/нет} | {N языков, .strings / .xcstrings} |

## 7. AI Setup Status

| Файл | Статус |
|------|--------|
| CLAUDE.md | {есть / нет} |
| .claude/skills/ | {N скиллов / нет} |
| .claude/commands/ | {N команд / нет} |
| .cursor/rules/ | {есть / нет} |

## 8. Readiness Assessment

### Сильные стороны
- {пункт 1}
- {пункт 2}

### Области для улучшения
- {пункт 1}
- {пункт 2}

### Рекомендуемый следующий шаг

{Конкретная рекомендация: /init-project, /swift-review, "настроить CI/CD" и т.д.}
```
