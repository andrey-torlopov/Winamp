# Assertion Without Message

## Why this is bad

XCTest assertions без сообщений:
- При падении непонятно, что именно проверялось
- В CI-логах только stack trace без контекста
- Нужно открывать код чтобы понять причину
- Xcode Test Report становятся бесполезными

## Bad Example

```swift
// ❌ BAD: Что упало? Почему?
func testUserRegistration() async throws {
    let response = try await apiClient.register(payload)

    XCTAssertEqual(response.statusCode, 201)        // XCTAssertEqual failed: ("400") is not equal to ("201")
    XCTAssertNotNil(response.body.userId)            // Какой userId? Почему nil?
    XCTAssertEqual(response.body.status, "pending")
}

// В CI-логах:
// XCTAssertEqual failed: ("400") is not equal to ("201")
// Что пошло не так?
```

## Good Example

```swift
// ✅ GOOD: XCTAssert с message
func testUserRegistration() async throws {
    let response = try await apiClient.register(payload)

    XCTAssertEqual(response.statusCode, 201, "Registration should return 201 for valid payload")
    XCTAssertNotNil(response.body.userId, "User ID should be returned after successful registration")
    XCTAssertEqual(response.body.status, "pending", "New user should have pending status until verification")
}

// ✅ GOOD: XCTContext.runActivity для группировки проверок
func testUserRegistration() async throws {
    let response = try await apiClient.register(payload)

    XCTContext.runActivity(named: "Verify HTTP 201 Created") { _ in
        XCTAssertEqual(response.statusCode, 201, "Registration should succeed")
    }

    XCTContext.runActivity(named: "Verify user ID is returned") { _ in
        XCTAssertNotNil(response.body.userId, "User ID should be present")
    }
}
```

## What to look for in code review

- `XCTAssertEqual`, `XCTAssertNotNil`, `XCTAssertTrue` без message параметра
- Несколько assertions подряд без контекста
- Отсутствие `XCTContext.runActivity` в integration тестах
- Assertions на вложенные поля без пояснения структуры
