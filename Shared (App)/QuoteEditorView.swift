import SwiftUI

/// The enable toggle + rotation picker, shared by both platforms' settings UIs.
struct QuoteWidgetControls: View {
    var body: some View {
        Toggle("Show Quotes Over Hidden Feeds", isOn: QuoteWidget.enabledBinding)
        Picker("New Quote", selection: QuoteWidget.rotationBinding) {
            ForEach(QuoteWidget.rotationOptions, id: \.value) { option in
                Text(option.label).tag(option.value)
            }
        }
    }
}

/// Custom-quote list editor, shared by both platforms. iOS presents it as a
/// sheet; macOS embeds it inline in the Quote Widget settings pane.
struct QuoteEditorView: View {
    @State private var quotes = QuoteWidget.loadCustomQuotes()
    @State private var newText = ""
    @State private var newAttribution = ""

    private var trimmedText: String { newText.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        Group {
            if quotes.isEmpty {
                Text("No custom quotes yet.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(quotes) { quote in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("“\(quote.text)”")
                            Text("— \(quote.attribution)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(role: .destructive) {
                            quotes.removeAll { $0.id == quote.id }
                            QuoteWidget.saveCustomQuotes(quotes)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }

            TextField("Quote", text: $newText)
            TextField("Attribution", text: $newAttribution)
            Button("Add Quote") {
                guard !trimmedText.isEmpty else { return }
                let attribution = newAttribution.trimmingCharacters(in: .whitespacesAndNewlines)
                quotes.append(CustomQuote(text: trimmedText, attribution: attribution.isEmpty ? "Unknown" : attribution))
                QuoteWidget.saveCustomQuotes(quotes)
                newText = ""
                newAttribution = ""
            }
            .disabled(trimmedText.isEmpty)
        }
    }
}
