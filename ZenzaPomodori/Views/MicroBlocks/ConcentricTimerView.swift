import SwiftUI

struct ConcentricTimerView: View {
    let microProgress: Double
    let outerProgress: Double
    let microTimeFormatted: String
    let outerTimeFormatted: String
    var size: CGFloat = 140

    private var scale: CGFloat { size / 140 }
    private var outerRadius: CGFloat { 64 * scale }
    private var innerRadius: CGFloat { 48 * scale }
    private var outerStroke: CGFloat { 4 * scale }
    private var innerStroke: CGFloat { 5 * scale }
    private var mainFontSize: CGFloat { 26 * scale }
    private var subFontSize: CGFloat { 11 * scale }

    var body: some View {
        ZStack {
            // Outer ring: pomodoro block
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: outerStroke)
                .frame(width: outerRadius * 2, height: outerRadius * 2)
            Circle()
                .trim(from: 0, to: outerProgress)
                .stroke(
                    Color.blue.opacity(0.4),
                    style: StrokeStyle(lineWidth: outerStroke, lineCap: .round)
                )
                .frame(width: outerRadius * 2, height: outerRadius * 2)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.3), value: outerProgress)

            // Inner ring: micro-rotation
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: innerStroke)
                .frame(width: innerRadius * 2, height: innerRadius * 2)
            Circle()
                .trim(from: 0, to: microProgress)
                .stroke(
                    Color.red.opacity(0.85),
                    style: StrokeStyle(lineWidth: innerStroke, lineCap: .round)
                )
                .frame(width: innerRadius * 2, height: innerRadius * 2)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.3), value: microProgress)

            // Center text
            VStack(spacing: 1) {
                Text(microTimeFormatted)
                    .font(.system(size: mainFontSize, weight: .medium, design: .monospaced))
                    .foregroundStyle(.primary)
                Text(outerTimeFormatted)
                    .font(.system(size: subFontSize, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
    }
}
