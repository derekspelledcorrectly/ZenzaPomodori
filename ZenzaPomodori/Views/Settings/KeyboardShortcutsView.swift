import SwiftUI

struct ShortcutEntry {
    let action: String
    let keys: String
}

struct ShortcutSection {
    let title: String
    let shortcuts: [ShortcutEntry]
}

enum ShortcutData {
    static let sections: [ShortcutSection] = [
        ShortcutSection(title: "General", shortcuts: [
            ShortcutEntry(action: "Start timer", keys: "Space / ↩"),
            ShortcutEntry(action: "Pause / Resume", keys: "Space / ↩"),
            ShortcutEntry(action: "Settings", keys: "⌘,"),
            ShortcutEntry(action: "Keyboard Shortcuts", keys: "⌘/"),
            ShortcutEntry(action: "Switch to Focus", keys: "⌘←"),
            ShortcutEntry(action: "Switch to Slices", keys: "⌘→"),
            ShortcutEntry(action: "Dismiss / Go back", keys: "Escape"),
        ]),
        ShortcutSection(title: "Timer Running", shortcuts: [
            ShortcutEntry(action: "Finish Block / Break", keys: "⌘↩"),
            ShortcutEntry(action: "Restart Timer", keys: "⌘R"),
            ShortcutEntry(action: "Abandon Block", keys: "⌘⌫"),
        ]),
        ShortcutSection(title: "Slices Active", shortcuts: [
            ShortcutEntry(action: "Edit Rotation List", keys: "⌘E"),
            ShortcutEntry(action: "Restart Slice", keys: "⌘R"),
            ShortcutEntry(action: "Restart Block Timer", keys: "⇧⌘R"),
        ]),
    ]
}

struct KeyboardShortcutsView: View {
    var onBack: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            if let onBack {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                    }
                    .buttonStyle(.borderless)
                    Text("Keyboard Shortcuts")
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 4)
            }

            Form {
                ForEach(ShortcutData.sections, id: \.title) { section in
                    Section(section.title) {
                        ForEach(section.shortcuts, id: \.action) { shortcut in
                            HStack {
                                Text(shortcut.action)
                                Spacer()
                                Text(shortcut.keys)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .fixedSize(horizontal: false, vertical: true)

            if let onBack {
                Button("Done", action: onBack)
                    .keyboardShortcut(.defaultAction)
                    .padding(.bottom, 12)
                Button(action: onBack) { EmptyView() }
                    .keyboardShortcut(.escape, modifiers: [])
                    .frame(width: 0, height: 0)
                    .opacity(0)
            }
        }
        .frame(width: 280)
    }
}
