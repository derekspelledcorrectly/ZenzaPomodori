import SwiftUI

struct ActiveRotationView: View {
    let engine: MicroBlockEngine
    let timer: PomodoroTimer
    var onSkip: () -> Void
    var onEditList: () -> Void
    var onPause: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("MicroBlocks")
                    .font(.caption.bold())
                    .textCase(.uppercase)
                    .foregroundStyle(.red)
                Text(timer.phase.label(totalBlocks: timer.blocksBeforeLongBreak))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(timer.formattedTime)
                    .font(.callout.bold())
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 14) {
                ConcentricTimerView(
                    microProgress: engine.progress,
                    outerProgress: timer.progress,
                    microTimeFormatted: TimeFormatting.formatted(seconds: engine.microSecondsRemaining),
                    outerTimeFormatted: timer.formattedTime
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(engine.currentItemName ?? "")
                        .font(.callout.bold())
                        .lineLimit(1)

                    Text("\(engine.currentIndex + 1) of \(engine.rotationItems.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    +
                    Text(" \u{00B7} Next: \(engine.nextItemName ?? "start")")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(.sRGB, red: 0.29, green: 0.44, blue: 0.65).opacity(0.7))
                            .frame(width: 6, height: 6)
                        Text("\(timer.formattedTime) remaining")
                            .font(.caption2)
                            .foregroundStyle(Color(.sRGB, red: 0.29, green: 0.44, blue: 0.65).opacity(0.7))
                    }
                }
            }

            CollapsedListPreview(items: engine.rotationItems, currentIndex: engine.currentIndex)

            HStack(spacing: 8) {
                Button("Skip") { onSkip() }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .controlSize(.small)

                Button("Edit List") { onEditList() }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                Button(engine.isPaused ? "Resume" : "Pause") { onPause() }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }
        }
        .padding()
        .frame(width: 320)
    }
}

private struct CollapsedListPreview: View {
    let items: [RotationItem]
    let currentIndex: Int
    @State private var isExpanded = false

    var body: some View {
        if items.count > 1 {
            DisclosureGroup(isExpanded: $isExpanded) {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        Text(item.name)
                            .font(.caption)
                            .foregroundStyle(index == currentIndex ? .primary : .secondary)
                            .fontWeight(index == currentIndex ? .bold : .regular)
                    }
                }
            } label: {
                let upcoming = items.dropFirst(currentIndex + 1).prefix(2).map(\.name)
                let remaining = max(0, items.count - currentIndex - 1 - upcoming.count)
                HStack(spacing: 4) {
                    if !upcoming.isEmpty {
                        Text(upcoming.joined(separator: " \u{00B7} "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if remaining > 0 {
                        Text("+\(remaining) more")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .font(.caption)
        }
    }
}
