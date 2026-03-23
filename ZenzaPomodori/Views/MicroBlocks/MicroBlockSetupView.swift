import SwiftUI

struct MicroBlockSetupView: View {
    @Bindable var rotationStore: RotationStore
    let focusNameStore: FocusNameStore
    @Binding var workingItems: [RotationItem]
    var onStart: () -> Void

    @State private var newItemText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !rotationStore.savedRotations.isEmpty {
                Text("Saved Rotations")
                    .font(.caption2)
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)

                FlowLayout(spacing: 6) {
                    ForEach(rotationStore.savedRotations) { rotation in
                        Button {
                            workingItems = rotation.items
                        } label: {
                            Text("\(rotation.name) (\(rotation.items.count))")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }

            let recentNames = focusNameStore.entries
                .map(\.name)
                .filter { name in !workingItems.contains { $0.name == name } }
                .prefix(6)

            if !recentNames.isEmpty {
                Text("Quick Add")
                    .font(.caption2)
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)

                FlowLayout(spacing: 4) {
                    ForEach(Array(recentNames), id: \.self) { name in
                        Button {
                            workingItems.append(RotationItem(name: name))
                        } label: {
                            Text("+ \(name)")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        .controlSize(.small)
                    }
                }
            }

            HStack {
                TextField("Add focus area...", text: $newItemText)
                    .textFieldStyle(.roundedBorder)
                    .font(.callout)
                    .onSubmit(addNewItem)

                Button("Add", action: addNewItem)
                    .controlSize(.small)
                    .disabled(newItemText.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            if !workingItems.isEmpty {
                Divider()

                Text("Rotation Order")
                    .font(.caption2)
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)

                RotationListEditor(items: $workingItems)
            }

            HStack {
                if !workingItems.isEmpty {
                    SaveRotationButton(
                        items: workingItems,
                        rotationStore: rotationStore
                    )
                }

                Spacer()

                Button("Start") {
                    onStart()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(workingItems.isEmpty)
                .keyboardShortcut(.return)
            }
            .padding(.top, 4)
        }
    }

    private func addNewItem() {
        let trimmed = newItemText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        workingItems.append(RotationItem(name: trimmed))
        newItemText = ""
    }
}

private struct SaveRotationButton: View {
    let items: [RotationItem]
    @Bindable var rotationStore: RotationStore
    @State private var showingNamePrompt = false
    @State private var rotationName = ""

    var body: some View {
        Button {
            showingNamePrompt = true
        } label: {
            Label("Save Rotation", systemImage: "star")
                .font(.caption)
        }
        .buttonStyle(.borderless)
        .popover(isPresented: $showingNamePrompt) {
            VStack(spacing: 8) {
                TextField("Rotation name", text: $rotationName)
                    .textFieldStyle(.roundedBorder)
                Button("Save") {
                    let trimmed = rotationName.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { return }
                    rotationStore.saveRotation(name: trimmed, items: items)
                    rotationName = ""
                    showingNamePrompt = false
                }
                .buttonStyle(.borderedProminent)
                .disabled(rotationName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
            .frame(width: 200)
        }
    }
}

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
