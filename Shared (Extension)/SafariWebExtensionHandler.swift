import SafariServices

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    func beginRequest(with context: NSExtensionContext) {
        let request = context.inputItems.first as? NSExtensionItem
        let message = (request?.userInfo as? [String: Any])?["message"] ?? request?.userInfo?[SFExtensionMessageKey]
        let settings = UserDefaults.standard.dictionaryRepresentation().filter { $0.key.hasPrefix("local:") }

        let response = NSExtensionItem()
        response.userInfo = ["message": ["echo": message, "settings": settings]]
        context.completeRequest(returningItems: [response])
    }
}
