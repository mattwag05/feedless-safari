import SwiftUI

extension PlatformConfig {
    static func seedDefaults() {
        let store = SharedDefaults.store
        for p in all {
            for s in p.settings where store.object(forKey: s.rawKey) == nil {
                store.set(s.defaultValue, forKey: s.rawKey)
            }
        }
    }
}

extension SettingKey {
    var toggleBinding: Binding<Bool> {
        Binding(get: { SharedDefaults.store.bool(forKey: rawKey) },
                set: { SharedDefaults.store.set($0, forKey: rawKey) })
    }
}
