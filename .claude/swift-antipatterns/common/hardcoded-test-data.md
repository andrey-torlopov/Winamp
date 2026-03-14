# Hardcoded Test Data

**Applies to:** Unit-тесты, UI-тесты, snapshot-тесты

## Why this is bad

Захардкоженные данные в тестах:
- Скрывают логику выбора тестовых данных (почему именно это значение?)
- При изменении требований нужно искать все места с хардкодом
- Невозможно переиспользовать тест для других окружений
- Тестировщик копирует значения вместо понимания граничных условий

## Bad Example

```swift
// ❌ BAD: Конкретные значения без объяснения
func testSuccessfulRegistration() async throws {
    let request = RegisterRequest(
        email: "test@example.com",     // Почему именно этот?
        password: "Password123!",       // Захардкожен конкретный пароль
        fullName: "Test User"
    )

    let response = try await apiClient.register(request)
    XCTAssertEqual(response.statusCode, 201)
}
```

## Good Example

```swift
// ✅ GOOD: Factory с описанием класса данных
enum TestData {
    static func validRegistration() -> RegisterRequest {
        RegisterRequest(
            email: "auto_\(Int(Date().timeIntervalSince1970))@example.com",
            password: "Test#\(UUID().uuidString.prefix(8))",
            fullName: "Test User"
        )
    }
}

// ✅ GOOD: Для BVA - указать границу, не конкретное значение
func testMinimumPasswordLength() async throws {
    // Минимальная граница: ровно 8 символов
    let request = TestData.validRegistration()
        .with(password: String(repeating: "A", count: 8) + "1!")

    let response = try await apiClient.register(request)
    XCTAssertEqual(response.statusCode, 201, "Password at minimum boundary should be accepted")
}
```

## What to look for in review

- Конкретные email/phone/password прямо в теле теста
- Отсутствие пояснения "почему это значение" (граница? valid? invalid?)
- Одинаковые literal значения в разных тестах
- Отсутствие TestData factory / fixture builder
