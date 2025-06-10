import UserNotifications
import UniformTypeIdentifiers

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        print("🔥 NotificationService STARTED!")
        print("📋 UserInfo: \(request.content.userInfo)")
        
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent = bestAttemptContent else {
            contentHandler(request.content)
            return
        }
        
        // Попытка извлечь URL изображения из разных источников
        if let imageURL = extractImageURL(from: bestAttemptContent.userInfo) {
            downloadImage(from: imageURL) { attachment in
                if let attachment = attachment {
                    bestAttemptContent.attachments = [attachment]
                }
                contentHandler(bestAttemptContent)
            }
        } else {
            // Если изображения нет, просто отправляем уведомление как есть
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Вызывается когда время на обработку истекает (30 секунд)
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    // MARK: - Private Methods
    
    private func extractImageURL(from userInfo: [AnyHashable: Any]) -> URL? {
        // Способ 1: Firebase FCM формат
        if let fcmOptions = userInfo["fcm_options"] as? [String: Any],
           let imageURLString = fcmOptions["image"] as? String,
           let imageURL = URL(string: imageURLString) {
            return imageURL
        }
        
        // Способ 2: Прямо в aps
        if let aps = userInfo["aps"] as? [String: Any],
           let imageURLString = aps["mutable-content"] as? String,
           let imageURL = URL(string: imageURLString) {
            return imageURL
        }
        
        // Способ 3: Кастомное поле
        if let imageURLString = userInfo["image"] as? String,
           let imageURL = URL(string: imageURLString) {
            return imageURL
        }
        
        // Способ 4: Attachment URL
        if let imageURLString = userInfo["attachment-url"] as? String,
           let imageURL = URL(string: imageURLString) {
            return imageURL
        }
        
        return nil
    }
    
    private func downloadImage(from url: URL, completion: @escaping (UNNotificationAttachment?) -> Void) {
        let session = URLSession(configuration: .default)
        
        session.downloadTask(with: url) { [weak self] location, response, error in
            defer {
                session.invalidateAndCancel()
            }
            
            guard let self = self,
                  error == nil,
                  let location = location,
                  let response = response else {
                print("❌ NotificationService: Download failed - \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            // Проверяем размер файла (максимум 10MB для изображений)
            if response.expectedContentLength > 10 * 1024 * 1024 {
                print("❌ NotificationService: File too large: \(response.expectedContentLength) bytes")
                completion(nil)
                return
            }
            
            let tmpDirectory = FileManager.default.temporaryDirectory
            let fileExtension = self.getFileExtension(from: url, response: response)
            let tmpFile = tmpDirectory.appendingPathComponent("notification_image.\(fileExtension)")
            
            do {
                // Удаляем файл если он уже существует
                if FileManager.default.fileExists(atPath: tmpFile.path) {
                    try FileManager.default.removeItem(at: tmpFile)
                }
                
                try FileManager.default.moveItem(at: location, to: tmpFile)
                
                // Определяем тип контента
                let typeIdentifier = self.getTypeIdentifier(for: fileExtension)
                
                let attachment = try UNNotificationAttachment(
                    identifier: "notification_image",
                    url: tmpFile,
                    options: [
                        UNNotificationAttachmentOptionsTypeHintKey: typeIdentifier
                    ]
                )
                
                print("✅ NotificationService: Image attached successfully")
                completion(attachment)
                
            } catch {
                print("❌ NotificationService: Failed to create attachment - \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
    
    private func getFileExtension(from url: URL, response: URLResponse) -> String {
        // Сначала пробуем получить расширение из URL
        let urlExtension = url.pathExtension.lowercased()
        if !urlExtension.isEmpty && isValidImageExtension(urlExtension) {
            return urlExtension
        }
        
        // Затем из MIME type
        if let mimeType = response.mimeType {
            switch mimeType.lowercased() {
            case "image/jpeg":
                return "jpg"
            case "image/png":
                return "png"
            case "image/gif":
                return "gif"
            case "image/webp":
                return "webp"
            default:
                break
            }
        }
        
        // По умолчанию
        return "jpg"
    }
    
    private func isValidImageExtension(_ fileExtension: String) -> Bool {
        let validExtensions = ["jpg", "jpeg", "png", "gif", "webp"]
        return validExtensions.contains(fileExtension.lowercased())
    }
    
    private func getTypeIdentifier(for fileExtension: String) -> String {
        switch fileExtension.lowercased() {
        case "jpg", "jpeg":
            return UTType.jpeg.identifier
        case "png":
            return UTType.png.identifier
        case "gif":
            return UTType.gif.identifier
        case "webp":
            return "org.webmproject.webp"
        default:
            return UTType.jpeg.identifier
        }
    }
}
