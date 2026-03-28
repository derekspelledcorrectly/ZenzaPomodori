import SwiftUI

struct ActiveRotationView: View {
    let engine: SliceEngine
    let timer: PomodoroTimer
    var onNext: () -> Void
    var onPause: () -> Void
    var onFinishBlock: () -> Void
    let autoAdvance: Bool

    var body: some View {
        VStack(spacing: 12) {
            // Concentric rings: outer = slice (hero), inner = block (context)
            ConcentricTimerView(
                sliceProgress: timer.progress,
                outerProgress: engine.progress,
                sliceTimeFormatted: TimeFormatting.formatted(seconds: engine.sliceSecondsRemaining),
                outerTimeFormatted: timer.formattedTime,
                outerColor: .orange,
                innerColor: phaseColor
            )

            // Current focus, metadata, next focus
            VStack(spacing: 4) {
                if let current = engine.currentItemName {
                    Text(current)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }

                HStack(spacing: 6) {
                    if engine.rotationItems.count > 1 {
                        Text("Focus \(engine.currentIndex + 1)/\(engine.rotationItems.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text("\u{00B7}")
                        .foregroundStyle(.tertiary)

                    Text(blockLabel)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                if let next = engine.nextItemName {
                    Text("Next: \(next)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
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

                if !autoAdvance && timer.isOvertime {
                    Button(action: { onFinishBlock() }) {
                        Image(systemName: "checkmark.circle")
                            .frame(width: 20)
                    }
                    .help("Finish Block (\u{2318}\u{21A9}\u{FE0E})")
                }
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

        Button(action: { onFinishBlock() }) { EmptyView() }
            .keyboardShortcut(.return, modifiers: .command)
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

