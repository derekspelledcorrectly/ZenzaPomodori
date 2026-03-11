import SwiftUI

struct MenuBarView: View {
    @Bindable var timer: PomodoroTimer

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
        }
        .padding()
        .frame(width: 240)
    }
}
