import SwiftUI

struct RotationTransitionCard: View {
    let currentName: String
    let nextName: String?
    let positionText: String
    let outerTimeRemaining: String
    let rotationProgress: Double
    var onDismiss: () -> Void
    var onAutoDismiss: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Rotating")
                    .font(.caption.bold())
                    .textCase(.uppercase)
                    .foregroundStyle(.red)
                Spacer()
                Text("\(positionText) \u{00B7} \(outerTimeRemaining) left")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(currentName)
                .font(.title3.bold())
                .lineLimit(1)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(.sRGB, red: 0.04, green: 0.04, blue: 0.1))
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.red)
                        .frame(width: geo.size.width * rotationProgress, height: 4)
                }
            }
            .frame(height: 4)

            if let nextName {
                Text("Up next: \(nextName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(width: 320)
        .background {
            Button("Dismiss") { onDismiss() }
                .keyboardShortcut(.return, modifiers: [])
                .frame(width: 0, height: 0)
                .opacity(0)

            Button("Dismiss2") { onDismiss() }
                .keyboardShortcut(.space, modifiers: [])
                .frame(width: 0, height: 0)
                .opacity(0)
        }
    }
}
