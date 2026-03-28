import SwiftUI

struct RotationTransitionCard: View {
    let currentName: String
    let nextName: String?
    let positionText: String
    let outerTimeRemaining: String
    let rotationProgress: Double
    var onDismiss: () -> Void
    var onClose: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Rotating")
                    .font(.caption.bold())
                    .textCase(.uppercase)
                    .foregroundColor(.accentColor)
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
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.accentColor)
                        .frame(width: geo.size.width * rotationProgress, height: 4)
                }
            }
            .frame(height: 4)

            HStack {
                if let nextName {
                    Text("Up next: \(nextName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: { onDismiss() }) {
                    Image(systemName: "chevron.down.circle")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("Show Full View")
            }
        }
        .padding(16)
        .frame(width: 320)
        .background {
            let closeAction = { (onClose ?? onDismiss)() }
            Button("K1") { closeAction() }
                .keyboardShortcut(.return, modifiers: [])
                .frame(width: 0, height: 0)
                .opacity(0)

            Button("K2") { closeAction() }
                .keyboardShortcut(.space, modifiers: [])
                .frame(width: 0, height: 0)
                .opacity(0)

            Button("K3") { closeAction() }
                .keyboardShortcut(.escape, modifiers: [])
                .frame(width: 0, height: 0)
                .opacity(0)
        }
    }
}
