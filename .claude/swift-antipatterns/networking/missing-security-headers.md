# Anti-Pattern: Отсутствие проверки Security Headers

## Problem

Networking layer не проверяет security headers ответа.
Сервер возвращает 200, но заголовки безопасности отсутствуют - уязвимость остается незамеченной.

## Bad Example

```swift
// ❌ BAD: Нет проверки security headers в API клиенте
func fetchUser(id: String) async throws -> User {
    let (data, response) = try await session.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw APIError.invalidResponse
    }

    return try decoder.decode(User.self, from: data)
    // X-Content-Type-Options, HSTS - не проверены
}
```

## Good Example

```swift
// ✅ GOOD: Проверка security headers в тестах API
func testRegistrationResponseHeaders() async throws {
    let response = try await apiClient.register(TestData.validRegistration())
    XCTAssertEqual(response.statusCode, 201, "Registration should succeed")

    let headers = response.allHeaderFields
    XCTAssertEqual(
        headers["X-Content-Type-Options"] as? String,
        "nosniff",
        "X-Content-Type-Options header should be nosniff"
    )
    XCTAssertNotNil(
        headers["Strict-Transport-Security"],
        "HSTS header must be present"
    )
}

// ✅ GOOD: Logging подозрительных ответов без HSTS в production
func validateSecurityHeaders(_ response: HTTPURLResponse) {
    #if DEBUG
    let requiredHeaders = ["X-Content-Type-Options", "Strict-Transport-Security"]
    for header in requiredHeaders {
        if response.value(forHTTPHeaderField: header) == nil {
            assertionFailure("Missing security header: \(header)")
        }
    }
    #endif
}
```

## Checklist (Security Headers)

| Header | Expected value |
|--------|----------------|
| `Content-Type` | `application/json` (или согласно spec) |
| `X-Content-Type-Options` | `nosniff` |
| `Strict-Transport-Security` | present (`max-age=...`) |

## What to look for in code review

- Ни один тест не проверяет security headers
- Отсутствие debug-валидации заголовков в networking layer
- ATS (App Transport Security) отключен без обоснования в Info.plist
- `NSAllowsArbitraryLoads = true` в production
