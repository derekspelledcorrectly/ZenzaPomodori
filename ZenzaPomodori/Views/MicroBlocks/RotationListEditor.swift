import SwiftUI

struct RotationListEditor: View {
    @Binding var items: [RotationItem]

    var body: some View {
        List {
            if items.isEmpty {
                Text("Add focus areas above to build your rotation")
                    .foregroundStyle(.tertiary)
                    .font(.system(size: 11))
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
            } else {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: 8) {
                        Image(systemName: "line.3.horizontal")
                            .font(.caption2)
                            .foregroundStyle(.quaternary)

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
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                }
                .onMove { items.move(fromOffsets: $0, toOffset: $1) }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}
