# Information Leakage in Error Responses

**Applies to:** Networking layer, Error handling, Logging

## Why this is bad

Утечка внутренней информации через error handling:
- Stack traces в логах раскрывают структуру кода и библиотеки
- Internal paths раскрывают файловую систему (`/Users/developer/...`)
- Debug info раскрывает SQL-запросы, имена таблиц, connection strings
- `localizedDescription` может содержать internal details
- Crash-логи с sensitive data попадают в Crashlytics/Sentry

## Bad Example

```swift
// ❌ BAD: Полная ошибка попадает в UI
func handleError(_ error: Error) {
    showAlert(message: error.localizedDescription)
    // "The operation couldn't be completed. (NSURLError -1001: request timed out, URL: https://internal-api.company.com/v2/users)"
}

// ❌ BAD: Stack trace в логах без фильтрации
func logError(_ error: Error) {
    logger.error("Request failed: \(String(describing: error))")
    // Логирует полный NSError с userInfo, включая URL, headers, etc.
}

// ❌ BAD: Debug description попадает в production логи
func handleAPIError(_ response: HTTPURLResponse, data: Data) {
    let body = String(data: data, encoding: .utf8) ?? ""
    logger.error("API error \(response.statusCode): \(body)")
    // Body может содержать: stack trace, SQL query, internal paths
}
```

## Good Example

```swift
// ✅ GOOD: Generic сообщение для пользователя
func handleError(_ error: Error) {
    switch error {
    case APIError.noConnection:
        showAlert(message: "Нет подключения к интернету")
    case APIError.timeout:
        showAlert(message: "Сервер не отвечает. Попробуйте позже")
    case let APIError.serverError(statusCode, _) where statusCode >= 500:
        showAlert(message: "Ошибка сервера. Мы уже работаем над решением")
    default:
        showAlert(message: "Произошла ошибка. Попробуйте позже")
    }
}

// ✅ GOOD: Логирование без sensitive data
func logError(_ error: Error, context: String) {
    switch error {
    case let APIError.serverError(statusCode, body):
        logger.error("[\(context)] Server error: \(statusCode), code: \(body?.code ?? "unknown")")
        // Не логируем body.message, body.details - могут содержать PII
    case let urlError as URLError:
        logger.error("[\(context)] Network error: \(urlError.code.rawValue)")
        // Не логируем URL, headers
    default:
        logger.error("[\(context)] Error type: \(type(of: error))")
    }
}

// ✅ GOOD: Тест проверяет отсутствие утечек
func testErrorResponseDoesNotLeakInternals() async throws {
    let response = try await apiClient.sendCorruptedRequest()
    let body = response.rawBody

    XCTAssertFalse(body.contains("Exception"), "Error should not contain Exception")
    XCTAssertFalse(body.contains("/Users/"), "Error should not contain file paths")
    XCTAssertFalse(body.contains(".swift:"), "Error should not contain source references")
    XCTAssertFalse(body.contains("SELECT"), "Error should not contain SQL")
}
```

## What to look for in code review

- `error.localizedDescription` отображается пользователю напрямую
- `String(describing: error)` или `\(error)` в production логах
- Error body логируется целиком без фильтрации полей
- Отсутствие маппинга internal errors -> user-facing messages
- `debugDescription` в production коде
- URL с query parameters в логах (могут содержать токены)
