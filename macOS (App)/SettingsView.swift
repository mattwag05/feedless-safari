import SwiftUI

struct SettingsView: View {
    private static let quoteWidgetID = "quote-widget"

    @State private var search = ""
    @State private var selected = PlatformConfig.all[0].id

    private var filtered: [PlatformConfig] {
        let q = search.lowercased()
        return q.isEmpty ? PlatformConfig.all : PlatformConfig.all.filter { $0.name.lowercased().contains(q) }
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selected) {
                ForEach(filtered) { p in
                    Label(p.name, systemImage: p.systemImage).tag(p.id)
                }
                Section("Extras") {
                    Label("Quote Widget", systemImage: "quote.opening").tag(Self.quoteWidgetID)
                }
            }
            .listStyle(.sidebar)
            .searchable(text: $search)
        } detail: {
            if selected == Self.quoteWidgetID {
                quoteWidgetForm
            } else if let p = PlatformConfig.all.first(where: { $0.id == selected }) {
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

    private var quoteWidgetForm: some View {
        Form {
            Section {
                Toggle("Show Quotes Over Hidden Feeds", isOn: QuoteWidget.enabledBinding)
                Picker("New Quote", selection: QuoteWidget.rotationBinding) {
                    ForEach(QuoteWidget.rotationOptions, id: \.value) { option in
                        Text(option.label).tag(option.value)
                    }
                }
            }
            Section("Custom Quotes") {
                QuoteEditorView()
            }
        }
        .formStyle(.grouped)
    }
}
