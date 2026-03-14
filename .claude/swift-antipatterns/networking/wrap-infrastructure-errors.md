# Wrap Infrastructure Errors

**Applies to:** Networking layer

## Why this is bad

Инфраструктурные ошибки (сеть, таймаут, DNS) не отличимы от бизнес-ошибок:
- `URLError` выглядит как баг приложения в crash-логах
- UI показывает generic ошибку вместо "Нет соединения"
- Невозможно отличить "сервер вернул ошибку" от "сеть недоступна"
- Analytics считает network timeout как app error

## Bad Example

```swift
// ❌ BAD: Infrastructure error неотличим от бизнес-ошибки
func createUser(_ request: CreateUserRequest) async throws -> UserResponse {
    let (data, response) = try await session.data(for: buildRequest(request))
    // URLError.timedOut, URLError.notConnectedToInternet бросаются как есть
    // Вызывающий код не различает причину
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 201 else {
        throw APIError.serverError
    }
    return try decoder.decode(UserResponse.self, from: data)
}
```

## Good Example

```swift
// ✅ GOOD: Разделение infrastructure и business ошибок
enum APIError: Error {
    // Infrastructure
    case noConnection
    case timeout
    case networkError(URLError)

    // Business
    case serverError(statusCode: Int, body: ErrorResponse?)
    case decodingError(DecodingError)
    case invalidResponse
}

func createUser(_ request: CreateUserRequest) async throws -> UserResponse {
    let data: Data
    let response: URLResponse

    do {
        (data, response) = try await session.data(for: buildRequest(request))
    } catch let urlError as URLError {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost:
            throw APIError.noConnection
        case .timedOut:
            throw APIError.timeout
        default:
            throw APIError.networkError(urlError)
        }
    }

    guard let httpResponse = response as? HTTPURLResponse else {
        throw APIError.invalidResponse
    }

    guard httpResponse.statusCode == 201 else {
        let errorBody = try? decoder.decode(ErrorResponse.self, from: data)
        throw APIError.serverError(statusCode: httpResponse.statusCode, body: errorBody)
    }

    do {
        return try decoder.decode(UserResponse.self, from: data)
    } catch let error as DecodingError {
        throw APIError.decodingError(error)
    }
}

// ✅ GOOD: UI различает типы ошибок
func handleError(_ error: Error) {
    switch error {
    case APIError.noConnection:
        showNoConnectionBanner()
    case APIError.timeout:
        showRetryDialog()
    case let APIError.serverError(_, body):
        showServerError(body?.message)
    default:
        showGenericError()
    }
}
```

## What to look for in code review

- `try await session.data(for:)` без catch `URLError`
- Единый `APIError.unknown` для всех типов ошибок
- UI показывает одинаковое сообщение для network error и server error
- Отсутствие NWPathMonitor / connectivity check
- `URLError` в crash-логах без оборачивания в доменную ошибку
