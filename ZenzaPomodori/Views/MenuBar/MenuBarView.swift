import SwiftUI

struct MenuBarView: View {
    @Bindable var timer: PomodoroTimer
    var onOpenSettings: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            TimerDisplayView(
                phase: timer.phase,
                totalBlocks: timer.blocksBeforeLongBreak,
                progress: timer.progress,
                formattedTime: timer.formattedTime,
                isOvertime: timer.isOvertime
            )

            TimerControlsView(
                phase: timer.phase,
                isRunning: timer.isRunning,
                onStart: timer.start,
                onPause: timer.pause,
                onResume: timer.resume,
                onNext: timer.next,
                onReset: timer.reset
            )

            Divider()

            HStack {
                Button(action: onOpenSettings) {
                    Image(systemName: "gear")
                }

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
            }
        }
        .padding()
        .frame(width: 240)
    }
}
