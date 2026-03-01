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
                    Image(systemName: "play.fill")
                }
                .controlSize(.large)
            } else {
                Button(action: isRunning ? onPause : onResume) {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .frame(width: 20)
                }

                Button(action: onSkip) {
                    Image(systemName: "forward.fill")
                        .frame(width: 20)
                }

                Button(action: onReset) {
                    Image(systemName: "arrow.counterclockwise")
                        .frame(width: 20)
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
