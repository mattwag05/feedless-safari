import SwiftUI

struct SettingsView: View {
    @State private var search = ""
    private var filtered: [PlatformConfig] {
        let q = search.lowercased()
        return q.isEmpty ? PlatformConfig.all : PlatformConfig.all.filter { $0.name.lowercased().contains(q) }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(filtered) { platform in
                    Section(header: Label(platform.name, systemImage: platform.systemImage)) {
                        ForEach(platform.settings) { s in
                            Toggle(s.label, isOn: keyBinding(s.rawKey))
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $search, placement: .navigationBarDrawer)
            .navigationTitle("Feedless")
        }
        .onAppear { loadDefaults() }
    }

    private func loadDefaults() {
        let store = SharedDefaults.store
        for p in PlatformConfig.all {
            for s in p.settings where store.object(forKey: s.rawKey) == nil {
                store.set(s.defaultValue, forKey: s.rawKey)
            }
        }
    }

    private func keyBinding(_ key: String) -> Binding<Bool> {
        Binding(get:  { SharedDefaults.store.bool(forKey: key) },
                set:  { SharedDefaults.store.set($0, forKey: key) })
    }
}
