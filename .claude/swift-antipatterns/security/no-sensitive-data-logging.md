# No Sensitive Data Logging

**Applies to:** Logging, Analytics, Crash reporting

## Why this is bad

Логирование чувствительных данных:
- Токены и пароли попадают в Console.app и CI-логи
- Crashlytics/Sentry отчеты с секретами доступны всей команде
- os_log с sensitive data сохраняется на устройстве
- Нарушение compliance (GDPR, PCI DSS)
- Аналитика с PII отправляется на сторонние серверы

## Bad Example

```swift
// ❌ BAD: Токен в логах
func authenticate(token: String) async throws -> AuthResponse {
    logger.info("Authenticating with token: \(token)")
    return try await apiClient.auth(token: token)
}

// ❌ BAD: Пароль в assertion message (тесты)
XCTAssertEqual(response.statusCode, 200, "Auth failed for password=\(password)")

// ❌ BAD: Полный response body с токенами
func logResponse(_ response: APIResponse<AuthResponse>) {
    print("Response: \(response.body)")
    // body содержит accessToken, refreshToken
}

// ❌ BAD: UserDefaults с sensitive data видны в device logs
UserDefaults.standard.set(apiKey, forKey: "apiKey")
logger.debug("Saved API key to UserDefaults")
```

## Good Example

```swift
// ✅ GOOD: Маскированный токен в логах
func authenticate(token: String) async throws -> AuthResponse {
    let masked = String(token.prefix(4)) + "****"
    logger.info("Authenticating with token: \(masked)")
    return try await apiClient.auth(token: token)
}

// ✅ GOOD: os_log с privacy
import os

let logger = Logger(subsystem: "com.app", category: "auth")

func authenticate(token: String) async throws {
    logger.info("Authenticating with token: \(token, privacy: .private)")
    // В release билде токен заменяется на <private>
}

// ✅ GOOD: Логируем только структуру, не значения
func logResponse<T>(_ response: APIResponse<T>) {
    logger.info("Response: status=\(response.statusCode), type=\(T.self)")
}

// ✅ GOOD: Keychain вместо UserDefaults для секретов
try KeychainHelper.save(apiKey, forKey: "apiKey")
```

## What to look for in code review

- `print()`, `NSLog()`, `logger.info()` с interpolated секретами
- `os_log` без `privacy: .private` для sensitive полей
- Response body логируется целиком (может содержать токены)
- `UserDefaults` для хранения токенов/паролей вместо Keychain
- Crashlytics custom keys с PII
- Analytics events с email, phone, name
- `debugPrint()` оставленный в production коде
