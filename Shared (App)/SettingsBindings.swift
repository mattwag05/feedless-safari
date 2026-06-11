import SwiftUI

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
    }

    /// Shortform keys are tri-state strings (`block`/`hide`/`show`). Earlier app
    /// versions wrote Bools to them, which match no upstream CSS rule. Map the
    /// legacy intent (true = block shorts, false = leave them alone) and seed
    /// anything else to the upstream default.
    private static func migrateShortform(_ s: SettingKey, in store: UserDefaults) {
        let value = store.object(forKey: s.rawKey)
        if let str = value as? String, SettingKey.shortformOptions.contains(str) { return }
        if let num = value as? NSNumber {
            store.set(num.boolValue ? "block" : "show", forKey: s.rawKey)
        } else {
            store.set("block", forKey: s.rawKey)
        }
    }
}

extension SettingKey {
    static let shortformOptions = ["block", "hide", "show"]

    var toggleBinding: Binding<Bool> {
        Binding(get: { SharedDefaults.store.bool(forKey: rawKey) },
                set: { SharedDefaults.store.set($0, forKey: rawKey) })
    }

    var shortformBinding: Binding<String> {
        Binding(get: {
            let value = SharedDefaults.store.string(forKey: rawKey)
            return Self.shortformOptions.contains(value ?? "") ? value! : "block"
        },
                set: { SharedDefaults.store.set($0, forKey: rawKey) })
    }
}
