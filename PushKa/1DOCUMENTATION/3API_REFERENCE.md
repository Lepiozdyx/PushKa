# 📚 API Reference

## 🏗️ Основные классы

### FCMManager

**Назначение:** Singleton для управления FCM токенами

```swift
class FCMManager: ObservableObject {
    static let shared = FCMManager()
    @Published private(set) var fcmToken: String?
}
```

**Методы:**

#### `setToken(_ token: String)`
Устанавливает FCM токен и оповещает ожидающие continuation'ы.

```swift
FCMManager.shared.setToken("new_fcm_token")
```

#### `waitForToken() async -> String`
Асинхронно ждет получения FCM токена.

```swift
let token = await FCMManager.shared.waitForToken()
print("Получен токен: \(token)")
```

---

### NetworkManager

**Назначение:** Управление сетевыми запросами и конфигурацией сервера

```swift
class NetworkManager: ObservableObject {
    static let BASE_URL = "https://yourserver.com/endpoint"
    @Published private(set) var targetURL: URL?
}
```

**Статические методы:**

#### `getInitialURL(fcmToken: String) -> URL`
Создает URL с FCM токеном для отправки на сервер.

```swift
let url = NetworkManager.getInitialURL(fcmToken: "token123")
// Результат: https://yourserver.com/endpoint?fcm=token123
```

#### `isInitialURL(_ url: URL) -> Bool`
Проверяет, является ли URL начальным серверным URL.

```swift
let isInitial = NetworkManager.isInitialURL(someURL)
```

**Методы экземпляра:**

#### `checkInitialURL() async throws -> Bool`
Отправляет FCM токен на сервер и проверяет ответ.

```swift
let success = try await networkManager.checkInitialURL()
if success {
    print("Сервер ответил успешно")
}
```

#### `checkURL(_ url: URL)`
Сохраняет URL если он не является невалидным.

```swift
networkManager.checkURL(someValidURL)
```

#### `getUAgent(forWebView: Bool = false) -> String`
Возвращает User-Agent строку для запросов.

```swift
let webAgent = networkManager.getUAgent(forWebView: true)
let apiAgent = networkManager.getUAgent(forWebView: false)
```

---

### AppStateManager

**Назначение:** Управление состояниями приложения

```swift
@MainActor
final class AppStateManager: ObservableObject {
    enum AppState {
        case fetch  // Запрос
        case supp   // WebView
        case final  // Контент (прила)
    }
    
    @Published private(set) var appState: AppState = .fetch
}
```

**Методы:**

#### `stateCheck()`
Запускает проверку состояния и определяет следующий экран.

```swift
appStateManager.stateCheck()
```

**Логика работы:**
1. Проверяет наличие сохраненного URL
2. Если нет - отправляет FCM токен на сервер
3. На основе ответа сервера переключает состояние

---

## 🔔 NotificationService Extension

### NotificationService

**Назначение:** Обработка Rich Push Notifications с изображениями

**Ключевые методы:**

#### `didReceive(_ request:withContentHandler:)`
Основной метод обработки входящих уведомлений.

```swift
override func didReceive(_ request: UNNotificationRequest,
                        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void)
```

#### `extractImageURL(from userInfo:) -> URL?`
Извлекает URL изображения из payload уведомления.

**Поддерживаемые форматы payload:**

```json
// Вариант 1: FCM format
{
  "fcm_options": {
    "image": "https://example.com/image.jpg"
  }
}

// Вариант 2: Custom field
{
  "image": "https://example.com/image.jpg"
}

// Вариант 3: Attachment URL
{
  "attachment-url": "https://example.com/image.jpg"
}
```

#### `downloadImage(from:completion:)`
Скачивает изображение и создает UNNotificationAttachment.

**Ограничения:**
- Максимальный размер: 10MB
- Поддерживаемые форматы: JPG, PNG, GIF, WebP
- Таймаут: 30 секунд (системное ограничение)

---

## 🌐 WebView интеграция

### WebViewManager

**Назначение:** UIViewRepresentable для отображения веб-контента

```swift
struct WebViewManager: UIViewRepresentable {
    let url: URL
    let webManager: NetworkManager
}
```

**Особенности:**
- Автоматическая настройка WKWebView
- Кастомный User-Agent для веб-запросов
- Отслеживание навигации и сохранение URL
- Поддержка JavaScript и медиа контента

**Автоматические настройки:**
```swift
configuration.allowsInlineMediaPlayback = true
configuration.mediaTypesRequiringUserActionForPlayback = []
preferences.allowsContentJavaScript = true
webView.allowsBackForwardNavigationGestures = true
```

---

## 📱 AppDelegate интеграция

### Методы делегата

#### Firebase Messaging

```swift
func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    // Получение нового FCM токена
}
```

#### Remote Notifications

```swift
func application(_ application: UIApplication,
                didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Получение APNs токена
}

func application(_ application: UIApplication,
                didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    // Обработка background push
}
```

#### User Notifications

```swift
func userNotificationCenter(_ center: UNUserNotificationCenter,
                           willPresent notification: UNNotification,
                           withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    // Показ уведомлений в foreground
}

func userNotificationCenter(_ center: UNUserNotificationCenter,
                           didReceive response: UNNotificationResponse,
                           withCompletionHandler completionHandler: @escaping () -> Void) {
    // Обработка нажатий на уведомления
}
```

---

## 🔧 Utility функции

### URL валидация

**Невалидные URL:**
- `about:blank`
- `about:srcdoc`
- Любые URL с хостом содержащим `google.com`

### Таймауты

- **Network запросы:** 10 секунд
- **App loading timeout:** 15 секунд
- **Rich Push processing:** 30 секунд (системное ограничение)

---

## 🚀 Расширения и кастомизация

### Добавление параметров в запрос

```swift
static func getInitialURL(fcmToken: String) -> URL {
    // ... existing code ...
    
    // Добавить кастомные параметры
    queryItems.append(URLQueryItem(name: "app_version", value: appVersion))
    queryItems.append(URLQueryItem(name: "user_id", value: userId))
    
    // ... rest of code ...
}
```

### Кастомная обработка push

```swift
private func handlePushNotification(_ userInfo: [AnyHashable: Any]) {
    // Извлечь кастомные данные
    if let screen = userInfo["target_screen"] as? String {
        navigateToScreen(screen)
    }
    
    // Стандартная обработка
    NotificationCenter.default.post(...)
}
```
