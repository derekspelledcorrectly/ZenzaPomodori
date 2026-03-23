import SwiftUI

struct MicroBlockSetupView: View {
    @Bindable var rotationStore: RotationStore
    let focusNameStore: FocusNameStore
    @Binding var workingItems: [RotationItem]
    var onStart: () -> Void

    @State private var newItemText: String = ""
    @State private var renamingRotationId: UUID?
    @State private var renameText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Saved rotations
            if !rotationStore.savedRotations.isEmpty {
                sectionLabel("Saved")

                FlowLayout(spacing: 6) {
                    ForEach(rotationStore.savedRotations) { rotation in
                        chipButton(rotation.name, count: rotation.items.count) {
                            workingItems = rotation.items
                        }
                        .contextMenu {
                            Button("Rename...") {
                                renameText = rotation.name
                                renamingRotationId = rotation.id
                            }
                            Divider()
                            Button("Delete", role: .destructive) {
                                rotationStore.deleteRotation(rotation.id)
                            }
                        }
                        .popover(isPresented: Binding(
                            get: { renamingRotationId == rotation.id },
                            set: { if !$0 { renamingRotationId = nil } }
                        )) {
                            renamePopover(rotationId: rotation.id)
                        }
                    }
                }
            }

            // Quick add from recents
            let recentEntries = focusNameStore.entries
                .filter { entry in !workingItems.contains { $0.name == entry.name } }
                .prefix(6)

            if !recentEntries.isEmpty {
                if !rotationStore.savedRotations.isEmpty {
                    Divider().padding(.vertical, 2)
                }

                FlowLayout(spacing: 6) {
                    ForEach(Array(recentEntries), id: \.id) { entry in
                        addChipButton(entry.name) {
                            workingItems.append(RotationItem(name: entry.name))
                        }
                        .contextMenu {
                            Button("Remove from Recents", role: .destructive) {
                                focusNameStore.deleteEntry(entry.id)
                            }
                        }
                    }
                }
            }

            // Text input
            TextField("Add focus area...", text: $newItemText)
                .textFieldStyle(.plain)
                .font(.system(size: 12))
                .padding(8)
                .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 6))
                .onSubmit(addNewItem)

            // Rotation list (fixed height, scrolls)
            Divider().padding(.vertical, 2)

            RotationListEditor(items: $workingItems)
                .frame(height: 120)

            // Footer
            HStack {
                if !workingItems.isEmpty {
                    SaveRotationButton(
                        items: workingItems,
                        rotationStore: rotationStore
                    )
                }

                Spacer()

                Button {
                    onStart()
                } label: {
                    Text("Start")
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(workingItems.isEmpty ? Color.secondary.opacity(0.3) : Color.red)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                .disabled(workingItems.isEmpty)
                .keyboardShortcut(.return)
            }
            .padding(.top, 2)
        }
    }

    // MARK: - Components

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(.tertiary)
            .textCase(.uppercase)
            .tracking(0.5)
    }

    private func chipButton(_ name: String, count: Int, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(name)
                    .font(.system(size: 11))
                Text("\(count)")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.primary.opacity(0.06), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func addChipButton(_ name: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 2) {
                Image(systemName: "plus")
                    .font(.system(size: 9, weight: .medium))
                Text(name)
                    .font(.system(size: 11))
            }
            .foregroundStyle(.red.opacity(0.8))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.red.opacity(0.08), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func renamePopover(rotationId: UUID) -> some View {
        VStack(spacing: 8) {
            TextField("Name", text: $renameText)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    commitRename(rotationId)
                }
            Button("Rename") {
                commitRename(rotationId)
            }
            .keyboardShortcut(.defaultAction)
            .buttonStyle(.borderedProminent)
            .disabled(renameText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding()
        .frame(width: 200)
    }

    // MARK: - Actions

    private func addNewItem() {
        let trimmed = newItemText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        workingItems.append(RotationItem(name: trimmed))
        newItemText = ""
    }

    private func commitRename(_ id: UUID) {
        let trimmed = renameText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        rotationStore.renameRotation(id, to: trimmed)
        renamingRotationId = nil
    }
}

// MARK: - Save Rotation Button

private struct SaveRotationButton: View {
    let items: [RotationItem]
    @Bindable var rotationStore: RotationStore
    @State private var showingNamePrompt = false
    @State private var rotationName = ""

    var body: some View {
        Button {
            showingNamePrompt = true
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "star")
                    .font(.system(size: 10))
                Text("Save")
                    .font(.system(size: 11))
            }
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showingNamePrompt) {
            VStack(spacing: 8) {
                TextField("Rotation name", text: $rotationName)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(saveRotation)
                Button("Save", action: saveRotation)
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
                    .disabled(rotationName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
            .frame(width: 200)
        }
    }

    private func saveRotation() {
        let trimmed = rotationName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        rotationStore.saveRotation(name: trimmed, items: items)
        rotationName = ""
        showingNamePrompt = false
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}
