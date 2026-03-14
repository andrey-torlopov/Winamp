# YAML Frontmatter Reference

## Обязательные поля

### name
- **Формат:** kebab-case
- **Ограничения:**
  - Только строчные буквы, цифры, дефисы
  - Должно совпадать с именем папки скилла
  - Без префиксов "claude", "anthropic"
  - Уникально в пределах проекта
- **Примеры:**
  - ✅ `test-cases`, `api-tests`, `screenshot-analyze`
  - ❌ `TestPlan`, `api_tests`, `claude-helper`

### description
- **Формат:** `[Что делает]. [Когда использовать]. [Когда НЕ использовать]`
- **Ограничения:**
  - Максимум 1024 символа
  - Без XML тегов (<>, &lt;, &gt;)
  - Без переносов строк (однострочный)
  - Используй trigger-фразы из примеров использования
- **Структура:**
  1. Что делает (1-2 предложения)
  2. Когда использовать (конкретные сценарии)
  3. Когда НЕ использовать (anti-use-cases)
- **Примеры:**
  - ✅ `Генерирует тест-кейсы из спецификации API. Используй после /spec-audit для покрытия endpoints тестами. Не используй для UI тестирования.`
  - ❌ `Полезный инструмент для тестирования` (слишком общее)

## Опциональные поля

### allowed-tools
- **Формат:** Строка с перечислением через пробел
- **Примеры:**
  - `"Read Write Edit Glob Grep"`
  - `"Read Write Bash(wc*) Bash(git*)"`
- **Wildcards:** Bash команды можно ограничить паттерном: `Bash(ls*)` разрешает только `ls`

### agent
- **Формат:** Путь к файлу агента относительно `.claude/`
- **Пример:** `agents/sdet.md`, `agents/auditor.md`

### context
- **Варианты:**
  - `fork` — изолированный контекст (Process Isolation)
  - `inherit` — унаследованный контекст (по умолчанию)

## Примеры готовых YAML

### Analysis Skill
```yaml
---
name: swift-review
description: Глубокий code review Swift-кода с фокусом на memory safety, concurrency и Swift conventions. Используй для ревью модулей и PR. Не используй для анализа зависимостей.
allowed-tools: "Read Write Edit Glob Grep"
context: fork
---
```

### Generation Skill
```yaml
---
name: init-project
description: Генерирует CLAUDE.md для iOS/Swift проекта на основе анализа репозитория. Используй для нового проекта без CLAUDE.md. Не используй если CLAUDE.md уже настроен.
allowed-tools: "Read Write Edit Glob Grep Bash(ls*)"
context: fork
---
```

### Validation Skill
```yaml
---
name: dependency-check
description: Анализирует SPM-зависимости проекта на актуальность и конфликты. Используй перед обновлением зависимостей. Не используй для анализа кода.
allowed-tools: "Read Glob Grep Bash(swift*)"
context: fork
---
```

## Валидация

После написания YAML проверь:
- [ ] `name` = имя директории скилла
- [ ] `description` содержит все 3 части (что/когда/не когда)
- [ ] `description` < 1024 символов
- [ ] Нет XML символов в `description`
- [ ] YAML синтаксически корректен (triple-dash начало и конец)
