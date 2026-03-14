# Swift Code Review Checklist

## Memory Safety

| # | Проверка | Severity | Grep-паттерн |
|---|---------|----------|-------------|
| M-1 | Escaping closure без [weak self] | BLOCKER | `@escaping.*\{[^w]*self\.` |
| M-2 | Delegate property без weak | BLOCKER | `var delegate:` (без weak) |
| M-3 | Force unwrap (!) вне тестов и IBOutlet | CRITICAL | `[^?]!` в не-тестовых файлах |
| M-4 | Implicitly unwrapped optional без обоснования | WARNING | `var.*:.*!` |
| M-5 | Unowned reference | WARNING | `unowned` |
| M-6 | Closure capture list отсутствует в escaping | WARNING | escaping closure без `[` |
| M-7 | Strong self в Task без необходимости | INFO | `Task.*\{.*self\.` без weak |

### Правила

- В Task: если используем [weak self], не усиливаем сразу self, а только перед первым использованием
- Delegate, dataSource - всегда weak
- Timer, NotificationCenter callbacks - всегда weak self
- DispatchQueue closures - weak self если long-running

## Concurrency

Полные правила: `concurrency-rules.md`

| # | Проверка | Severity |
|---|---------|----------|
| C-1 | Мутабельное shared state без синхронизации | BLOCKER |
| C-2 | DispatchQueue.main вместо @MainActor | CRITICAL |
| C-3 | Тип передается между actors без Sendable | CRITICAL |
| C-4 | Task {} вместо structured concurrency | WARNING |
| C-5 | Task.detached() без явной необходимости | WARNING |
| C-6 | @unchecked Sendable без комментария-обоснования | WARNING |
| C-7 | Completion handler вместо async/await | INFO |
| C-8 | NSLock/Semaphore вместо actor | INFO |

## Swift Conventions

| # | Проверка | Severity |
|---|---------|----------|
| S-1 | var где достаточно let | WARNING |
| S-2 | class где достаточно struct | WARNING |
| S-3 | Вложенный if let вместо guard | WARNING |
| S-4 | Any/AnyObject без необходимости | WARNING |
| S-5 | .init вместо явного имени типа | INFO |
| S-6 | Naming не по Swift API Design Guidelines | INFO |
| S-7 | Булевые без is/has/should префикса | INFO |
| S-8 | enum для одиночных значений (лучше struct) | INFO |

## Error Handling

| # | Проверка | Severity |
|---|---------|----------|
| E-1 | Пустой catch {} | CRITICAL |
| E-2 | try? с потерей ошибки без логирования | WARNING |
| E-3 | Optional для ошибочных состояний вместо throws | WARNING |
| E-4 | fatalError() в production коде | BLOCKER |
| E-5 | Необработанный Result.failure | WARNING |

## Performance

| # | Проверка | Severity |
|---|---------|----------|
| P-1 | Вычисления в body SwiftUI View | WARNING |
| P-2 | Лишние аллокации в hot path | INFO |
| P-3 | Отсутствие lazy для тяжелых свойств | INFO |
| P-4 | Array вместо Set для поиска/contains | INFO |

## Architecture

| # | Проверка | Severity |
|---|---------|----------|
| A-1 | Файл > 500 строк | WARNING |
| A-2 | Класс/структура > 300 строк | WARNING |
| A-3 | Функция > 50 строк | INFO |
| A-4 | UI-логика в ViewModel/бизнес-слое | CRITICAL |
| A-5 | Бизнес-логика в View | WARNING |
| A-6 | Жесткая зависимость вместо протокола | INFO |

## SwiftUI Specific

| # | Проверка | Severity |
|---|---------|----------|
| U-1 | @ObservedObject где нужен @StateObject | CRITICAL |
| U-2 | @State для reference type | CRITICAL |
| U-3 | Тяжелые вычисления в body | WARNING |
| U-4 | Глубокая вложенность View (>5 уровней) | INFO |
| U-5 | Отсутствие @ViewBuilder для условных View | INFO |
