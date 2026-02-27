import SwiftUI

struct TimerDisplayView: View {
    let phase: TimerPhase
    let progress: Double
    let formattedTime: String

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 6)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)

                VStack(spacing: 2) {
                    Text(formattedTime)
                        .font(.system(size: 32, weight: .medium, design: .monospaced))

                    Text(phase.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 120, height: 120)
        }
    }

    private var ringColor: Color {
        switch phase {
        case .idle: .secondary
        case .focus: .red
        case .shortBreak: .green
        case .longBreak: .blue
        }
    }
}

#Preview("Focus") {
    TimerDisplayView(
        phase: .focus(block: 2),
        progress: 0.4,
        formattedTime: "15:00"
    )
    .padding()
}

#Preview("Break") {
    TimerDisplayView(
        phase: .shortBreak(afterBlock: 1),
        progress: 0.7,
        formattedTime: "01:30"
    )
    .padding()
}
