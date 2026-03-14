# Static Test Data

**Applies to:** Unit-тесты, Integration-тесты

## Why this is bad

Статичные данные в TestData / Factory:
- Конфликты при параллельном запуске (одинаковые email/phone)
- Невозможно запустить тест дважды без cleanup
- Flaky тесты из-за `UNIQUE constraint violation`
- Скрывают проблемы изоляции между тестами

## Bad Example

```swift
// ❌ BAD: Статичные константы
enum RegistrationTestData {
    static let validEmail = "test@example.com"       // Конфликт при втором запуске
    static let validPhone = "+79991234567"
    static let validPassword = "Password123!"

    static func validRequest() -> RegisterRequest {
        RegisterRequest(
            email: validEmail,   // Всегда одинаковый
            phone: validPhone,
            password: validPassword
        )
    }
}

// ❌ BAD: Хардкод без генерации
static func validRequest() -> RegisterRequest {
    RegisterRequest(
        email: "fixed_test@example.com",  // Статика!
        phone: "+70001112233",
        password: "Test123!"
    )
}
```

## Good Example

```swift
// ✅ GOOD: Factory с генерацией уникальных данных
enum RegistrationTestData {

    static func validRequest() -> RegisterRequest {
        let suffix = Int(Date().timeIntervalSince1970)
        return RegisterRequest(
            email: "auto_\(suffix)@example.com",
            phone: "+7\(Int.random(in: 9_000_000_000...9_999_999_999))",
            password: "Test#\(UUID().uuidString.prefix(8))",
            fullName: "Test User"
        )
    }

    // Модификации через copy-паттерн
    static func withInvalidEmail() -> RegisterRequest {
        var request = validRequest()
        request.email = "invalid-email-no-at-sign"
        return request
    }

    static func withWeakPassword() -> RegisterRequest {
        var request = validRequest()
        request.password = "weak"
        return request
    }
}
```

## Pattern: Unique Suffix Generator

```swift
// ✅ Переиспользуемый генератор
enum TestDataUtils {
    static func uniqueSuffix() -> String {
        "\(Int(Date().timeIntervalSince1970))_\(Int.random(in: 1000...9999))"
    }

    static func uniqueEmail(prefix: String = "auto") -> String {
        "\(prefix)_\(uniqueSuffix())@example.com"
    }

    static func uniquePhone() -> String {
        "+7\(Int.random(in: 9_000_000_000...9_999_999_999))"
    }
}
```

## What to look for in code review

- `static let` с фиксированными email/phone/id в тестовых данных
- Factory функции без `Date()` или `UUID()` для уникальных полей
- Отсутствие рандомизации в данных, которые должны быть уникальными
- Тесты с `skip` / комментариями о "конфликтах данных"
