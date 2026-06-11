import SwiftUI

/// A user-added quote. Persisted as a JSON array string under
/// `local:quote-widget-custom-quotes-json` so it rides the existing
/// getSettings bridge into the extension unchanged.
struct CustomQuote: Codable, Identifiable, Equatable {
    var id = UUID()
    var text: String
    var attribution: String

    enum CodingKeys: String, CodingKey {
        case text, attribution
    }
}

enum QuoteWidget {
    static let enabledKey = "local:quote-widget-enabled"
    static let rotationKey = "local:quote-widget-rotation-policy"
    static let customQuotesKey = "local:quote-widget-custom-quotes-json"

    /// (storage value, UI label) — order matters for the picker.
    static let rotationOptions: [(value: String, label: String)] = [
        ("page-load", "Every Page Load"),
        ("session", "Per Browsing Session"),
        ("day", "Daily"),
    ]

    static func seedDefaults() {
        let store = SharedDefaults.store
        if store.object(forKey: enabledKey) == nil { store.set(true, forKey: enabledKey) }
        if store.string(forKey: rotationKey) == nil { store.set("page-load", forKey: rotationKey) }
        if store.string(forKey: customQuotesKey) == nil { store.set("[]", forKey: customQuotesKey) }
    }

    static func loadCustomQuotes() -> [CustomQuote] {
        guard let data = (SharedDefaults.store.string(forKey: customQuotesKey) ?? "[]").data(using: .utf8),
              let quotes = try? JSONDecoder().decode([CustomQuote].self, from: data) else { return [] }
        return quotes
    }

    static func saveCustomQuotes(_ quotes: [CustomQuote]) {
        guard let data = try? JSONEncoder().encode(quotes),
              let json = String(data: data, encoding: .utf8) else { return }
        SharedDefaults.store.set(json, forKey: customQuotesKey)
    }

    static var enabledBinding: Binding<Bool> {
        Binding(get: { SharedDefaults.store.bool(forKey: enabledKey) },
                set: { SharedDefaults.store.set($0, forKey: enabledKey) })
    }

    static var rotationBinding: Binding<String> {
        Binding(get: { SharedDefaults.store.string(forKey: rotationKey) ?? "page-load" },
                set: { SharedDefaults.store.set($0, forKey: rotationKey) })
    }
}
