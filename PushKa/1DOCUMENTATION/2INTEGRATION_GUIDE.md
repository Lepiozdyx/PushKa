# 🔧 Руководство по интеграции PushKa

## 🎯 Полная интеграция в новый проект

### Шаг 1: Создание Notification Service Extension

1. **File → New → Target...**
2. Выберите **"Notification Service Extension"**
3. **Product Name**: `NotificationService`
4. **Bundle Identifier**: автоматически станет `com.yourappbundle.NotificationService`
5. Нажмите **"Finish"**
6. Когда появится диалог **"Activate scheme?"** → выберите **"Cancel"**

### Шаг 2: Настройка Extension

1. Замените содержимое `NotificationService.swift` кодом из PushKa
2. Убедитесь, что Extension добавлен в **Embed Foundation Extensions**:
   - Target → **Build Phases** → **Embed Foundation Extensions**
   - Там должен быть `NotificationService.appex`

### Шаг 3: Firebase Dependencies

**Для основного Target:**
1. Проект → **Package Dependencies** → **"+"**
2. URL: `https://github.com/firebase/firebase-ios-sdk.git`
3. Выберите **"FirebaseMessaging"**

### Шаг 4: Проверка настроек

**Main App Target:**
- ✅ Push Notifications capability включен
- ✅ Background Modes → Remote notifications включен
- ✅ FirebaseMessaging добавлен в зависимости
- ✅ GoogleService-Info.plist добавлен в Target

**NotificationService Target:**
- ✅ Extension встроен в основное приложение
- ✅ Bundle ID правильный (com.yourapp.NotificationService)

---

## 🔄 Интеграция в существующий проект

### Если у вас SwiftUI без AppDelegate - создайте, а затем добавьте файл `AppDelegate.swift` с кодом выше.

### Простая настройка

В `NetworkManager.swift` измените одну строку:

```swift
static let BASE_URL = "https://your-server.com/api/fcm-tokens"
```

**Как сервер получит запрос:**
```
GET https://your-server.com/api/fcm-tokens?fcm=ACTUAL_FCM_TOKEN
```
