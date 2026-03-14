# Flaky Sleep Tests

## Why this is bad

`Thread.sleep()` / `Task.sleep()` с фиксированным временем создает нестабильные тесты:
- На медленных машинах/CI тест падает (timeout слишком короткий)
- На быстрых машинах тест тратит время впустую
- Невозможно предсказать, сколько времени нужно async-операции

## Bad Example

```swift
// ❌ BAD: Magic number, flaky on slow CI
func testUserStatusBecomesActive() async throws {
    let userId = try await userHelper.registerUser(TestData.validRequest())

    try await Task.sleep(for: .seconds(2))  // Ждем "достаточно"

    let response = try await apiClient.getUser(userId)
    XCTAssertEqual(response.body.status, "active", "User should become active")
}

// ❌ BAD: Thread.sleep блокирует поток
func testNotificationReceived() {
    notificationService.send(notification)
    Thread.sleep(forTimeInterval: 1.0)  // Блокирует cooperative thread pool
    XCTAssertTrue(handler.didReceive)
}
```

## Good Example

```swift
// ✅ GOOD: XCTestExpectation с polling для async статуса
func testUserStatusBecomesActive() async throws {
    let userId = try await userHelper.registerUser(TestData.validRequest())

    let predicate = NSPredicate { _, _ in
        let response = try? await self.apiClient.getUser(userId)
        return response?.body.status == "active"
    }

    let expectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)
    await fulfillment(of: [expectation], timeout: 10)
}

// ✅ GOOD: Custom polling helper
func testUserStatusBecomesActive() async throws {
    let userId = try await userHelper.registerUser(TestData.validRequest())

    try await waitUntil(timeout: .seconds(10), pollInterval: .milliseconds(500)) {
        let response = try await apiClient.getUser(userId)
        return response.body.status == "active"
    }
}

// Переиспользуемый polling helper
func waitUntil(
    timeout: Duration,
    pollInterval: Duration = .seconds(1),
    condition: () async throws -> Bool
) async throws {
    let deadline = ContinuousClock.now + timeout
    while ContinuousClock.now < deadline {
        if try await condition() { return }
        try await Task.sleep(for: pollInterval)
    }
    XCTFail("Condition not met within \(timeout)")
}
```

## What to look for in code review

- `Thread.sleep()`, `Task.sleep(for:)` с фиксированным значением в тестах
- Магические числа в таймаутах без объяснения
- Комментарии типа "wait for async operation"
- Тесты, которые "иногда падают" (flaky)
- `usleep()`, `sleep()` в тестовом коде
