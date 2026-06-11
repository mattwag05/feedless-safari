import SwiftUI

struct SettingRow: View {
    let setting: SettingKey

    var body: some View {
        switch setting.kind {
        case .toggle:
            Toggle(setting.label, isOn: setting.toggleBinding)
        case .shortform:
            Picker(setting.label, selection: setting.shortformBinding) {
                Text("Block").tag("block")
                Text("Hide").tag("hide")
                Text("Show").tag("show")
            }
            #if os(macOS)
            .pickerStyle(.segmented)
            #endif
        }
    }
}
