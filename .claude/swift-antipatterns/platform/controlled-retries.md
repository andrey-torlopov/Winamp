# Controlled Retries

**Applies to:** Networking, async operations

## Why this is bad

Неконтролируемые retry-логики:
- Бесконечные retry скрывают реальные баги
- Retry без backoff перегружают сервер и батарею
- Retry всех ошибок маскируют non-retriable failures (400, 403)
- Пользователь ждет без обратной связи

## Bad Example

```swift
// ❌ BAD: Retry всех ошибок, маскирует баги
func createUserWithRetry(_ request: CreateUserRequest) async throws -> UserResponse {
    for attempt in 0..<5 {
        do {
            return try await apiClient.createUser(request)
        } catch {
            // Глотает все ошибки, включая 400 Bad Request
            try? await Task.sleep(for: .seconds(1))
        }
    }
    throw APIError.maxRetriesExceeded
}

// ❌ BAD: Retry без различия типов ошибок
func fetchData() async throws -> Data {
    var lastError: Error?
    for _ in 0..<3 {
        do {
            return try await session.data(for: request).0
        } catch {
            lastError = error
        }
    }
    throw lastError ?? APIError.unknown
}
```

## Good Example

```swift
// ✅ GOOD: Retry только для retriable ошибок с exponential backoff
func fetchWithRetry<T>(
    maxAttempts: Int = 3,
    initialDelay: Duration = .seconds(1),
    operation: () async throws -> T
) async throws -> T {
    var lastError: Error?

    for attempt in 0..<maxAttempts {
        do {
            return try await operation()
        } catch let error as URLError where error.isRetriable {
            lastError = error
            let delay = initialDelay * pow(2, Double(attempt))
            try await Task.sleep(for: delay)
        } catch {
            throw error // Non-retriable - бросаем сразу
        }
    }

    throw lastError ?? APIError.maxRetriesExceeded
}

extension URLError {
    var isRetriable: Bool {
        switch code {
        case .timedOut, .networkConnectionLost, .notConnectedToInternet:
            return true
        default:
            return false
        }
    }
}

// ✅ GOOD: Sync операции без retry - если падает, это баг
func createUser(_ request: CreateUserRequest) async throws -> UserResponse {
    try await apiClient.createUser(request)
}
```

## What to look for in code review

- `for _ in 0..<N` вокруг async-вызовов
- `catch { }` с пустым телом (проглатывание ошибок)
- Retry без различия retriable (5xx, timeout) и non-retriable (4xx) ошибок
- Отсутствие exponential backoff при retry
- Retry на синхронные CRUD-операции (не async status polling)
