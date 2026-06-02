import SafariServices

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    func beginRequest(with context: NSExtensionContext) {
        let request = context.inputItems.first as? NSExtensionItem
        let userInfo = request?.userInfo as? [String: Any]
        let message = userInfo?["message"] as? [String: Any]
        let action = message?["action"] as? String

        var responsePayload: [String: Any]
        let store = UserDefaults(suiteName: "group.com.mattwagner.feedless-safari") ?? .standard
        let settings = store.dictionaryRepresentation()
            .filter { $0.key.hasPrefix("local:") }

        if action == "getSettings" {
            responsePayload = ["settings": settings]
        } else {
            responsePayload = ["echo": message ?? "no-message", "settings": settings]
        }

        let response = NSExtensionItem()
        response.userInfo = ["message": responsePayload]
        context.completeRequest(returningItems: [response])
    }
}
