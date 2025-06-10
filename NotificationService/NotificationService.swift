import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent,
           let attachmentURL = bestAttemptContent.userInfo["fcm_options"] as? [String: Any],
           let imageURLString = attachmentURL["image"] as? String,
           let imageURL = URL(string: imageURLString) {
            downloadImage(from: imageURL) { attachment in
                if let attachment = attachment {
                    bestAttemptContent.attachments = [attachment]
                }
                contentHandler(bestAttemptContent)
            }
        } else {
            contentHandler(bestAttemptContent!)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    private func downloadImage(from url: URL, completion: @escaping (UNNotificationAttachment?) -> Void) {
        URLSession.shared.downloadTask(with: url) { location, response, error in
            guard let location = location else {
                completion(nil)
                return
            }
            
            let tmpDirectory = FileManager.default.temporaryDirectory
            let tmpFile = tmpDirectory.appendingPathComponent(url.lastPathComponent)
            
            do {
                try FileManager.default.moveItem(at: location, to: tmpFile)
                let attachment = try UNNotificationAttachment(identifier: "image", url: tmpFile, options: nil)
                completion(attachment)
            } catch {
                completion(nil)
            }
        }.resume()
    }
}
