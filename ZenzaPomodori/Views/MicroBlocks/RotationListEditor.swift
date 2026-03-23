import SwiftUI

struct RotationListEditor: View {
    @Binding var items: [RotationItem]

    var body: some View {
        if items.isEmpty {
            Text("No focus areas added")
                .foregroundStyle(.secondary)
                .font(.caption)
                .padding(.vertical, 4)
        } else {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                HStack(spacing: 8) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(.tertiary)
                        .font(.caption)

                    Text("\(index + 1)")
                        .font(.caption.bold())
                        .foregroundStyle(.red)
                        .frame(width: 16)

                    Text(item.name)
                        .font(.callout)
                        .lineLimit(1)

                    Spacer()

                    Button {
                        items.removeAll { $0.id == item.id }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.vertical, 2)
            }
            .onMove { items.move(fromOffsets: $0, toOffset: $1) }
        }
    }
}
