import SwiftUI

struct ActiveRotationView: View {
    let engine: MicroBlockEngine
    let timer: PomodoroTimer
    var onSkip: () -> Void
    var onEditList: () -> Void
    var onPause: () -> Void
    var onEndBlock: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Concentric timer rings (centered, like TimerDisplayView)
            ConcentricTimerView(
                microProgress: engine.progress,
                outerProgress: timer.progress,
                microTimeFormatted: TimeFormatting.formatted(seconds: engine.microSecondsRemaining),
                outerTimeFormatted: timer.formattedTime
            )

            // Focus name + position
            VStack(spacing: 4) {
                Text(engine.currentItemName ?? "")
                    .font(.title3.bold())
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(timer.phase.label(totalBlocks: timer.blocksBeforeLongBreak))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if engine.rotationItems.count > 1 {
                        Text("\u{00B7}")
                            .foregroundStyle(.tertiary)
                        Text("\(engine.currentIndex + 1) of \(engine.rotationItems.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let next = engine.nextItemName {
                        Text("\u{00B7}")
                            .foregroundStyle(.tertiary)
                        Text("Next: \(next)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Collapsed list preview
            CollapsedListPreview(items: engine.rotationItems, currentIndex: engine.currentIndex)

            // Controls
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

                Button("End Block") { onEndBlock() }
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
