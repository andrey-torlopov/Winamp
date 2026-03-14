---
name: init-project
description: Генерирует CLAUDE.md для iOS/Swift проекта - сканирует репозиторий, анализирует tech stack, создает онбординг-документ. Используй для нового проекта без CLAUDE.md или настройки AI-assisted workflow. Не используй если CLAUDE.md уже настроен - редактируй вручную.
allowed-tools: "Read Write Edit Glob Grep Bash(ls*)"
context: fork
---

# /init-project - Генератор CLAUDE.md для iOS/Swift

<purpose>
Автоматическое создание CLAUDE.md (онбординг AI в проект) на основе анализа iOS/Swift репозитория.
</purpose>

## Когда использовать

- Новый iOS/Swift проект без CLAUDE.md
- Миграция существующего проекта на AI-assisted workflow
- Стандартизация CLAUDE.md по команде

## Verbosity Protocol

**Tools first:** Сканируй молча. В чат - только финальный результат.

---

## Алгоритм выполнения

### Шаг 1: Сканирование проекта

Найди и проанализируй:

1. **Project files:**
   - `Package.swift` -> SPM, targets, dependencies
   - `*.xcodeproj` / `*.xcworkspace` -> Xcode project
   - `Podfile` -> CocoaPods
   - `Cartfile` -> Carthage

2. **Структуру исходников:**
   - `Sources/` или корневые .swift файлы
   - `Tests/` или `*Tests/`
   - Модули/фреймворки

3. **Конфигурации:**
   - `.swiftlint.yml` -> SwiftLint
   - `.swiftformat` -> SwiftFormat
   - `fastlane/` -> Fastlane

4. **CI/CD:**
   - `.github/workflows/` -> GitHub Actions
   - `.gitlab-ci.yml` -> GitLab CI
   - `fastlane/Fastfile` -> Fastlane lanes

### Обработка ошибок Шага 1

**Project-файлы не найдены** -> Спроси пользователя:

```
Не удалось определить структуру проекта автоматически. Уточни:
- Тип проекта: (App / Framework / SPM Package)
- Package manager: (SPM / CocoaPods / Carthage)
- UI framework: (SwiftUI / UIKit / Hybrid)
```

**CI/CD-конфиги отсутствуют** -> Пропусти секцию CI в CLAUDE.md, отметь как TODO.

### Шаг 2: Определение Tech Stack

На основе зависимостей и кода определи:

| Категория | Что искать |
|-----------|------------|
| UI | SwiftUI / UIKit / Hybrid |
| Architecture | MVVM / VIPER / TCA / MVC |
| Networking | URLSession / Alamofire / Moya |
| Storage | CoreData / SwiftData / Realm |
| DI | Swinject / Factory / Manual |
| Concurrency | Swift Concurrency / Combine / RxSwift |
| Testing | XCTest / swift-testing / Quick+Nimble |
| Linting | SwiftLint / SwiftFormat |

### Шаг 3: Генерация CLAUDE.md

Прочитай и используй шаблон из `references/claude-md-template.md`.

Заполни все placeholder-ы `[xxx]` данными из Шагов 1-2.

### Шаг 4: Валидация

Перед сохранением проверь:

- [ ] Tech Stack соответствует реальным зависимостям
- [ ] Commands работают (проверь наличие Package.swift / xcodeproj)
- [ ] Structure отражает реальные папки
- [ ] Нет placeholder-ов вида `[xxx]` или TODO в финальном файле

## Вывод

Сохрани результат в `CLAUDE.md` в корне проекта.

## Пример диалога

```
User: /init-project

AI: Сканирую проект...

Найдено:
- Package.swift -> swift-tools-version 5.9
- Зависимости: Alamofire, SnapKit, Kingfisher
- UI: SwiftUI + UIKit (hybrid)
- Архитектура: MVVM (ViewModel + ObservableObject)
- Тесты: XCTest, 15 тестовых файлов

Генерирую CLAUDE.md...

[Показывает сгенерированный файл]

Сохранить в ./CLAUDE.md? (y/n)
```

## Связанные файлы

- Шаблон: `references/claude-md-template.md`
- Разведка: `/repo-scout` (может быть выполнен перед init-project)
