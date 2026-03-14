# Anti-Pattern: Async Test Pitfalls

## Problem

Неправильное использование async/await в XCTest приводит к тестам, которые проходят,
но не тестируют то, что ожидается - или зависают без диагностики.

## Bad Example

```swift
// ❌ BAD: Fire-and-forget Task в тесте - тест завершается раньше проверки
func testUserCreation() {
    Task {
        let response = try await apiClient.createUser(request)
        XCTAssertEqual(response.statusCode, 201)  // Может не выполниться
    }
    // Тест завершается сразу, не дожидаясь Task
}

// ❌ BAD: XCTestExpectation для async кода (legacy подход)
func testUserCreation() {
    let expectation = expectation(description: "User created")

    Task {
        let response = try await apiClient.createUser(request)
        XCTAssertEqual(response.statusCode, 201)
        expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5)
}

// ❌ BAD: DispatchSemaphore блокирует main thread
func testUserCreation() {
    let semaphore = DispatchSemaphore(value: 0)
    Task {
        let response = try await apiClient.createUser(request)
        XCTAssertEqual(response.statusCode, 201)
        semaphore.signal()
    }
    semaphore.wait()
}
```

## Good Example

```swift
// ✅ GOOD: async test method (Swift 5.5+, Xcode 13+)
func testUserCreation() async throws {
    let response = try await apiClient.createUser(request)
    XCTAssertEqual(response.statusCode, 201, "User creation should succeed")
}

// ✅ GOOD: Structured concurrency в тесте
func testParallelRequests() async throws {
    async let userResponse = apiClient.createUser(userRequest)
    async let profileResponse = apiClient.createProfile(profileRequest)

    let (user, profile) = try await (userResponse, profileResponse)
    XCTAssertEqual(user.statusCode, 201, "User should be created")
    XCTAssertEqual(profile.statusCode, 201, "Profile should be created")
}
```

## Why

- `Task { }` в sync test создает unstructured concurrency - тест не ждет завершения
- `XCTestExpectation` для async кода - legacy pattern, async test methods чище
- `DispatchSemaphore` может заблокировать cooperative thread pool Swift concurrency
- `async throws` test methods автоматически ждут завершения и пробрасывают ошибки

## Detection

```bash
grep -rn "Task {" --include="*Tests.swift" Tests/ | grep -v "addTeardownBlock"
grep -rn "DispatchSemaphore\|semaphore.wait" --include="*Tests.swift" Tests/
```

## References

- (ref: platform/async-test-pitfalls.md)
- Apple: Testing asynchronous code
