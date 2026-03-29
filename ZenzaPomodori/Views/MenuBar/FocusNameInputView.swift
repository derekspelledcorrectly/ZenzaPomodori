import SwiftUI

struct FocusNameInputView: View {
    @Binding var draftName: String
    let isLocked: Bool
    let activeFocusName: String?
    let entries: [FocusNameEntry]
    let onSelect: (FocusNameEntry) -> Void
    let onToggleFavorite: (UUID) -> Void
    let onDelete: (UUID) -> Void
    let onSubmit: () -> Void
    var autoFocus: Bool = false

    @State private var showingDropdown = false
    @FocusState private var isTextFieldFocused: Bool

    private var favorites: [FocusNameEntry] {
        entries.filter { $0.isFavorite }
    }

    private var recents: [FocusNameEntry] {
        entries.filter { !$0.isFavorite }
    }

    var body: some View {
        if isLocked {
            lockedView
        } else {
            editorView
        }
    }

    private var lockedView: some View {
        Group {
            if let name = activeFocusName {
                Text(name)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var editorView: some View {
        HStack(spacing: 4) {
            TextField("What will you focus on?", text: $draftName)
                .textFieldStyle(.plain)
                .font(.system(size: 12))
                .focused($isTextFieldFocused)
                .onSubmit {
                    isTextFieldFocused = false
                    onSubmit()
                }
                .onAppear {
                    if autoFocus {
                        isTextFieldFocused = true
                    }
                }

            if !entries.isEmpty {
                Button(action: { showingDropdown.toggle() }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showingDropdown, arrowEdge: .bottom) {
                    dropdownContent
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }

    private var dropdownContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if !favorites.isEmpty {
                    sectionHeader("Favorites")
                    ForEach(favorites) { entry in
                        entryRow(entry)
                    }
                }

                if !recents.isEmpty {
                    if !favorites.isEmpty {
                        Divider().padding(.vertical, 4)
                    }
                    sectionHeader("Recent")
                    ForEach(recents) { entry in
                        entryRow(entry)
                    }
                }
            }
            .padding(8)
        }
        .frame(width: 220)
        .frame(maxHeight: 300)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .padding(.horizontal, 4)
            .padding(.bottom, 2)
    }

    private func entryRow(_ entry: FocusNameEntry) -> some View {
        HStack(spacing: 4) {
            Button(action: {
                onSelect(entry)
                showingDropdown = false
            }) {
                Text(entry.name)
                    .font(.system(size: 12))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(action: { onToggleFavorite(entry.id) }) {
                Image(systemName: entry.isFavorite ? "star.fill" : "star")
                    .font(.system(size: 10))
                    .foregroundStyle(entry.isFavorite ? .yellow : .secondary)
            }
            .buttonStyle(.plain)

            Button(action: { onDelete(entry.id) }) {
                Image(systemName: "xmark")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(.clear)
        )
    }
}

#Preview("Editable") {
    FocusNameInputView(
        draftName: .constant("Deep Work"),
        isLocked: false,
        activeFocusName: nil,
        entries: [
            FocusNameEntry(name: "Deep Work", isFavorite: true),
            FocusNameEntry(name: "Code Review", isFavorite: false),
            FocusNameEntry(name: "Bug Fixes", isFavorite: false),
        ],
        onSelect: { _ in },
        onToggleFavorite: { _ in },
        onDelete: { _ in },
        onSubmit: {}
    )
    .padding()
    .frame(width: 240)
}

#Preview("Locked") {
    FocusNameInputView(
        draftName: .constant("Deep Work"),
        isLocked: true,
        activeFocusName: "Deep Work",
        entries: [],
        onSelect: { _ in },
        onToggleFavorite: { _ in },
        onDelete: { _ in },
        onSubmit: {}
    )
    .padding()
    .frame(width: 240)
}

#Preview("Empty") {
    FocusNameInputView(
        draftName: .constant(""),
        isLocked: false,
        activeFocusName: nil,
        entries: [],
        onSelect: { _ in },
        onToggleFavorite: { _ in },
        onDelete: { _ in },
        onSubmit: {}
    )
    .padding()
    .frame(width: 240)
}
