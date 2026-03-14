---
name: repo-scout
description: Сканирует iOS/Swift репозиторий, каталогизирует структуру проекта, зависимости, архитектуру и тестовое покрытие. Используй при входе в новый репо для понимания кодовой базы. Не используй для code review - для этого /swift-review.
allowed-tools: "Read Glob Grep Bash(ls*) Bash(wc*)"
context: fork
---

# /repo-scout - Разведка iOS-репозитория

<purpose>
Глубокое сканирование iOS/Swift репозитория -> структурированный отчет о проекте, зависимостях, архитектуре и текущем покрытии тестами. Дает полную картину проекта перед началом работы.
</purpose>

## Когда использовать

- Первый вход в новый iOS-репозиторий
- Перед `/init-project` - для понимания проекта
- Периодический аудит: "что изменилось в проекте?"
- Онбординг в существующий проект

## Когда НЕ использовать

- Code review (используй `/swift-review`)
- Анализ зависимостей (используй `/dependency-check`)

## Входные данные

- Путь к репозиторию (или текущая директория)
- Не требует CLAUDE.md или других AI-файлов
- Может быть **первым шагом** в новом репо

## Verbosity Protocol

**Structured Output Priority:** Весь analysis идет в артефакт, не в чат.

**Chat output:** Только Summary table + "Отчет: audit/repo-scout-report.md".

**Tools first:** Grep -> table -> report, без "Now I will grep...". Read -> analyze -> report, без "The file shows...".

**Фазы 1-5:** Silent execution. **Фаза 6:** Только Summary + путь к отчету.

---

## Алгоритм

### Фаза 1: Project Structure Scan

**Цель:** Определить тип проекта, билд-систему, структуру директорий.

1. Проверь наличие project-файлов:
   ```
   Package.swift, *.xcodeproj, *.xcworkspace, Podfile, Cartfile
   ```
   Приоритет определения: Package.swift (SPM) > xcworkspace > xcodeproj > Podfile

2. Извлеки из Package.swift (если есть):
   - Название пакета
   - Platforms и минимальные версии
   - Products (library/executable)
   - Dependencies (packages)
   - Targets и test targets

3. Определи структуру:
   ```
   Glob: Sources/*/ -> модули/фреймворки
   Glob: Tests/*/ -> тестовые таргеты
   Glob: **/Info.plist -> таргеты приложения
   Glob: **/*.entitlements -> capabilities
   ```

4. Подсчитай размер:
   ```
   Количество .swift файлов (без Tests/)
   Количество тестовых .swift файлов
   ```

### Фаза 2: Dependencies Analysis

**Цель:** Каталогизировать все зависимости.

#### 2.1 SPM Dependencies

Если есть Package.swift и/или Package.resolved:
- Список всех пакетов с версиями
- Классификация: UI, Networking, Storage, Testing, Utilities

#### 2.2 CocoaPods

Если есть Podfile:
- Список подов с версиями
- Наличие Podfile.lock

#### 2.3 Carthage

Если есть Cartfile:
- Список зависимостей

### Фаза 3: Architecture Discovery

**Цель:** Определить архитектурные паттерны проекта.

1. **UI Framework:**
   ```
   Grep: import SwiftUI -> SwiftUI
   Grep: import UIKit -> UIKit
   Grep: import Combine -> Combine usage
   ```
   Определить: SwiftUI / UIKit / Hybrid

2. **Архитектурный паттерн:**
   ```
   Grep: ViewModel, ObservableObject -> MVVM
   Grep: Presenter, Interactor, Router -> VIPER
   Grep: Store, Reducer, Effect -> TCA/Redux
   Grep: Coordinator -> Coordinator pattern
   ```

3. **Networking:**
   ```
   Grep: URLSession -> Native
   Grep: import Alamofire -> Alamofire
   Grep: import Moya -> Moya
   ```

4. **Storage:**
   ```
   Grep: import CoreData -> CoreData
   Grep: import SwiftData -> SwiftData
   Grep: import RealmSwift -> Realm
   Grep: UserDefaults -> UserDefaults usage
   Grep: import KeychainAccess|KeychainSwift -> Keychain
   ```

5. **Concurrency:**
   ```
   Grep: actor |@MainActor -> Modern concurrency
   Grep: DispatchQueue -> GCD
   Grep: import RxSwift -> RxSwift
   ```

### Фаза 4: Test Coverage Analysis

**Цель:** Оценить текущее тестовое покрытие.

1. Найди тестовые файлы:
   ```
   Glob: **/Tests/**/*.swift, **/*Tests*/**/*.swift
   ```

2. Классифицируй:
   - **Unit:** файлы с XCTestCase / @Test без сетевых/UI зависимостей
   - **UI:** файлы с XCUIApplication, XCUIElement
   - **Snapshot:** файлы с import SnapshotTesting
   - **Integration:** файлы с сетевыми моками

3. Определи тестовые фреймворки:
   ```
   Grep: import XCTest -> XCTest
   Grep: import Testing -> swift-testing
   Grep: import Quick -> Quick
   Grep: import Nimble -> Nimble
   Grep: import SnapshotTesting -> SnapshotTesting
   ```

### Фаза 5: Infrastructure Scan

**Цель:** Понять инфраструктурный контекст.

1. **CI/CD:**
   ```
   Glob: .github/workflows/*.yml -> GitHub Actions
   Glob: .gitlab-ci.yml -> GitLab CI
   Glob: fastlane/** -> Fastlane
   Glob: .bitrise.yml -> Bitrise
   Glob: Jenkinsfile -> Jenkins
   ```

2. **Linting/Formatting:**
   ```
   Glob: .swiftlint.yml -> SwiftLint
   Glob: .swiftformat -> SwiftFormat
   ```

3. **AI Setup:**
   ```
   Glob: CLAUDE.md -> Claude Code
   Glob: .claude/** -> Claude config
   Glob: .cursor/rules/*.mdc -> Cursor IDE
   Glob: .github/copilot-instructions.md -> Copilot
   Glob: AGENTS.md -> Agents
   ```

4. **Code Generation:**
   ```
   Glob: **/*.generated.swift -> Generated code
   Glob: **/Sourcery/** -> Sourcery templates
   Glob: **/SwiftGen/** -> SwiftGen
   ```

### Фаза 6: Report Generation

Собери отчет и сохрани в `audit/repo-scout-report.md`. Используй шаблон из `references/report-template.md`.

**Обязательные секции:**
1. Project Profile (name, platforms, type, dependencies count)
2. Module Structure (targets, source/test files)
3. Dependencies Catalog (SPM/Pods/Carthage с классификацией)
4. Architecture Summary (UI framework, pattern, networking, storage, concurrency)
5. Test Coverage (unit/UI/snapshot/integration)
6. Infrastructure (CI/CD, linting, AI setup)
7. Readiness Assessment (strengths + areas for improvement + next step)

## Quality Gates

- [ ] Package.swift или xcodeproj найден и проанализирован
- [ ] Все зависимости каталогизированы
- [ ] Архитектурный паттерн определен
- [ ] Тестовое покрытие оценено
- [ ] Нет placeholder-ов `{xxx}` в финальном отчете
- [ ] Readiness Assessment заполнен

## Self-Check

- [ ] **Completeness:** Все 7 секций заполнены?
- [ ] **Accuracy:** Количества файлов верифицированы?
- [ ] **No Hallucinations:** Каждый найденный паттерн подтвержден Grep-ом?
- [ ] **Readiness:** Оценка обоснована данными?

## Завершение

```
SKILL COMPLETE: /repo-scout
|- Артефакты: audit/repo-scout-report.md
|- Compilation: N/A
|- Upstream: нет
|- Modules: {N} | Swift files: {M} | Tests: {K}
```

## Связанные файлы

- Паттерны iOS: `references/ios-patterns.md`
- Шаблон отчета: `references/report-template.md`
- Следующий шаг: `/init-project` (использует отчет как вход)
