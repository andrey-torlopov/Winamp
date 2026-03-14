# Missing Content-Type Validation

**Applies to:** Networking layer

## Why this is bad

Код не проверяет Content-Type ответа:
- Сервер может вернуть HTML вместо JSON (ошибка reverse proxy, CloudFlare challenge)
- `JSONDecoder` бросит `DecodingError` вместо понятной ошибки
- Баг обнаруживается только в production при интеграции
- Непонятные crash-логи вместо чёткого "сервер вернул не JSON"

## Bad Example

```swift
// ❌ BAD: Проверяем только status code, Content-Type игнорируется
func fetchUser(id: String) async throws -> User {
    let (data, response) = try await session.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw APIError.invalidResponse
    }

    return try decoder.decode(User.self, from: data)
    // Если сервер вернул HTML (502 от nginx) - получим DecodingError
}
```

## Good Example

```swift
// ✅ GOOD: Проверяем Content-Type перед декодированием
func fetchUser(id: String) async throws -> User {
    let (data, response) = try await session.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
        throw APIError.invalidResponse
    }

    guard httpResponse.statusCode == 200 else {
        throw APIError.serverError(statusCode: httpResponse.statusCode)
    }

    let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") ?? ""
    guard contentType.contains("application/json") else {
        throw APIError.unexpectedContentType(
            expected: "application/json",
            received: contentType,
            statusCode: httpResponse.statusCode
        )
    }

    return try decoder.decode(User.self, from: data)
}

// ✅ GOOD: Централизованная валидация в базовом методе
func request<T: Decodable>(
    _ method: HTTPMethod,
    path: String,
    responseType: T.Type
) async throws -> T {
    let (data, response) = try await session.data(for: buildRequest(method, path: path))
    try validateResponse(response, data: data)
    return try decoder.decode(T.self, from: data)
}

private func validateResponse(_ response: URLResponse, data: Data) throws {
    guard let httpResponse = response as? HTTPURLResponse else {
        throw APIError.invalidResponse
    }

    let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") ?? ""
    guard contentType.contains("application/json") else {
        throw APIError.unexpectedContentType(
            expected: "application/json",
            received: contentType,
            statusCode: httpResponse.statusCode
        )
    }
}
```

## What to look for in code review

- `JSONDecoder().decode()` без предварительной проверки Content-Type
- Отсутствие проверки Content-Type в базовом networking layer
- Error responses (4xx/5xx) не проверяются на Content-Type перед парсингом
- `DecodingError` в crash-логах (может быть следствием HTML вместо JSON)
