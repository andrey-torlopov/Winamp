# Anti-Pattern: Проверка только HTTP-кода без бизнес-ошибки

## Problem

Обработка ошибок проверяет только HTTP-статус (`400`, `422`), не проверяя `body.code` / `body.errorType`.
Код считает запрос неуспешным, но реальная причина (неверный бизнес-код ошибки) не обнаружена.

## Bad Example

```swift
// ❌ BAD: проверяем только HTTP статус
func register(_ request: RegisterRequest) async throws -> RegisterResponse {
    let (data, response) = try await session.data(for: buildRequest(request))
    guard let httpResponse = response as? HTTPURLResponse else {
        throw APIError.invalidResponse
    }

    guard httpResponse.statusCode == 201 else {
        throw APIError.serverError(statusCode: httpResponse.statusCode)
        // Бизнес-код не проверен - любой non-201 обрабатывается одинаково
    }

    return try decoder.decode(RegisterResponse.self, from: data)
}
```

## Good Example

```swift
// ✅ GOOD: проверяем HTTP статус + бизнес-код ошибки
func register(_ request: RegisterRequest) async throws -> RegisterResponse {
    let (data, response) = try await session.data(for: buildRequest(request))
    guard let httpResponse = response as? HTTPURLResponse else {
        throw APIError.invalidResponse
    }

    guard httpResponse.statusCode == 201 else {
        let errorBody = try? decoder.decode(ErrorResponse.self, from: data)
        throw APIError.businessError(
            statusCode: httpResponse.statusCode,
            code: errorBody?.code ?? "UNKNOWN",
            field: errorBody?.field,
            message: errorBody?.message ?? "No error details"
        )
    }

    return try decoder.decode(RegisterResponse.self, from: data)
}

// Вызывающий код может различать типы ошибок
do {
    let response = try await apiClient.register(request)
} catch let APIError.businessError(statusCode, code, field, message) where code == "VALIDATION_ERROR" {
    showFieldError(field: field, message: message)
} catch let APIError.businessError(statusCode, code, _, _) where code == "DUPLICATE_EMAIL" {
    showDuplicateEmailAlert()
} catch {
    showGenericError()
}
```

## Why

- HTTP `400` может приходить по многим причинам (auth, schema, rate limit)
- Без `body.code` невозможно отличить `VALIDATION_ERROR` от `MISSING_FIELD` или `RATE_LIMITED`
- UI не может показать правильное сообщение пользователю
- Регрессия в бизнес-логике ошибок остается незамеченной

## Detection

```bash
grep -rn "statusCode ==" --include="*.swift" Sources/ | grep -v "body\.\|errorBody\.\|errorResponse"
```
