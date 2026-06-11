import SwiftUI

extension SharedDefaults {
    static func boolBinding(forKey key: String) -> Binding<Bool> {
        Binding(get: { store.bool(forKey: key) },
                set: { store.set($0, forKey: key) })
    }

    static func stringBinding(forKey key: String, default defaultValue: String, allowed: [String]) -> Binding<String> {
        Binding(get: {
            guard let value = store.string(forKey: key), allowed.contains(value) else { return defaultValue }
            return value
        },
                set: { store.set($0, forKey: key) })
    }
}

extension PlatformConfig {
    static func seedDefaults() {
        let store = SharedDefaults.store
        for p in all {
            for s in p.settings {
                switch s.kind {
                case .toggle:
                    if store.object(forKey: s.rawKey) == nil {
                        store.set(s.defaultValue, forKey: s.rawKey)
                    }
                case .shortform:
                    migrateShortform(s, in: store)
                }
            }
        }
        QuoteWidget.seedDefaults()
    }

    /// Shortform keys are tri-state strings (`block`/`hide`/`show`). Earlier app
    /// versions wrote Bools to them, which match no upstream CSS rule. Map the
    /// legacy intent (true = block shorts, false = leave them alone) and seed
    /// anything else from the model default.
    private static func migrateShortform(_ s: SettingKey, in store: UserDefaults) {
        let value = store.object(forKey: s.rawKey)
        if let str = value as? String, SettingKey.shortformOptions.contains(str) { return }
        if let num = value as? NSNumber {
            store.set(num.boolValue ? "block" : "show", forKey: s.rawKey)
        } else {
            store.set(s.shortformDefault, forKey: s.rawKey)
        }
    }
}

extension SettingKey {
    static let shortformOptions = ["block", "hide", "show"]

    /// For `.shortform` keys, `defaultValue` means "block by default".
    var shortformDefault: String { defaultValue ? "block" : "show" }

    var toggleBinding: Binding<Bool> {
        SharedDefaults.boolBinding(forKey: rawKey)
    }

    var shortformBinding: Binding<String> {
        SharedDefaults.stringBinding(forKey: rawKey, default: shortformDefault, allowed: Self.shortformOptions)
    }
}
