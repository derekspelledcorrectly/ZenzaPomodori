import SwiftUI

struct TimerDisplayView: View {
    let phase: TimerPhase
    let progress: Double
    let formattedTime: String
    let isOvertime: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 6)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.3), value: progress)
                    .transaction { t in
                        if progress < 0.05 || isOvertime {
                            t.animation = nil
                        }
                    }

                VStack(spacing: 2) {
                    Text(formattedTime)
                        .font(.system(size: 32, weight: .medium, design: .monospaced))
                        .foregroundStyle(isOvertime ? .orange : .primary)

                    Text(phase.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 140, height: 140)
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
        formattedTime: "15:00",
        isOvertime: false
    )
    .padding()
}

#Preview("Overtime") {
    TimerDisplayView(
        phase: .focus(block: 1),
        progress: 1.0,
        formattedTime: "+02:30",
        isOvertime: true
    )
    .padding()
}

#Preview("Break") {
    TimerDisplayView(
        phase: .shortBreak(afterBlock: 1),
        progress: 0.7,
        formattedTime: "01:30",
        isOvertime: false
    )
    .padding()
}
