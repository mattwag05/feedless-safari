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
                        ForEach(platform.groupedSettings, id: \.0) { group, keys in
                            if platform.showsGroupHeaders {
                                Text(group.rawValue)
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                            }
                            ForEach(keys) { SettingRow(setting: $0) }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $search, placement: .navigationBarDrawer)
            .navigationTitle("Feedless")
        }
        .onAppear { PlatformConfig.seedDefaults() }
    }
}
