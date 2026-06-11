import SwiftUI

struct SettingsView: View {
    @State private var search = ""
    @State private var showQuoteEditor = false

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
                Section(header: Label("Quote Widget", systemImage: "quote.opening")) {
                    Toggle("Show Quotes Over Hidden Feeds", isOn: QuoteWidget.enabledBinding)
                    Picker("New Quote", selection: QuoteWidget.rotationBinding) {
                        ForEach(QuoteWidget.rotationOptions, id: \.value) { option in
                            Text(option.label).tag(option.value)
                        }
                    }
                    Button("Edit Custom Quotes…") { showQuoteEditor = true }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $search, placement: .navigationBarDrawer)
            .navigationTitle("Feedless")
        }
        .sheet(isPresented: $showQuoteEditor) {
            NavigationView {
                List { QuoteEditorView() }
                    .navigationTitle("Custom Quotes")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showQuoteEditor = false }
                        }
                    }
            }
        }
        .onAppear { PlatformConfig.seedDefaults() }
    }
}
