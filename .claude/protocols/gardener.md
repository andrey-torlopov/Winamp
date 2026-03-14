# 🌱 Gardener Protocol

<system_requirements>
SSOT. Подключается через `SYSTEM REQUIREMENTS` в SKILL.md и `Protocol Injection` в agents.
</system_requirements>

<triggers>
  <activate_on>
    1. Пользователь нашёл ошибку в output скилла
    2. Auditor нашёл ошибку, требующую >1 итерации
    3. Обнаружен анти-паттерн, отсутствующий в `swift-antipatterns/`
  </activate_on>

  <do_not_activate_on>
    Штатные compilation fix, разовые опечатки, user preference изменения.
  </do_not_activate_on>
</triggers>

<algorithm>
  Оценить: "Могла ли обновлённая документация предотвратить этот класс ошибок?"

  <decision>
    - Если ДА → вывести Suggestion
    - Если НЕТ → молчать
  </decision>
</algorithm>

<routing>
  | Класс ошибки                          | Target                          |
  |---------------------------------------|---------------------------------|
  | Повторяющийся паттерн в коде          | `swift-antipatterns/{name}.md`  |
  | Неверный формат/структура output      | `skills/{skill}/SKILL.md`       |
  | Неверное решение агента               | `agents/{agent}.md`             |
  | Глобальное соглашение                 | `CLAUDE.md` или `dev_agent.md`  |
</routing>

<output_format>
```
🌱 GARDENER SUGGESTION
├─ Target: [файл]
├─ Root Cause: [одна строка]
└─ Patch: [≤3 строк diff]
```

Только suggestion — применять после подтверждения пользователя.
</output_format>
