# No Hardcoded Timeouts

**Applies to:** Networking, тесты, polling

## Why this is bad

Захардкоженные таймауты в коде:
- Ломаются на медленном CI (timeout слишком маленький)
- Тратят время на быстром окружении (timeout слишком большой)
- Невозможно переопределить для разных окружений (debug/staging/prod)
- Magic numbers разбросаны по всему проекту

## Bad Example

```swift
// ❌ BAD: Magic numbers в тестах
func testAsyncOperation() async throws {
    let expectation = expectation(description: "Done")
    await fulfillment(of: [expectation], timeout: 5)
}

// ❌ BAD: Разные таймауты в разных местах
try await waitUntil(timeout: .seconds(3)) { /* ... */ }
try await waitUntil(timeout: .seconds(10)) { /* ... */ }
try await waitUntil(timeout: .seconds(30)) { /* ... */ }

// ❌ BAD: Хардкод таймаутов в networking
var request = URLRequest(url: url)
request.timeoutInterval = 15  // Почему 15? Для какого окружения?
```

## Good Example

```swift
// ✅ GOOD: Таймауты в конфигурации, переиспользуются
enum TestConfig {
    static let defaultPollingTimeout: Duration = {
        let seconds = ProcessInfo.processInfo.environment["POLL_TIMEOUT_SEC"]
            .flatMap(Double.init) ?? 10
        return .seconds(seconds)
    }()

    static let defaultPollingInterval: Duration = .seconds(1)

    static let expectationTimeout: TimeInterval = {
        ProcessInfo.processInfo.environment["EXPECTATION_TIMEOUT_SEC"]
            .flatMap(TimeInterval.init) ?? 5
    }()
}

// Использование
try await waitUntil(
    timeout: TestConfig.defaultPollingTimeout,
    pollInterval: TestConfig.defaultPollingInterval
) {
    let response = try await apiClient.getUser(userId)
    return response.body.status == "active"
}

await fulfillment(of: [expectation], timeout: TestConfig.expectationTimeout)
```

## What to look for in code review

- `timeout:` с literal числами в тестах и production коде
- Разные таймауты для одинаковых операций в разных местах
- Отсутствие централизованного конфига таймаутов
- `.seconds(N)`, `.milliseconds(N)` без пояснения "почему это значение"
