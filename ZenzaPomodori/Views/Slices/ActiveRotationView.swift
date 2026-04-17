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
            concentricTimer

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
                .help(engine.isPaused ? "Resume (Space)" : "Pause (Space)")
                .accessibilityLabel(engine.isPaused ? "Resume" : "Pause")

                Button(action: { onNext() }) {
                    Image(systemName: "forward.end.fill")
                        .frame(width: 20)
                }
                .help(engine.isOvertime ? "Start Next Slice (Return)" : "Next Slice (Return)")
                .accessibilityLabel(engine.isOvertime ? "Start next slice" : "Skip to next slice")

                if !autoAdvance && timer.isOvertime {
                    Button(action: { onFinishBlock() }) {
                        Image(systemName: "checkmark.circle")
                            .frame(width: 20)
                    }
                    .help("Finish Block (\u{2318}\u{21A9}\u{FE0E})")
                    .accessibilityLabel("Finish block")
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
        hiddenShortcut(.space, modifiers: [], action: onPause)
        hiddenShortcut(.return, modifiers: [], action: onNext)
        hiddenShortcut(.return, modifiers: .command, action: onFinishBlock)
    }

    private var concentricTimer: ConcentricTimerView {
        var view = ConcentricTimerView(
            sliceProgress: timer.progress,
            outerProgress: engine.progress,
            sliceTimeFormatted: engine.formattedTime,
            outerTimeFormatted: timer.formattedTime,
            outerColor: .orange,
            innerColor: timer.phase.color,
            sliceIsOvertime: engine.isOvertime
        )
        #if DEBUG
            view.onSliceTap = {
                if NSEvent.modifierFlags.contains(.shift) {
                    engine.debugAddTime(10)
                } else {
                    engine.debugSkipToEnd()
                }
            }
            view.onBlockTap = {
                if NSEvent.modifierFlags.contains(.shift) {
                    timer.debugAddTime(20)
                } else {
                    timer.debugSkipToEnd()
                }
            }
        #endif
        return view
    }

    private var blockLabel: String {
        switch timer.phase {
        case .focus(let block): "Block \(block)/\(timer.blocksBeforeLongBreak)"
        case .shortBreak: "Short Break"
        case .longBreak: "Long Break"
        case .idle: "Ready"
        }
    }

}
