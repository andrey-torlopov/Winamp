---
name: doc-lint
description: Аудит качества документации — размер, структура, дубликаты между файлами, нарушения SSOT. Используй для контроля качества human-readable файлов, поиска дублирования и проверки структуры. Не используй для code review или анализа исходного кода.
allowed-tools: "Read Write Edit Glob Grep Bash(wc*)"
context: fork
---

# /doc-lint — Аудит качества документации

<purpose>
Сканирует все human-readable файлы проекта, находит проблемы с размером, структурой, дубликатами между файлами и нарушения SSOT (Single Source of Truth). Генерирует отчёт с приоритизированными findings и планом рефакторинга.
</purpose>

## Когда использовать

- После добавления нового документа или skill
- При подозрении на дублирование контента между файлами
- Для периодического аудита документации (раз в спринт)
- Перед рефакторингом документации

## Входные данные

| Параметр | Обязательность | Описание |
|----------|:--------------:|----------|
| Scope | Опционально | Конкретные файлы/директории. По умолчанию — весь проект |
| Focus | Опционально | Только определённые фазы (size, structure, duplicates) |

---

## Алгоритм (6 фаз)

## Verbosity Protocol (STRICT)

**SILENT MODE ENFORCED:**
1.  **NO CHAT TABLES:** Никогда не выводи таблицы (Inventory, Findings, Stats) в чат. Только в файл отчёта.
2.  **NO LISTS:** Не перечисляй проверенные файлы в чате.
3.  **ONLY STATUS:** В чат выводить **только** финальный блок `SKILL COMPLETE` и путь к отчёту.

**Пример единственного допустимого вывода в чат:**
> 📝 Audit Complete.
> 📊 Report: `audit/doc-lint-report.md`
> 📉 Health Score: 78/100
> 💡 Action: Run `bash audit/safe-fix.sh` to apply safe fixes.

### Фазы 1-7: Детальный алгоритм

Полное описание всех фаз (Discovery, Size Analysis, Structure Analysis, Cross-File Duplicate Detection, Content Hygiene, Report Generation, Safe-Fix Script) — в `references/phases.md`.

---

## Severity Model

| Severity | Критерии |
|----------|----------|
| **CRITICAL** | Фактическое превышение лимитов (>700 generic, >500 SKILL); Битые ссылки (файл не найден) |
| **WARNING** | Приближение к лимиту (90% от порога); Дубликаты >10 строк; Wall-of-text >30 строк |
| **INFO** | TODO маркеры; Мелкие дубликаты (3-5 строк); Stale dates; Formatting issues |

---

## Health Score Logic

Start Score: 100.

**Deductions (вычитание):**
- CRITICAL: -15 баллов (за каждый finding)
- WARNING: -5 баллов
- INFO: -0.5 балла (снижаем вес мусора)

**Formula:** `MAX(0, 100 - (Count_Crit * 15) - (Count_Warn * 5) - (Count_Info * 0.5))`

*Бонусных баллов за "хорошее поведение" не начислять.*

| Диапазон | Оценка | Интерпретация |
|----------|--------|---------------|
| 90-100 | Excellent | Документация в отличном состоянии |
| 70-89 | Good | Есть незначительные проблемы |
| 50-69 | Needs attention | Требуется рефакторинг |
| <50 | Refactoring needed | Срочный рефакторинг документации |

**Формула должна быть показана с подстановкой значений:**
```
Score = 100 - (2 × 15) - (5 × 5) - (8 × 0.5) = 100 - 30 - 25 - 4 = 41/100
```

---

## Формат вывода

### Артефакт: `audit/doc-lint-report.md`

```markdown
# Doc-Lint Report

> Дата: {YYYY-MM-DD}
> Scope: {описание scope}
> Health Score: {N}/100 ({оценка})

## Summary

| Метрика | Значение |
|---------|----------|
| Файлов просканировано | N |
| CRITICAL | N |
| WARNING | N |
| INFO | N |
| Health Score | N/100 |
| Кластеров дубликатов | N |

## File Inventory

| # | Файл | Строк | Тип | Size Status |
|---|------|------:|-----|-------------|
| 1 | ... | ... | ... | OK/WARNING/CRITICAL |

## CRITICAL Findings

| # | Файл | Фаза | Описание | Рекомендация |
|---|------|------|----------|--------------|

## WARNING Findings

| # | Файл | Фаза | Описание | Рекомендация |
|---|------|------|----------|--------------|

## INFO Findings

| # | Файл | Фаза | Описание | Рекомендация |
|---|------|------|----------|--------------|

## Duplicate Map

### Кластер D-1: {название паттерна}
- **Тип:** Exact / Near-duplicate / Conceptual
- **SSOT Owner:** {файл}
- **Найдено в:** {список файлов с номерами строк}
- **Рекомендация:** Оставить в {Owner}, в остальных заменить ссылкой

### Кластер D-N: ...

## SSOT Refactoring Plan

| # | Действие | Файл | Что сделать |
|---|----------|------|-------------|
| 1 | REMOVE | file.md:10-25 | Удалить копию Tech Stack, добавить ссылку |

## Statistics

- Общий объём документации: {N} строк в {M} файлах
- Средний размер файла: {N/M} строк
- Файлов в пределах нормы: {X}/{M} = {%}
- Health Score: {формула с подстановкой}
```

### Post-Check Scorecard

Формат Post-Check:

**Post-Check Scorecard:**

```markdown
## Scorecard

| Критерий | Результат |
|----------|-----------|
| Все файлы просканированы | X/Y = NN% |
| Line counts верифицированы | ✅/❌ |
| Cross-file detection выполнен | ✅/❌ |
| Каждый finding имеет severity + рекомендацию | X/Y = NN% |
| Нет placeholder {xxx} | ✅/❌ |
| SSOT owner назначен для каждого кластера | X/Y = NN% |
| Формулы с числителем/знаменателем | ✅/❌ |

### Итоговый Score: NN%
```

---

## Quality Gates

- [ ] Все файлы в scope отсканированы (Glob + count verification)
- [ ] Line counts верифицированы через `wc -l`
- [ ] Cross-file duplicate detection выполнен (Фаза 4)
- [ ] Каждый finding имеет severity + рекомендацию
- [ ] Нет placeholder `{xxx}` в отчёте
- [ ] SSOT owner назначен для каждого кластера дубликатов
- [ ] Формулы показаны с числителем и знаменателем (CLAUDE.md requirement)
- [ ] Health Score рассчитан и показан с подстановкой

---

## Anti-Patterns (BANNED)

### False Positive на одинаковых заголовках

```
❌ Flagging таблиц с одинаковыми заголовками но разными данными как "duplicate"
✅ Сравнивать содержимое ячеек, не только headers
```

### Phantom Findings

```
❌ Генерировать findings на основе предположений без чтения файла
✅ Каждый finding подтверждён содержимым файла (строка, фрагмент)
```

### Missing Context

```
❌ "File is too long"
✅ "CLAUDE.md: 305 строк > порог CRITICAL (300). Рекомендация: вынести секцию X в отдельный файл"
```

### Over-flagging Intentional Repetition

```
❌ Flagging ссылок на паттерны как дубликатов (ссылки — не дубликаты)
✅ Отличать полное копирование от ссылок и краткого упоминания
```

---

## Связанные файлы

| Файл | Содержание |
|------|------------|
| `references/check-rules.md` | Пороги размеров, сигнатуры дубликатов, SSOT-матрица, Diataxis-маркеры |
| `references/best-practices.md` | Корпоративные практики: Google, Amazon, Diataxis, Microsoft, GitLab, Stripe |

---

## Завершение

После создания отчёта и скрипта — напечатай блок завершения:

```
SKILL COMPLETE: /doc-lint
|- Артефакты: audit/doc-lint-report.md, audit/safe-fix.sh
|- Compilation: N/A
|- Upstream: нет
|- Score: {Health Score}/100
```
