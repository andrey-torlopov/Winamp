---
name: swift-review
description: Глубокий code review Swift-кода с фокусом на memory safety, concurrency, Swift conventions и архитектуру. Используй для ревью модулей, PR или отдельных файлов. Не используй для анализа зависимостей - для этого /dependency-check.
allowed-tools: "Read Write Edit Glob Grep Bash(wc*)"
context: fork
---

# /swift-review - Глубокий Swift Code Review

<purpose>
Структурированный code review Swift-кода по чек-листу: memory safety, concurrency, conventions, error handling, performance, architecture. Результат - отчет с приоритизированными findings.
</purpose>

## Когда использовать

- Ревью модуля/файла перед мержем
- Аудит качества кода после рефакторинга
- Поиск потенциальных проблем в существующем коде
- Глубокий анализ конкретного аспекта (concurrency, memory)

## Когда НЕ использовать

- Быстрый review diff (используй команду `/short_review`)
- Анализ зависимостей (используй `/dependency-check`)
- Разведка нового репо (используй `/repo-scout`)

## Входные данные

| Параметр | Обязательность | Описание |
|----------|:--------------:|----------|
| Scope | Обязательно | Путь к файлу, модулю или директории |
| Focus | Опционально | Конкретный аспект: memory, concurrency, architecture, all |

По умолчанию Focus = all.

---

## Verbosity Protocol

**SILENT MODE:** Весь analysis идет в артефакт, не в чат.

**В чат:** Только финальная сводка + путь к отчету.

**Tools first:** Read -> analyze -> report, без промежуточных комментариев.

---

## Алгоритм

### Шаг 1: Scope Discovery

1. Определи файлы для ревью:
   - Если указан файл -> один файл
   - Если указана директория -> все .swift файлы в ней (без тестов)
   - Если указан модуль -> Sources/{module}/**/*.swift

2. Прочитай CLAUDE.md (если есть) для понимания конвенций проекта.

3. Подсчитай объем: `wc -l` для каждого файла.

### Шаг 2: Memory Safety Review

Прочитай `references/swift-checklist.md` секция "Memory Safety".

Для каждого файла проверь:
- **Retain cycles:** escaping closures без [weak self], delegate без weak
- **Closure captures:** неявный захват self в escaping closures
- **Force unwrap:** использование `!` (кроме IBOutlet и тестов)
- **Implicitly unwrapped optionals:** `Type!` без обоснования
- **Unowned:** использование unowned (риск краша при nil)

### Шаг 3: Concurrency Review

Прочитай `references/concurrency-rules.md`.

Для каждого файла проверь:
- **Sendable:** типы, передаваемые между actors, помечены как Sendable?
- **@MainActor:** UI-код помечен @MainActor (не DispatchQueue.main)?
- **Data races:** мутабельное shared state без синхронизации
- **Structured vs Unstructured:** Task {} вместо async let / TaskGroup
- **Task.detached:** использование Task.detached() без необходимости
- **Actors:** корректное использование actor isolation
- **@unchecked Sendable:** обоснованность использования

### Шаг 4: Swift Conventions Review

Для каждого файла проверь:
- **let vs var:** var где можно let
- **guard:** вложенные if let вместо guard
- **Value types:** class где достаточно struct
- **Naming:** соответствие Swift API Design Guidelines
- **Any/AnyObject:** использование без необходимости (предпочитай протоколы/дженерики)
- **Explicit types:** .init вместо явного типа

### Шаг 5: Error Handling Review

Для каждого файла проверь:
- **throws vs optionals:** optional для ошибочных состояний вместо throws
- **Empty catch:** catch {} без обработки
- **Try?:** потеря информации об ошибке без логирования
- **Result:** корректность использования Result<Success, Failure>

### Шаг 6: Architecture Review

Для каждого файла проверь:
- **Responsibility:** файл/класс делает слишком много (>300 строк - повод задуматься)
- **Dependencies:** жесткие зависимости вместо протоколов
- **Layer violations:** UI-код в бизнес-логике или наоборот
- **SwiftUI specifics:** @State/@Binding/@ObservedObject/@StateObject корректность

### Шаг 7: Report Generation

Сохрани отчет в путь указанный пользователем или `audit/swift-review-report.md`.

---

## Severity Model

| Severity | Критерии |
|----------|----------|
| **BLOCKER** | Краш в рантайме: force unwrap, data race, retain cycle с утечкой |
| **CRITICAL** | Баг при определенных условиях: race condition, missing error handling |
| **WARNING** | Нарушение конвенций, потенциальный tech debt |
| **INFO** | Стилистика, мелкие улучшения |

---

## Формат отчета

```markdown
# Swift Review Report

> Scope: {path}
> Файлов: {N} | Строк: {M}
> Дата: {YYYY-MM-DD}

## Summary

| Severity | Количество |
|----------|:----------:|
| BLOCKER | {N} |
| CRITICAL | {N} |
| WARNING | {N} |
| INFO | {N} |

## Findings

### BLOCKER

| # | Файл:строка | Категория | Описание | Рекомендация |
|---|------------|-----------|----------|--------------|

### CRITICAL

| # | Файл:строка | Категория | Описание | Рекомендация |
|---|------------|-----------|----------|--------------|

### WARNING

| # | Файл:строка | Категория | Описание | Рекомендация |
|---|------------|-----------|----------|--------------|

### INFO

| # | Файл:строка | Категория | Описание | Рекомендация |
|---|------------|-----------|----------|--------------|
```

---

## Quality Gates

- [ ] Все файлы в scope прочитаны
- [ ] Каждый finding имеет severity + файл:строка + рекомендацию
- [ ] Нет false positives (контекст проверен)
- [ ] BLOCKER/CRITICAL findings имеют конкретный пример кода

## Завершение

```
SKILL COMPLETE: /swift-review
|- Артефакты: {путь к отчету}
|- Scope: {N} файлов, {M} строк
|- Findings: {B} BLOCKER, {C} CRITICAL, {W} WARNING, {I} INFO
```

## Связанные файлы

- Чек-лист: `references/swift-checklist.md`
- Concurrency: `references/concurrency-rules.md`
