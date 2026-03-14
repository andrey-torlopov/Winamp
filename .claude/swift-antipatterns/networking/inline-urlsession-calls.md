# Anti-Pattern: URLSession создается inline в коде

## Problem

`URLSession` или `URLRequest` создаются прямо в месте использования.
Каждый вызов управляет своей сессией - нет единой точки конфигурации.

## Bad Example

```swift
// ❌ BAD: inline URLSession в каждом методе
func fetchUser(id: String) async throws -> User {
    let url = URL(string: "https://api.example.com/api/v1/users/\(id)")!
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw APIError.invalidResponse
    }
    return try JSONDecoder().decode(User.self, from: data)
}
```

## Good Example

```swift
// ✅ GOOD: Запросы через APIClient с единой конфигурацией
func fetchUser(id: String) async throws -> User {
    try await apiClient.request(
        .get,
        path: "/users/\(id)",
        responseType: User.self
    )
}
```

## Why

- Inline session не переиспользует connection pool - медленные запросы
- Нет единой точки для Logging, Auth, Retry конфигурации
- При смене baseURL нужно обновлять N мест, не один Config
- Невозможно подменить сессию для тестов (mock/stub)

## Detection

```bash
grep -rn "URLSession.shared\|URLSession(" --include="*.swift" Sources/
```

## References

- (ref: networking/inline-urlsession-calls.md)
- Общий принцип: `common/no-abstraction-layer.md`
