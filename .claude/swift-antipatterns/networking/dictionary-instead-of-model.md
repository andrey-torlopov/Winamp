# Dictionary Instead of Codable Model

## Why this is bad

Использование `[String: Any]` вместо типизированных Codable-моделей:
- Компилятор не ловит опечатки в названиях полей
- Нет автодополнения в IDE
- При рефакторинге API нужно искать строки по всему проекту
- Невозможно понять структуру данных без документации
- Теряется type safety - одно из главных преимуществ Swift

## Bad Example

```swift
// ❌ BAD: Dictionary - компилятор не поможет
func register() async throws {
    let payload: [String: Any] = [
        "email": "test@example.com",
        "phone": "+79991234567",
        "pasword": "Test123!",   // Опечатка! Компилятор молчит
        "full_name": "Test User"
    ]

    let data = try JSONSerialization.data(withJSONObject: payload)
    var request = URLRequest(url: registerURL)
    request.httpBody = data
    // ...
}
```

## Good Example

```swift
// ✅ GOOD: Codable struct с CodingKeys
struct RegisterRequest: Codable, Sendable {
    let email: String
    let phone: String
    let password: String   // Опечатка = ошибка компиляции
    let fullName: String

    enum CodingKeys: String, CodingKey {
        case email, phone, password
        case fullName = "full_name"
    }
}

func register() async throws {
    let payload = RegisterRequest(
        email: "test@example.com",
        phone: "+79991234567",
        password: "Test123!",    // IDE подсказывает
        fullName: "Test User"
    )

    let response = try await apiClient.register(payload)
}
```

## What to look for in code review

- `[String: Any]`, `[String: String]` для request/response body
- `JSONSerialization.data(withJSONObject:)` вместо `JSONEncoder().encode()`
- JSON-строки собранные через string interpolation
- Отсутствие Codable-моделей в папке `Models/` или `DTOs/`
- Приведение типов через `as? String`, `as? Int` при парсинге ответа
