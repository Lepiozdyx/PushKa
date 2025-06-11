# 🔔 PushKa

> **Готовое решение для интеграции Firebase Cloud Messaging с Rich Push Notifications**

## 🚀 Быстрый старт

### 1. Настройка Firebase

#### Создание проекта
1. Откройте [Firebase Console](https://console.firebase.google.com/)
2. Создайте новый проект или выберите существующий
3. Добавьте iOS приложение с вашим Bundle ID
4. Скачайте `GoogleService-Info.plist` и замените одноименный файл в проекте на свой

#### Настройка в Xcode
1. **Push Notifications:**
   - Target → **"Signing & Capabilities"** → **"+ Capability"** → **"Push Notifications"**

2. **Background Modes:**
   - Target → **"Signing & Capabilities"** → **"+ Capability"** → **"Background Modes"**
   - Поставьте галочку **"Remote notifications"**

3. **App Transport Security** (если нужен HTTP):
   - Откройте **Info.plist** → правый клик → **"Add Row"**
   - Добавьте: **"App Transport Security Settings"** (Dictionary)
   - Внутри добавьте: **"Allow Arbitrary Loads"** (Boolean: YES)

### 2. Конфигурация сервера (1 минута)

Откройте `NetworkManager.swift` и измените URL на "боевой":

```swift
static let BASE_URL = "https://yourserver.com/endpoint" // ← ИЗМЕНИТЬ ЗДЕСЬ
```

**Готово!** Приложение будет отправлять FCM токены на сервер.

---

## 📱 Тестирование

### ⚠️ ВАЖНО: Rich Push (изображения) работают ТОЛЬКО на реальных устройствах!

### Отправка тестового push через Firebase Console:
1. Firebase Console → **Cloud Messaging** → **"Send your first message"**
2. Найдите FCM токен в консоли Xcode: `🔥 FCM Token received: [токен]`
3. Вставьте токен в поле "FCM registration token"

---

## 🏗️ Архитектура проекта

```
📁 PushKa/
├── 📁 App/
│   └── PushKaApp.swift              # Точка входа
├── 📁 AppDelegate/
│   └── AppDelegate.swift            # Firebase + Push настройка
├── 📁 Managers/
│   ├── AppStateManager.swift        # Состояния приложения
│   ├── FCMManager.swift             # FCM токены
│   └── NetworkManager.swift         # Конфигурация сервера
├── 📁 Views/
│   ├── RootView.swift              # Главный роутер
│   ├── LoadingView.swift           # Экран загрузки
│   └── ContentView.swift           # Основной контент (прила)
└── 📁 NotificationService/          # Rich Push Extension
    └── NotificationService.swift    # Обработка изображений
```

---

## 🔧 Интеграция в существующий проект

### Минимальные файлы для копирования:
- ✅ `FCMManager.swift`
- ✅ `NetworkManager.swift` (измените BASE_URL)
- ✅ `NotificationService/` (создайте Extension)
- ✅ Ваш `GoogleService-Info.plist`

---

## 📖 Подробная документация

- 📄 `INTEGRATION_GUIDE.md` - Подробная интеграция
- 📄 `API_REFERENCE.md` - Справочник по API

---
