# No Order-Dependent Tests

**Applies to:** Unit-тесты, Integration-тесты

## Why this is bad

Тесты, зависящие от порядка выполнения:
- XCTest не гарантирует порядок по умолчанию (рандомизация в Xcode)
- Параллельный запуск невозможен
- Один упавший тест каскадно ломает все следующие

## Bad Example

```swift
// ❌ BAD: Тесты зависят от порядка - delete не работает без create
class UserTests: XCTestCase {
    static var userId: String = ""

    func test1_createUser() async throws {
        let response = try await apiClient.createUser(TestData.validCreateBody())
        Self.userId = response.body.id
    }

    func test2_getUser() async throws {
        let response = try await apiClient.getUser(Self.userId)
        XCTAssertEqual(response.statusCode, 200, "Get user should return 200")
    }

    func test3_deleteUser() async throws {
        let response = try await apiClient.deleteUser(Self.userId)
        XCTAssertEqual(response.statusCode, 204, "Delete should return 204")
    }
}
```

## Good Example

```swift
// ✅ GOOD: Каждый тест полностью автономен
class UserTests: XCTestCase {

    func testGetUserById() async throws {
        let userId = try await UserHelper.createUser(TestData.validCreateBody())

        let response = try await apiClient.getUser(userId)
        XCTAssertEqual(response.statusCode, 200, "Get user should return 200")
    }

    func testDeleteUser() async throws {
        let userId = try await UserHelper.createUser(TestData.validCreateBody())

        let response = try await apiClient.deleteUser(userId)
        XCTAssertEqual(response.statusCode, 204, "Delete should return 204")
    }
}
```

## What to look for in code review

- Методы с нумерацией `test1_`, `test2_`, `test3_`
- `static var` в XCTestCase, заполняемый в одном тесте
- Тесты, которые падают при запуске поодиночке
- Комментарии типа "run after test X"
- Отключенная рандомизация тестов в схеме Xcode
