---
name: skill-audit
description: Аудит SKILL.md на раздутость, дублирование, вредные паттерны ("НЕ ИСПРАВЛЯТЬ", раздутые шаблоны). Используй для оптимизации AI-сетапа и снижения токен-расхода. Не используй для аудита документации — для этого /doc-lint.
allowed-tools: "Read Write Edit Glob Grep Bash(wc*)"
context: fork
---

# Skill & Agent Audit

Аудит AI-инструкций на эффективность: находит раздутость, дублирование, вредные паттерны.

## Перед началом

Прочитай:
1. `.claude/skills/init-skill/references/validation-checklist.md` - пороги строк и обязательные секции
2. `.claude/skills/init-skill/references/yaml-reference.md` - правила YAML frontmatter

---

## Когда использовать

- После создания нового скилла через `/init-skill`
- При подозрении что скилл тратит слишком много токенов
- Периодически (раз в спринт) для всех скиллов
- После обновления CLAUDE.md

---

## Входные данные

| Параметр | Обязательность | Описание |
|----------|:--------------:|----------|
| Scope | Опционально | Путь к конкретному скиллу или "all". По умолчанию — все скиллы |

---

## Алгоритм (9 проверок)

## Verbosity Protocol

**Structured Output Priority:** Весь analysis идёт в артефакт (MD/HTML), не в чат.

**Chat output (ограничения):**
- Brief Summary: max 5 строк (что нашли, сколько, итог)
- Findings table: max 15 строк (топ по severity)
- Полный отчёт: `📊 Полный отчёт: {path}` + открыть файл

**Iterative steps:** Не выводить прогресс по каждому файлу. Checkpoint только при:
- Phase transition (Фаза N → Фаза N+1)
- Blocker обнаружен
- Завершение (SKILL COMPLETE)

**Tools first:**
- Grep → table → report, без "Now I will grep..."
- Read → analyze → report, без "The file shows..."

**Post-Check:** Inline перед SKILL COMPLETE (5-7 строк checklist), не отдельный файл.

### Check 0: Standards Drift

Проверь, что пороги в этом SKILL.md совпадают с `init-skill/references/validation-checklist.md`:
- Лимит строк SKILL.md (сейчас в чеклисте: ≤500)
- Обязательные поля YAML frontmatter
- Обязательные секции контента

Если расхождение найдено → **ERROR** «Standards Drift: {поле} в audit={X}, в checklist={Y}».
Рекомендация: обновить пороги в skill-audit/SKILL.md по чеклисту.

### Check 1: Line Count

Для каждого SKILL.md — `wc -l`. Порог берётся из `init-skill/references/validation-checklist.md` (секция «Структура», поле SKILL.md ≤ N строк):

| Порог (по чеклисту) | Severity |
|---------------------|----------|
| ≤ threshold | OK |
| threshold+1 … threshold×1.1 | WARNING |
| > threshold×1.1 | CRITICAL |

*Текущий threshold по чеклисту: **500 строк***.

### Check 1a: YAML Compliance

Для каждого SKILL.md сверь frontmatter с правилами из `init-skill/references/yaml-reference.md`:

- `name` в kebab-case, совпадает с именем папки, без "claude"/"anthropic"
- `description` содержит три части: **Что / Когда / Когда НЕ**
- `description` < 1024 символов, без XML-символов (`<`, `>`), однострочный
- Если `agent:` присутствует — referenced файл существует

Severity: **ERROR** (отсутствует обязательное поле), **WARNING** (нарушение формата description).

### Check 1b: Verbosity Protocol

Grep: `## Verbosity Protocol`, `SILENT MODE`, `NO CHAT TABLES` в SKILL.md файлах.

- Severity: **CRITICAL** (если отсутствует)
- Почему: Агенты без этого протокола замусоривают чат, выводят промежуточные таблицы и списки, тратят токены на болтовню
- Рекомендация: Добавить секцию Verbosity Protocol в SKILL.md

### Check 2: Self-Review Protocol (раздутый)

Grep: `Self-Review`, `self_review`, `_self_review.md`, шаблоны отчётов с `Scorecard`.

- Severity: **WARNING** (только если self-review шаблон >50 строк или не содержит Scorecard)
- Почему: раздутые шаблоны тратят токены; компактные Scorecard — полезный инструмент трекинга
- Рекомендация: оптимизировать шаблон до ≤50 строк с обязательным Scorecard
- **Исключения:**
  - `*_self_review.md` файлы с Scorecard — ценные артефакты трекинга прогресса. Не флагать

### Check 3: "НЕ ИСПРАВЛЯТЬ" Instruction

Grep: `НЕ ИСПРАВЛЯТЬ`, `не исправляй`, `только анализ` — в контексте review/check секций.

- Severity: **CRITICAL**
- Почему: AI документирует проблемы вместо исправления
- Рекомендация: заменить на "ИСПРАВЬ КОД/аудит, перекомпилируй"

### Check 4: Tech Stack Duplication

1. Прочитай CLAUDE.md → найди Tech Stack
2. Grep в каждом SKILL.md по ключевым словам стека (Alamofire, SnapKit, Kingfisher, etc.)
3. Если SKILL.md содержит полную таблицу стека (≥4 строки с `|`) → дублирование

- Severity: **WARNING**
- Рекомендация: заменить таблицу на `Стек LOCKED в CLAUDE.md → Tech Stack` + дополнения

### Check 5: Code Examples >50 Lines

Найти code blocks (```kotlin, ```python, etc.) в SKILL.md. Подсчитать строки в каждом.

- Severity: **WARNING** (если блок >50 строк)
- Рекомендация: вынести в `references/examples.md`, оставить 3-4 строки спецификации + ссылку

### Check 6: Decorative Code Blocks

Найти ``` блоки которые НЕ содержат код:
- Нет language identifier
- Содержимое = текст с emoji/bullet points/markdown formatting

- Severity: **INFO**
- Рекомендация: заменить на обычные списки/bold text

### Check 7: Anti-Patterns Verbosity

Найти секции BANNED/Anti-Patterns. Подсчитать строки и парные Bad/Good блоки (❌/✅ с кодом).

- Severity: **WARNING** (если пар >3 и строк >30)
- Рекомендация: заменить на однострочники, подробности → `qa-antipatterns/*.md` или skill-specific references/

### Check 8: Cross-Reference Staleness

1. Собрать ссылки из CLAUDE.md на секции/паттерны скиллов
2. Проверить что referenced секции существуют в текущих SKILL.md
3. Проверить Skill Completion Protocol на ссылки удалённых паттернов

- Severity: **ERROR**
- Рекомендация: обновить ссылки

### Check 9: Rarely-Used Sections Inline

Найти секции с:
- "промпты для кастомизации/генерации/адаптации"
- Мета-инструкции для пользователя (не для AI при выполнении)
- Контент используемый 1 раз за проект, но загружаемый каждый вызов

- Severity: **INFO**
- Рекомендация: вынести в `references/`

---

## Формат отчёта

Записать полный отчёт в `audit/skill-audit-report.md` (таблица находок + Summary).

В чат вывести только:
```
📊 Skill Audit: {N} CRITICAL, {N} WARNING, {N} INFO → audit/skill-audit-report.md
```

---

## Severity Model

| Severity | Что ловит |
|----------|-----------|
| **CRITICAL** | "НЕ ИСПРАВЛЯТЬ", SKILL.md >500 строк |
| **ERROR** | Stale cross-references |
| **WARNING** | Self-Review Protocol (раздутый >50 строк), Tech Stack дублирование, код >50 строк inline, Anti-Patterns >30 строк, 300-500 строк |
| **INFO** | Decorative ``` блоки, rarely-used sections inline |

---

## Post-Audit Check (в чат, НЕ создавай файл)

- [ ] Все скиллы в scope проверены?
- [ ] Line counts верифицированы через `wc -l`?
- [ ] Нет false positives (контекст каждого finding проверен)?
- [ ] Рекомендации конкретные (что → куда)?

**Если нашёл ошибку в аудите → исправь.**
НЕ создавай *_self_review.md.

---

### Завершение

После Post-Audit Check — напечатай блок завершения:

```
SKILL COMPLETE: /skill-audit
|- Артефакты: audit/skill-audit-report.md
|- Compilation: N/A
|- Upstream: нет
|- Findings: {N} CRITICAL, {N} WARNING, {N} INFO
```
