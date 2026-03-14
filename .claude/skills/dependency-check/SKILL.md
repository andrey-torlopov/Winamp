---
name: dependency-check
description: Анализирует SPM-зависимости iOS/Swift проекта на актуальность, конфликты и здоровье. Используй перед обновлением зависимостей или для аудита текущего состояния. Не используй для анализа кода - для этого /swift-review.
allowed-tools: "Read Write Glob Grep Bash(swift*) Bash(curl*) Bash(wc*)"
context: fork
---

# /dependency-check - Анализ SPM-зависимостей

<purpose>
Анализ зависимостей iOS/Swift проекта: версии, конфликты, актуальность. Помогает принять решение об обновлении зависимостей.
</purpose>

## Когда использовать

- Перед обновлением зависимостей
- Периодический аудит "здоровья" зависимостей
- При добавлении новой зависимости (проверка совместимости)
- Оценка tech debt в зависимостях

## Когда НЕ использовать

- Анализ кода проекта (используй `/swift-review`)
- Разведка репо (используй `/repo-scout`)

## Входные данные

- Путь к проекту с Package.swift (или текущая директория)

---

## Verbosity Protocol

**Tools first:** Анализируй молча. В чат - только сводка + путь к отчету.

---

## Алгоритм

### Шаг 1: Discovery

1. Найди и прочитай `Package.swift`
2. Найди и прочитай `Package.resolved` (если есть)
3. Найди `Podfile` / `Cartfile` (если есть)

Если Package.swift не найден -> сообщи пользователю и заверши.

### Шаг 2: Dependency Inventory

Для каждой зависимости извлеки:
- Название пакета
- URL репозитория
- Указанная версия / branch / revision
- Resolved версия (из Package.resolved)
- Какие targets используют зависимость

Классифицируй по категориям:
- **UI:** SnapKit, Kingfisher, Lottie, SDWebImage, etc.
- **Networking:** Alamofire, Moya, Apollo, etc.
- **Storage:** Realm, GRDB, etc.
- **Testing:** Quick, Nimble, SnapshotTesting, etc.
- **Utilities:** SwiftyJSON, KeychainAccess, etc.
- **Architecture:** TCA, RxSwift, Combine extensions, etc.

### Шаг 3: Version Analysis

Для каждой зависимости:
1. Определи тип version constraint:
   - Exact (`.exact("1.0.0")`) -> жесткая привязка, риск
   - Range (`.upToNextMajor`, `.upToNextMinor`) -> стандарт
   - Branch (`branch: "main"`) -> нестабильно
   - Revision (`revision: "abc123"`) -> заморожено

2. Отметь потенциальные проблемы:
   - Branch-based зависимости -> WARNING
   - Exact version -> INFO
   - Revision-based -> WARNING

### Шаг 4: Health Assessment

Для каждой зависимости оцени "здоровье" (без обращения к сети, только на основе данных Package.swift/resolved):

| Индикатор | Оценка |
|-----------|--------|
| Version constraint type | Strict/Flexible/Unstable |
| Используется ли в основных targets | Core/Testing/Optional |
| Количество transitive dependencies | Low/Medium/High |

### Шаг 5: Conflict Detection

1. Проверь нет ли дублирования зависимостей (одна библиотека через SPM и Pods)
2. Найди потенциальные конфликты версий (transitive dependencies)
3. Проверь совместимость platforms (если Package.swift указывает platforms)

### Шаг 6: Report Generation

Сохрани отчет в путь указанный пользователем или `audit/dependency-check-report.md`.

---

## Формат отчета

```markdown
# Dependency Check Report

> Project: {name}
> Package Manager: {SPM / CocoaPods / Mixed}
> Зависимостей: {N}
> Дата: {YYYY-MM-DD}

## Summary

| Метрика | Значение |
|---------|----------|
| Всего зависимостей | {N} |
| SPM | {N} |
| CocoaPods | {N} |
| Branch-based (нестабильные) | {N} |
| Exact version (жесткие) | {N} |
| Warnings | {N} |

## Dependencies Inventory

| # | Пакет | Версия | Constraint | Категория | Статус |
|---|-------|--------|-----------|-----------|--------|
| 1 | {name} | {version} | {range/exact/branch} | {UI/Net/...} | {OK/WARNING} |

## Warnings

| # | Пакет | Проблема | Рекомендация |
|---|-------|---------|--------------|

## Категории

### UI ({N})
{список}

### Networking ({N})
{список}

### Storage ({N})
{список}

### Testing ({N})
{список}

### Utilities ({N})
{список}

## Рекомендации

{Конкретные рекомендации по обновлению/замене зависимостей}
```

---

## Quality Gates

- [ ] Package.swift прочитан и распарсен
- [ ] Все зависимости каталогизированы
- [ ] Каждая зависимость классифицирована по категории
- [ ] Warnings имеют конкретную рекомендацию
- [ ] Нет placeholder-ов в отчете

## Завершение

```
SKILL COMPLETE: /dependency-check
|- Артефакты: {путь к отчету}
|- Зависимостей: {N} ({X} SPM, {Y} Pods)
|- Warnings: {N}
```
