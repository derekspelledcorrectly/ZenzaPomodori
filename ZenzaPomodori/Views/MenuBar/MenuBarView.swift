import SwiftUI

struct MenuBarView: View {
    @Bindable var timer: PomodoroTimer

    var body: some View {
        VStack(spacing: 12) {
            TimerDisplayView(
                phase: timer.phase,
                progress: timer.progress,
                formattedTime: timer.formattedTime
            )

            TimerControlsView(
                phase: timer.phase,
                isRunning: timer.isRunning,
                onStart: timer.start,
                onPause: timer.pause,
                onResume: timer.resume,
                onSkip: timer.skip,
                onReset: timer.reset
            )

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding()
        .frame(width: 200)
    }
}
