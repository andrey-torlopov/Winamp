# Swift/iOS Anti-Patterns Index

> **Адаптировано из:** QA Anti-Patterns (Kotlin/JUnit) -> Swift/iOS (XCTest, async/await, URLSession)

> **Lazy Load Protocol:** Читай файл ТОЛЬКО при обнаружении нарушения.
> Превентивная загрузка всех файлов ЗАПРЕЩЕНА (Token Economy).

## Naming Convention

`{category}/{problem-name}.md` - описание проблемы и Good Example.

## Available Patterns

### common/ - Базовая гигиена кода

| Файл | Проблема |
|------|----------|
| `common/assertion-without-message.md` | XCTAssert без message |
| `common/hardcoded-test-data.md` | Hardcoded данные в тестах |
| `common/no-abstraction-layer.md` | Прямые URLSession-вызовы в тестах |
| `common/static-test-data.md` | Статичные тестовые данные без рандомизации |
| `common/no-order-dependent-tests.md` | Тесты зависят друг от друга |
| `common/no-cleanup-pattern.md` | Нет cleanup после тестов |

### networking/ - Специфика HTTP и URLSession

| Файл | Проблема |
|------|----------|
| `networking/dictionary-instead-of-model.md` | `[String: Any]` вместо Codable |
| `networking/missing-content-type-validation.md` | Content-Type не валидируется |
| `networking/configure-urlsession.md` | URLSession не настроен (дефолтные таймауты) |
| `networking/wrap-infrastructure-errors.md` | URLError не отличим от бизнес-ошибки |
| `networking/inline-urlsession-calls.md` | URLSession.shared inline в коде |
| `networking/missing-security-headers.md` | Нет проверки security headers |
| `networking/missing-error-body-check.md` | Проверка только HTTP-кода без бизнес-ошибки |

### platform/ - Swift Concurrency + XCTest

| Файл | Проблема |
|------|----------|
| `platform/async-test-pitfalls.md` | `Task {}` в sync тестах, legacy XCTestExpectation для async |
| `platform/xctest-setup-crashes.md` | Force unwrap / try! в property init XCTestCase |
| `platform/flaky-sleep-tests.md` | `Thread.sleep()` / `Task.sleep()` вместо polling |
| `platform/no-hardcoded-timeouts.md` | Magic numbers в таймаутах |
| `platform/no-shared-mutable-state.md` | Shared mutable state, отсутствие actor/Sendable |
| `platform/controlled-retries.md` | Неконтролируемая retry-логика |

### security/ - Данные и безопасность

| Файл | Проблема |
|------|----------|
| `security/no-sensitive-data-logging.md` | PII в логах, print(), os_log |
| `security/information-leakage-in-errors.md` | Утечка данных через error.localizedDescription |
| `security/pii-in-code.md` | PII в тестах, Previews и Mock-данных |

## Маппинг QA (Kotlin) -> Swift

| QA (Kotlin/JUnit) | Swift/iOS | Изменения |
|---|---|---|
| `HttpClient` / Ktor | `URLSession` / `URLRequest` | API полностью другой |
| `@Test` / JUnit 5 | `func test*()` / XCTest | Lifecycle: `setUp()`/`tearDown()` вместо `@BeforeEach`/`@AfterEach` |
| `runBlocking {}` | `async throws` test methods | Нативная поддержка в Xcode 13+ |
| `Awaitility` | `XCTestExpectation` / custom polling | Нет прямого аналога, нужен helper |
| `@Serializable` (Kotlin) | `Codable` (Swift) | `CodingKeys` вместо `@SerialName` |
| `companion object` | `static` properties | `actor` для thread-safe state |
| `lateinit var` | `var ... : T!` в XCTestCase | Опасен при init crash |
| Allure steps | `XCTContext.runActivity` | Менее развит, но аналогичен |
| `@BeforeAll` | `override class func setUp()` | Вызывается один раз для класса |

## Usage (для разработчика)

При обнаружении проблемы в коде:
1. Определи категорию: common / networking / platform / security
2. Прочитай `swift-antipatterns/{category}/{name}.md` - примени Good Example - процитируй `(ref: {category}/{name}.md)`
3. Если reference не найден - BLOCKER, не угадывай fix

## Usage (для code review)

```bash
# Сканируй по категории
ls swift-antipatterns/networking/

# Grep в проекте
grep -rn "URLSession.shared\|[String: Any]\|Thread.sleep" --include="*.swift" Sources/ Tests/

# Прочитай файл при match
cat swift-antipatterns/networking/inline-urlsession-calls.md
```
