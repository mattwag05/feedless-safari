import SwiftUI

struct SettingsView: View {
    @State private var search = ""
    @State private var selected = PlatformConfig.all[0].id

    private var filtered: [PlatformConfig] {
        let q = search.lowercased()
        return q.isEmpty ? PlatformConfig.all : PlatformConfig.all.filter { $0.name.lowercased().contains(q) }
    }

    var body: some View {
        NavigationSplitView {
            List(filtered, selection: $selected) { p in
                Label(p.name, systemImage: p.systemImage).tag(p.id)
            }
            .listStyle(.sidebar)
            .searchable(text: $search)
        } detail: {
            if let p = PlatformConfig.all.first(where: { $0.id == selected }) {
                Form {
                    Section { ForEach(p.settings) { s in Toggle(s.label, isOn: keyBinding(s.rawKey)) } }
                }
                .formStyle(.grouped)
            }
        }
        .onAppear { loadDefaults() }
        .frame(minWidth: 580, minHeight: 380)
    }

    private func loadDefaults() {
        for p in PlatformConfig.all {
            for s in p.settings where UserDefaults.standard.object(forKey: s.rawKey) == nil {
                UserDefaults.standard.set(s.defaultValue, forKey: s.rawKey)
            }
        }
    }

    private func keyBinding(_ key: String) -> Binding<Bool> {
        Binding(get:  { UserDefaults.standard.bool(forKey: key) },
                set:  { UserDefaults.standard.set($0, forKey: key) })
    }
}
