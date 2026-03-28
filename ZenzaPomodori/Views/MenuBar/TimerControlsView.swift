import SwiftUI

struct TimerControlsView: View {
    let phase: TimerPhase
    let isRunning: Bool
    let onStart: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onNext: () -> Void
    let onReset: () -> Void
    var onAbandon: (() -> Void)?

    private var playPauseAction: () -> Void {
        if phase == .idle { return onStart }
        return isRunning ? onPause : onResume
    }

    var body: some View {
        HStack(spacing: 16) {
            Button(action: playPauseAction) {
                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                    .frame(width: 20)
            }
            .controlSize(phase == .idle ? .large : .regular)
            .help(isRunning ? "Pause" : (phase == .idle ? "Start" : "Resume"))

            if phase != .idle {
                Button(action: onNext) {
                    Image(systemName: phase.isFocus ? "checkmark.circle" : "forward.end.fill")
                        .frame(width: 20)
                }
                .help(phase.isFocus ? "Complete Block" : "Skip Break")

                Button(action: onReset) {
                    Image(systemName: "arrow.counterclockwise")
                        .frame(width: 20)
                }
                .help("Restart Timer")

                if phase.isFocus, let onAbandon {
                    Button(action: onAbandon) {
                        Image(systemName: "xmark.circle")
                            .frame(width: 20)
                    }
                    .help("Abandon Block")
                }
            }
        }
        .buttonStyle(.bordered)
    }
}

#Preview("Idle") {
    TimerControlsView(
        phase: .idle,
        isRunning: false,
        onStart: {}, onPause: {}, onResume: {},
        onNext: {}, onReset: {}
    )
    .padding()
}

#Preview("Running") {
    TimerControlsView(
        phase: .focus(block: 1),
        isRunning: true,
        onStart: {}, onPause: {}, onResume: {},
        onNext: {}, onReset: {}
    )
    .padding()
}
