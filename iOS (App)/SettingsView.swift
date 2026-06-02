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
                            Toggle(s.label, isOn: s.toggleBinding)
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
