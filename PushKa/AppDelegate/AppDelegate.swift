import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    // Метод вызывается при запуске приложения
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self // Устанавливаем делегат для уведомлений
        
        // Запрос разрешения на отправку уведомлений
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { isOn, _ in
            print("уведомления включены: \(isOn)")
            guard isOn else { return }
        }
        
        // Регистрация на получение удалённых уведомлений
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // Вызывается, когда устройство успешно зарегистрировано на APNs
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Передаём APNs токен в Firebase
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // Обработка Data Payload (если используется). вызывается, когда устройство получает data-payload от удалённого уведомления
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Получены данные: \(userInfo)")
        NotificationCenter.default.post(name: Notification.Name("didReceiveRemoteNotification"), object: nil, userInfo: userInfo)
        completionHandler(.newData)
    }
}

extension AppDelegate: MessagingDelegate, UNUserNotificationCenterDelegate {
    // Получение FCM токена устройства
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            FCMManager.shared.setToken(token)
            print("FCM Token: \(token)")
        }
    }
    
    // Обработка уведомлений, когда приложение активно (foreground)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }
    
    // Обработка взаимодействия пользователя с уведомлением
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Достаём данные из уведомления
        let userInfo = response.notification.request.content.userInfo
        
        // Отправляем уведомление внутри приложения через NotificationCenter
        NotificationCenter.default.post(name: Notification.Name("didReceiveRemoteNotification"), object: nil, userInfo: userInfo)
        completionHandler()
    }
}
