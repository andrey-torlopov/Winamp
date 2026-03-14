#!/bin/bash
# Post-edit hook: быстрая валидация SKILL.md и agents/*.md
# Полный аудит: /skill-audit

set -e

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Filter: skill files, agent files, CLAUDE.md
if [[ ! ("$FILE_PATH" == */.claude/skills/*/SKILL.md || "$FILE_PATH" == */.claude/agents/*.md || "$FILE_PATH" == */CLAUDE.md) ]]; then
  exit 0
fi

FINDINGS=""
FILENAME=$(basename "$FILE_PATH")
PARENT_DIR=$(basename "$(dirname "$FILE_PATH")")
LABEL="${PARENT_DIR}/${FILENAME}"

# Check 1: Line count
LINE_COUNT=$(wc -l < "$FILE_PATH" | tr -d ' ')
if [ "$LINE_COUNT" -gt 500 ]; then
  FINDINGS="${FINDINGS}\n  CRITICAL: ${LINE_COUNT} строк (лимит: 500)"
elif [ "$LINE_COUNT" -gt 300 ]; then
  FINDINGS="${FINDINGS}\n  WARNING: ${LINE_COUNT} строк (рекомендация: <=300)"
fi

# Check 2: Self-Review Protocol (anti-pattern)
if grep -q 'Формат отчёта Self-Review\|Алгоритм Self-Review\|Scorecard Self-Review' "$FILE_PATH" 2>/dev/null; then
  FINDINGS="${FINDINGS}\n  CRITICAL: Self-Review Protocol - заменить на Post-Check inline"
fi

# Check 3: Ссылки на несуществующие QA-артефакты
if grep -q 'qa_agent\.md\|qa-antipatterns/' "$FILE_PATH" 2>/dev/null; then
  FINDINGS="${FINDINGS}\n  WARNING: Найдены ссылки на несуществующие QA-артефакты (qa_agent.md, qa-antipatterns/)"
fi

# Check 4: YAML frontmatter в SKILL.md
if [[ "$FILENAME" == "SKILL.md" ]]; then
  if ! head -1 "$FILE_PATH" | grep -q '^---$'; then
    FINDINGS="${FINDINGS}\n  CRITICAL: Отсутствует YAML frontmatter (---)"
  fi
fi

if [ -n "$FINDINGS" ]; then
  echo -e "skill-lint: ${LABEL}${FINDINGS}" >&2
  echo -e "  Исправь найденные проблемы. Для полного аудита: /skill-audit" >&2
  exit 2
fi

exit 0
