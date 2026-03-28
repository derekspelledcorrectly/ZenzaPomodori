import SwiftUI

struct TimerControlsView: View {
    let phase: TimerPhase
    let isRunning: Bool
    let onStart: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onNext: () -> Void

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
            .help(isRunning ? "Pause (Space / Return)" : (phase == .idle ? "Start (Return)" : "Resume (Space / Return)"))

            if phase != .idle {
                Button(action: onNext) {
                    Image(systemName: phase.isFocus ? "checkmark.circle" : "forward.end.fill")
                        .frame(width: 20)
                }
                .help(phase.isFocus ? "Complete Block (\u{2318}\u{25B6}\u{FE0E})" : "Skip Break (\u{2318}\u{25B6}\u{FE0E})")
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
        onNext: {}
    )
    .padding()
}

#Preview("Running") {
    TimerControlsView(
        phase: .focus(block: 1),
        isRunning: true,
        onStart: {}, onPause: {}, onResume: {},
        onNext: {}
    )
    .padding()
}
