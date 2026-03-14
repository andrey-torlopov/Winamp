# Anti-Pattern: XCTestCase Setup Crashes

## Problem

Тяжелая инициализация в `init()` или property declaration XCTestCase приводит к падению
всего тест-класса без диагностики. XCTest пропускает класс целиком.

## Bad Example

```swift
// ❌ BAD: Property initialization может упасть
class APITests: XCTestCase {
    let apiClient = APIClient(
        configuration: APIConfiguration(
            baseURL: URL(string: ProcessInfo.processInfo.environment["BASE_URL"]!)!
        )
    )
    // Если BASE_URL не задан - force unwrap в init, весь класс пропускается

    func testCreateUser() async throws { /* ... */ }
}

// ❌ BAD: Сложная логика в init
class DatabaseTests: XCTestCase {
    let database: Database

    override init() {
        database = try! Database.connect(to: "test.db")  // Может упасть
        super.init()
    }
}
```

## Good Example

```swift
// ✅ GOOD: Инициализация в setUp
class APITests: XCTestCase {
    var apiClient: APIClient!

    override func setUp() async throws {
        try await super.setUp()

        let baseURLString = ProcessInfo.processInfo.environment["BASE_URL"] ?? "http://localhost:8080"
        guard let baseURL = URL(string: baseURLString) else {
            XCTFail("Invalid BASE_URL: \(baseURLString)")
            return
        }

        apiClient = APIClient(
            configuration: APIConfiguration(baseURL: baseURL)
        )
    }

    override func tearDown() async throws {
        apiClient = nil
        try await super.tearDown()
    }

    func testCreateUser() async throws { /* ... */ }
}
```

## Why

- `setUp()` запускается после успешной инициализации класса
- Ошибки setup изолированы от класса и дают чёткую диагностику
- Cleanup гарантирован через `tearDown()`
- Force unwrap в property declaration падает без понятного сообщения

## Detection

```bash
# Property init с force unwrap в тестах
grep -rn "let .* = .*!" --include="*Tests.swift" Tests/ | grep -v "IBOutlet\|XCTUnwrap"
# Force try в тестовых классах (не в тестовых методах)
grep -rn "try!" --include="*Tests.swift" Tests/
```

## References

- (ref: platform/xctest-setup-crashes.md)
- Apple: XCTestCase lifecycle
