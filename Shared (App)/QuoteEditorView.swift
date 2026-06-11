import SwiftUI

/// Custom-quote list editor, shared by both platforms. iOS presents it as a
/// sheet; macOS embeds it inline in the Quote Widget settings pane.
struct QuoteEditorView: View {
    @State private var quotes = QuoteWidget.loadCustomQuotes()
    @State private var newText = ""
    @State private var newAttribution = ""

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
                let text = newText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !text.isEmpty else { return }
                let attribution = newAttribution.trimmingCharacters(in: .whitespacesAndNewlines)
                quotes.append(CustomQuote(text: text, attribution: attribution.isEmpty ? "Unknown" : attribution))
                QuoteWidget.saveCustomQuotes(quotes)
                newText = ""
                newAttribution = ""
            }
            .disabled(newText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
}
