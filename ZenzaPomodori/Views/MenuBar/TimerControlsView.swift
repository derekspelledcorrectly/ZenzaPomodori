import SwiftUI

struct TimerControlsView: View {
    let phase: TimerPhase
    let isRunning: Bool
    let onStart: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onSkip: () -> Void
    let onReset: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            if phase == .idle {
                Button(action: onStart) {
                    Label("Start", systemImage: "play.fill")
                }
                .controlSize(.large)
            } else {
                Button(action: isRunning ? onPause : onResume) {
                    Label(
                        isRunning ? "Pause" : "Resume",
                        systemImage: isRunning ? "pause.fill" : "play.fill"
                    )
                }

                Button(action: onSkip) {
                    Label("Skip", systemImage: "forward.fill")
                }

                Button(action: onReset) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
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
        onSkip: {}, onReset: {}
    )
    .padding()
}

#Preview("Running") {
    TimerControlsView(
        phase: .focus(block: 1),
        isRunning: true,
        onStart: {}, onPause: {}, onResume: {},
        onSkip: {}, onReset: {}
    )
    .padding()
}
