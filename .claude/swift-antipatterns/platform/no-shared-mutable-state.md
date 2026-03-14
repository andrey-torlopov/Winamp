# No Shared Mutable State

**Applies to:** Тесты, многопоточный код

## Why this is bad

Разделяемое mutable состояние между тестами или потоками:
- Тесты зависят от порядка выполнения
- Параллельный запуск ломает всё
- Data race при concurrent доступе
- Падение одного теста каскадно ломает следующие

## Bad Example

```swift
// ❌ BAD: Static var в тестовом классе - тесты зависят друг от друга
class UserTests: XCTestCase {
    static var createdUserId: String = ""

    override class func setUp() {
        super.setUp()
        createdUserId = createUser()
    }

    func testUpdateUser() async throws {
        let response = try await apiClient.updateUser(Self.createdUserId, newData)
        XCTAssertEqual(response.statusCode, 200, "Update should succeed")
    }

    func testDeleteUser() async throws {
        let response = try await apiClient.deleteUser(Self.createdUserId)
        XCTAssertEqual(response.statusCode, 204, "Delete should succeed")
        // После delete - testUpdateUser сломается
    }
}

// ❌ BAD: Shared mutable state в production коде без синхронизации
class UserCache {
    var users: [String: User] = [:]  // Data race при concurrent доступе

    func getUser(_ id: String) -> User? {
        users[id]  // Чтение без синхронизации
    }

    func setUser(_ user: User) {
        users[user.id] = user  // Запись без синхронизации
    }
}
```

## Good Example

```swift
// ✅ GOOD: Каждый тест создает свои данные
class UserTests: XCTestCase {
    func testUpdateUser() async throws {
        let userId = try await UserHelper.createUser(TestData.validCreateBody())

        let response = try await apiClient.updateUser(userId, TestData.validUpdateBody())
        XCTAssertEqual(response.statusCode, 200, "Update should succeed")
    }

    func testDeleteUser() async throws {
        let userId = try await UserHelper.createUser(TestData.validCreateBody())

        let response = try await apiClient.deleteUser(userId)
        XCTAssertEqual(response.statusCode, 204, "Delete should succeed")
    }
}

// ✅ GOOD: Actor для thread-safe shared state
actor UserCache {
    private var users: [String: User] = [:]

    func getUser(_ id: String) -> User? {
        users[id]
    }

    func setUser(_ user: User) {
        users[user.id] = user
    }
}

// ✅ GOOD: Sendable struct для immutable shared data
struct AppConfig: Sendable {
    let baseURL: URL
    let apiKey: String
    let timeout: TimeInterval
}
```

## What to look for in code review

- `static var` в XCTestCase (кроме lazy конфигурации)
- Тест A создает данные, тест B использует их
- `var` properties в классах без `actor` или синхронизации
- Отсутствие `Sendable` conformance для типов, передаваемых между потоками
- `@unchecked Sendable` без обоснования
- `DispatchQueue` для синхронизации вместо `actor` (legacy)
