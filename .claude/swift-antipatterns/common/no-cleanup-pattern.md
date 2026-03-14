# No Cleanup Pattern

## Why this is bad

Тесты без очистки данных:
- Засоряют БД/UserDefaults/Keychain тестовыми записями
- Создают flaky тесты (конфликты уникальности)
- Делают невозможным параллельный запуск
- Усложняют отладку на staging/dev окружениях

## Bad Example

```swift
// ❌ BAD: Данные остаются навсегда
func testUserCanRegister() async throws {
    let payload = RegisterRequest(
        email: "test_\(Int(Date().timeIntervalSince1970))@example.com"
    )

    let response = try await apiClient.register(payload)
    XCTAssertEqual(response.statusCode, 201, "Registration should succeed")
    // Тест закончился, юзер остался в БД
}
```

## Good Example

```swift
// ✅ GOOD: defer гарантирует cleanup
func testUserCanRegister() async throws {
    let response = try await apiClient.register(validPayload)
    XCTAssertEqual(response.statusCode, 201, "Registration should succeed")

    let userId = response.body.userId

    // addTeardownBlock выполнится даже при падении теста
    addTeardownBlock { [weak self] in
        try? await self?.apiClient.deleteUser(userId)
    }
}

// ✅ GOOD: setUp cleanup перед каждым тестом
override func setUp() async throws {
    try await super.setUp()
    try? await apiClient.deleteUserByEmail(testEmail)
}

func testUserCanRegister() async throws {
    let response = try await apiClient.register(payload)
    XCTAssertEqual(response.statusCode, 201, "Registration should succeed")
}
```

## Рекомендованная стратегия: Cleanup-First

**Cleanup в `setUp()` (не `tearDown()`)** - рекомендованный подход для integration-тестов.

**Почему Cleanup-First лучше Cleanup-After:**
- При падении теста данные сохраняются для отладки
- Следующий запуск сам очистит перед собой (идемпотентно)
- `tearDown()` может не выполниться при crash процесса

| Стратегия | Когда |
|-----------|-------|
| **Cleanup-First (`setUp`)** | Integration-тесты, shared DB, нужна отладка при падении |
| **`addTeardownBlock`** | Тест создает уникальный ресурс, который нужно удалить сразу |
| **Cleanup-After (`tearDown`)** | Только если Cleanup-First невозможен |

## What to look for in code review

- Отсутствие `addTeardownBlock`, `setUp` cleanup или `tearDown`
- "Уникальные префиксы" как единственная стратегия изоляции
- Тесты, которые падают при повторном запуске
- `tearDown` вместо `setUp` cleanup без обоснования
- Cleanup-операции, которые не идемпотентны (падают если ресурс не существует)
