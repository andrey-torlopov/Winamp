# No Abstraction Layer

## Why this is bad

URLSession/URLRequest напрямую в тестах:
- При смене URL нужно править десятки тестов
- Дублирование кода настройки запросов
- Сложно добавить логирование/retry/auth
- Тесты знают слишком много о реализации API

## Bad Example

```swift
// ❌ BAD: Raw URLSession напрямую в каждом тесте
func testUserCanRegister() async throws {
    var request = URLRequest(url: URL(string: "https://api.example.com/api/v1/users/register")!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("secret-key", forHTTPHeaderField: "X-Api-Key")
    request.httpBody = try JSONEncoder().encode(payload)

    let (data, response) = try await URLSession.shared.data(for: request)
    let httpResponse = response as! HTTPURLResponse
    XCTAssertEqual(httpResponse.statusCode, 201)
}

func testRegistrationFailsWithInvalidEmail() async throws {
    // Тот же boilerplate снова...
    var request = URLRequest(url: URL(string: "https://api.example.com/api/v1/users/register")!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("secret-key", forHTTPHeaderField: "X-Api-Key")
    request.httpBody = try JSONEncoder().encode(invalidPayload)
}
```

## Good Example

```swift
// ✅ GOOD: APIClient инкапсулирует HTTP
struct APIClient {
    let baseURL: URL
    let session: URLSession

    func register(_ request: RegisterRequest) async throws -> APIResponse<UserResponse> {
        try await execute(.post, path: Endpoints.register, body: request)
    }
}

// Тесты чистые и читаемые
func testUserCanRegister() async throws {
    let response = try await apiClient.register(TestData.validRegistration())
    XCTAssertEqual(response.statusCode, 201, "Registration should succeed with valid payload")
}
```

## What to look for in code review

- `URLSession.shared.data(for:)` напрямую в тестовых методах
- Дублирование URL, headers, httpMethod
- Ручное создание `URLRequest` в каждом тесте
- Хардкод URL в тестах (`"https://..."`)
- `JSONEncoder().encode()` / `JSONDecoder().decode()` в каждом тесте вместо общего APIClient
