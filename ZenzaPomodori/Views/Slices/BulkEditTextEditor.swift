import SwiftUI

struct BulkEditTextEditor: View {
    @Binding var items: [RotationItem]
    @State private var text: String = ""
    @State private var isSyncingFromItems = false
    @FocusState private var isFocused: Bool

    var body: some View {
        BulkTextView(text: $text)
            .font(.system(size: 13))
            .focused($isFocused)
            .accessibilityLabel("Focus areas")
            .accessibilityHint("Enter one focus area per line")
            .onChange(of: text) {
                guard !isSyncingFromItems else { return }
                items = Self.syncTextToItems(text: text, existing: items)
            }
            .onChange(of: items) {
                guard !isSyncingFromItems else { return }
                let newText = Self.syncItemsToText(items: items)
                if newText != text {
                    isSyncingFromItems = true
                    defer { isSyncingFromItems = false }
                    text = newText
                }
            }
            .onAppear {
                text = Self.syncItemsToText(items: items)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isFocused = true
                    moveCursorToEnd()
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.primary.opacity(0.03))
            }
    }

    private func moveCursorToEnd() {
        guard let textView = NSApplication.shared.keyWindow?
            .firstResponder as? NSTextView else { return }
        textView.moveToEndOfDocument(nil)
    }

    // MARK: - Sync Logic (static for testability)

    nonisolated static func syncTextToItems(
        text: String,
        existing: [RotationItem]
    ) -> [RotationItem] {
        let lines = text
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        return lines.enumerated().map { index, name in
            if index < existing.count {
                var item = existing[index]
                item.name = name
                return item
            } else {
                return RotationItem(name: name)
            }
        }
    }

    nonisolated static func syncItemsToText(items: [RotationItem]) -> String {
        items.map(\.name).joined(separator: "\n")
    }
}

// MARK: - NSViewRepresentable TextEditor with placeholder

private struct BulkTextView: NSViewRepresentable {
    @Binding var text: String

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        guard let textView = scrollView.documentView as? NSTextView else {
            assertionFailure("NSTextView.scrollableTextView() did not produce an NSTextView documentView")
            return scrollView
        }

        textView.font = .systemFont(ofSize: 13)
        textView.isRichText = false
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.drawsBackground = false
        textView.textContainerInset = NSSize(width: 4, height: 8)
        textView.textContainer?.lineFragmentPadding = 4

        textView.delegate = context.coordinator

        let placeholder = NSTextField(labelWithString: "Add focus areas...")
        placeholder.font = .systemFont(ofSize: 13)
        placeholder.textColor = .tertiaryLabelColor
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        textView.addSubview(placeholder)
        context.coordinator.placeholder = placeholder
        NSLayoutConstraint.activate([
            placeholder.leadingAnchor.constraint(
                equalTo: textView.leadingAnchor,
                constant: textView.textContainerInset.width
                    + (textView.textContainer?.lineFragmentPadding ?? 0)
            ),
            placeholder.topAnchor.constraint(
                equalTo: textView.topAnchor,
                constant: textView.textContainerInset.height
            ),
        ])

        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        if textView.string != text {
            textView.string = text
            let length = (text as NSString).length
            textView.setSelectedRange(NSRange(location: length, length: 0))
        }
        context.coordinator.placeholder?.isHidden = !text.isEmpty
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var text: Binding<String>
        var placeholder: NSTextField?

        init(text: Binding<String>) {
            self.text = text
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            text.wrappedValue = textView.string
            placeholder?.isHidden = !textView.string.isEmpty
        }
    }
}
