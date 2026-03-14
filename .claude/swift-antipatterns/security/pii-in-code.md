# Anti-Pattern: PII в коде и тестовых данных

**Applies to:** Тесты, Previews, Mock-данные

## Problem

Персональные данные (реальные или "реалистичные") в коде:
- Код попадает в Git - утечка PII при публикации репозитория
- SwiftUI Previews с реальными данными видны на скриншотах
- Нарушение GDPR / 152-ФЗ при аудите кодовой базы
- "Тестовый аккаунт Васи" - это все ещё PII

## Bad Example

```swift
// ❌ BAD: реальные домены и форматы
enum TestData {
    static func validRequest() -> RegisterRequest {
        RegisterRequest(
            email: "ivan.petrov@gmail.com",      // реальный домен
            phone: "+79161234567",                // реальный формат
            fullName: "Петров Иван Сергеевич"    // похоже на реального человека
        )
    }
}

let testEmail = "vasya.dev@company.com"   // PII коллеги
let testPhone = "+79031112233"             // чей-то номер

// ❌ BAD: PII в SwiftUI Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: User(
            name: "Мария Иванова",
            email: "m.ivanova@gmail.com",
            phone: "+79161234567"
        ))
    }
}
```

## Good Example

```swift
// ✅ GOOD: RFC 2606 + явно невалидные форматы
enum TestData {
    static func validRequest() -> RegisterRequest {
        let suffix = Int(Date().timeIntervalSince1970)
        return RegisterRequest(
            email: "auto_\(suffix)@example.com",   // RFC 2606
            phone: "+70000000000",                   // явно тестовый (нули)
            fullName: "Test User \(UUID().uuidString.prefix(4))"
        )
    }
}

// ✅ GOOD: Safe Preview данные
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: User(
            name: "Test User",
            email: "preview@example.com",
            phone: "+70000000000"
        ))
    }
}

// ✅ GOOD: Mock namespace для preview/тестовых данных
extension User {
    enum Mock {
        static let standard = User(
            name: "Test User",
            email: "test@example.com",
            phone: "+70000000000"
        )

        static let empty = User(name: "", email: "", phone: "")
    }
}
```

## Safe Patterns

| Тип | Безопасно | Запрещено |
|-----|-----------|-----------|
| Email | `@example.com`, `@example.org` (RFC 2606) | `@gmail.com`, `@yandex.ru`, `@company.com` |
| Phone | `+70000000000`, `+79999999999` | `+7916...`, `+7903...` |
| Name | `Test User`, `QA Bot`, `Auto Test 123` | ФИО в формате "Фамилия Имя Отчество" |
| Card | ссылки на тестовые карты из docs платежной системы | любые 16-значные числа без ссылки |
| Address | `123 Test Street, City 00000` | реальные адреса |

## Detection

```bash
grep -rn "@gmail\.com\|@yandex\.ru\|@mail\.ru" --include="*.swift" Sources/ Tests/
grep -rn "+7916\|+7903\|+7925\|+7926" --include="*.swift" Sources/ Tests/
```

## References

- (ref: security/pii-in-code.md)
- RFC 2606: Reserved Example Domains
