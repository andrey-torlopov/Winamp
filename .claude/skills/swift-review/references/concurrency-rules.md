# Swift Concurrency Rules

## Structured vs Unstructured Concurrency

### Предпочитай structured concurrency

| Ситуация | Правильно | Неправильно |
|----------|-----------|-------------|
| Параллельные запросы | `async let a = ...; async let b = ...` | `Task { } + Task { }` |
| N параллельных задач | `withTaskGroup { }` | Массив `Task { }` |
| Последовательные шаги | `await step1(); await step2()` | Callback chain |
| Таймаут | `withTimeout { }` | `Task.sleep` + cancel |

### Когда Task {} допустим

- Запуск async работы из sync контекста (onAppear, viewDidLoad)
- Fire-and-forget операции (логирование, аналитика)

### Task.detached() - почти никогда

Используй только когда нужно **явно отвязаться** от текущего actor context. В 99% случаев достаточно обычного Task {}.

## Sendable

### Типы, которые должны быть Sendable

- Все типы, передаваемые между actors
- Все типы в @Sendable closures
- Value types (struct, enum) с Sendable свойствами - автоматически Sendable

### @unchecked Sendable

Допустимо ТОЛЬКО с комментарием-обоснованием:
```swift
// @unchecked Sendable: потокобезопасность обеспечена через внутренний lock
final class ThreadSafeCache: @unchecked Sendable { ... }
```

Без комментария - WARNING.

## Actor Isolation

### @MainActor

- Все UI-свойства и методы
- Все @Published свойства в ObservableObject, используемые из UI
- Вместо DispatchQueue.main.async - @MainActor

### Custom Actors

- Для shared mutable state
- Вместо DispatchQueue + lock
- Вместо NSLock / os_unfair_lock

### Nonisolated

- Для computed properties без side effects
- Для методов, не обращающихся к isolated state
- Для Hashable/Equatable conformance

## Паттерны [weak self] в Task

```swift
// Правильно: weak self, усиление перед использованием
Task { [weak self] in
    let data = await fetchData()
    guard let self else { return }
    self.updateUI(data)
}

// Неправильно: усиление self сразу
Task { [weak self] in
    guard let self else { return }  // <- слишком рано
    let data = await self.fetchData()
    self.updateUI(data)
}
```

## Миграция с GCD

| GCD | Swift Concurrency |
|-----|-------------------|
| `DispatchQueue.main.async { }` | `@MainActor func` или `await MainActor.run { }` |
| `DispatchQueue.global().async { }` | `Task { }` |
| `DispatchGroup` | `async let` или `withTaskGroup` |
| `DispatchSemaphore` | `AsyncStream` или actor |
| `DispatchQueue(label:) + sync` | `actor` |
| `NSLock` | `actor` |
| `Thread.sleep` | `Task.sleep(for:)` |
