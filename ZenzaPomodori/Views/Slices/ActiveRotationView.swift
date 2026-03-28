import SwiftUI

struct ActiveRotationView: View {
    let engine: SliceEngine
    let timer: PomodoroTimer
    var onNext: () -> Void
    var onPause: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Concentric rings: outer = slice (hero), inner = block (context)
            ConcentricTimerView(
                sliceProgress: timer.progress,
                outerProgress: engine.progress,
                sliceTimeFormatted: TimeFormatting.formatted(seconds: engine.sliceSecondsRemaining),
                outerTimeFormatted: engine.currentItemName ?? "",
                outerColor: .orange,
                innerColor: phaseColor
            )

            // Rotation + block info
            HStack(spacing: 6) {
                if engine.rotationItems.count > 1 {
                    Text("Focus \(engine.currentIndex + 1)/\(engine.rotationItems.count)")
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

                Text("\u{00B7}")
                    .foregroundStyle(.tertiary)

                Text("\(blockLabel) \u{00B7} \(timer.formattedTime) left")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            // Controls
            HStack(spacing: 16) {
                Button(action: { onPause() }) {
                    Image(systemName: engine.isPaused ? "play.fill" : "pause.fill")
                        .frame(width: 20)
                }
                .help(engine.isPaused ? "Resume" : "Pause")

                Button(action: { onNext() }) {
                    Image(systemName: "forward.end.fill")
                        .frame(width: 20)
                }
                .help("Next Focus")

            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(width: 280)
        .background { keyboardShortcuts }
    }

    @ViewBuilder
    private var keyboardShortcuts: some View {
        Button(action: { onPause() }) { EmptyView() }
            .keyboardShortcut(.space, modifiers: [])
            .frame(width: 0, height: 0).opacity(0)

        Button(action: { onNext() }) { EmptyView() }
            .keyboardShortcut(.return, modifiers: [])
            .frame(width: 0, height: 0).opacity(0)
    }

    private var blockLabel: String {
        switch timer.phase {
        case .focus(let block): "Block \(block)/\(timer.blocksBeforeLongBreak)"
        case .shortBreak: "Short Break"
        case .longBreak: "Long Break"
        case .idle: "Ready"
        }
    }

    private var phaseColor: Color {
        switch timer.phase {
        case .idle: .secondary
        case .focus: .accentColor
        case .shortBreak: .green
        case .longBreak: .teal
        }
    }
}

