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
                    ForEach(p.groupedSettings, id: \.0) { group, keys in
                        Section {
                            ForEach(keys) { SettingRow(setting: $0) }
                        } header: {
                            if p.showsGroupHeaders { Text(group.rawValue) }
                        }
                    }
                }
                .formStyle(.grouped)
            }
        }
        .onAppear { PlatformConfig.seedDefaults() }
        .frame(minWidth: 580, minHeight: 380)
    }
}
