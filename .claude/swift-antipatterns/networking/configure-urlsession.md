# Configure URLSession

**Applies to:** Networking layer, API clients

## Why this is bad

Дефолтная конфигурация URLSession в коде:
- Дефолтный timeout (60 секунд) вешает UI и тесты
- Кеширование по умолчанию скрывает реальные проблемы
- Отсутствие лимитов на concurrent connections приводит к resource exhaustion
- `URLSession.shared` не позволяет настроить поведение для конкретных сценариев

## Bad Example

```swift
// ❌ BAD: Дефолтная сессия без таймаутов
final class APIClient {
    let session = URLSession.shared
}

// ❌ BAD: Таймаут задается в каждом запросе по-разному
func fetchSlowEndpoint() async throws -> Data {
    var request = URLRequest(url: slowURL)
    request.timeoutInterval = 30
    let (data, _) = try await session.data(for: request)
    return data
}
```

## Good Example

```swift
// ✅ GOOD: Централизованная конфигурация
final class APIClient: Sendable {
    let session: URLSession

    init(configuration: APIConfiguration = APIConfiguration()) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = configuration.requestTimeout
        config.timeoutIntervalForResource = configuration.resourceTimeout
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.httpMaximumConnectionsPerHost = configuration.maxConnectionsPerHost
        self.session = URLSession(configuration: config)
    }
}

struct APIConfiguration: Sendable {
    let baseURL: URL
    let requestTimeout: TimeInterval
    let resourceTimeout: TimeInterval
    let maxConnectionsPerHost: Int

    init(
        baseURL: URL = URL(string: "http://localhost:8080")!,
        requestTimeout: TimeInterval = 10,
        resourceTimeout: TimeInterval = 30,
        maxConnectionsPerHost: Int = 4
    ) {
        self.baseURL = baseURL
        self.requestTimeout = requestTimeout
        self.resourceTimeout = resourceTimeout
        self.maxConnectionsPerHost = maxConnectionsPerHost
    }
}
```

## What to look for in code review

- `URLSession.shared` в production-коде (не тестах)
- `URLSessionConfiguration.default` без явных таймаутов
- `timeoutInterval` в теле отдельных запросов (а не в конфигурации)
- Разные таймауты в разных местах для одного сервиса
- Отсутствие `requestCachePolicy` (кеш скрывает баги)
