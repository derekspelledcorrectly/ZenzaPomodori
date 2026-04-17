import SwiftUI

struct ConcentricTimerView: View {
    let sliceProgress: Double
    let outerProgress: Double
    let sliceTimeFormatted: String
    let outerTimeFormatted: String
    var outerColor: Color = .secondary
    var innerColor: Color = .orange
    var sliceIsOvertime: Bool = false
    var size: CGFloat = 140
    #if DEBUG
        var onSliceTap: (() -> Void)?
        var onBlockTap: (() -> Void)?
    #endif

    private var scale: CGFloat { size / 140 }
    private var outerRadius: CGFloat { 66 * scale }
    private var innerRadius: CGFloat { 54 * scale }
    private var outerStroke: CGFloat { 4 * scale }
    private var innerStroke: CGFloat { 3.5 * scale }
    private var mainFontSize: CGFloat { 26 * scale }
    private var subFontSize: CGFloat { 11 * scale }

    var body: some View {
        ZStack {
            // Outer ring: pomodoro block
            Circle()
                .stroke(Color.primary.opacity(0.04), lineWidth: outerStroke)
                .frame(width: outerRadius * 2, height: outerRadius * 2)
            Circle()
                .trim(from: 0, to: outerProgress)
                .stroke(
                    outerColor,
                    style: StrokeStyle(lineWidth: outerStroke, lineCap: .round)
                )
                .frame(width: outerRadius * 2, height: outerRadius * 2)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.3), value: outerProgress)

            // Inner ring: slice rotation
            Circle()
                .stroke(Color.primary.opacity(0.06), lineWidth: innerStroke)
                .frame(width: innerRadius * 2, height: innerRadius * 2)
            Circle()
                .trim(from: 0, to: sliceProgress)
                .stroke(
                    innerColor,
                    style: StrokeStyle(lineWidth: innerStroke, lineCap: .round)
                )
                .frame(width: innerRadius * 2, height: innerRadius * 2)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.3), value: sliceProgress)

            // Center text
            VStack(spacing: 1) {
                Text(sliceTimeFormatted)
                    .font(.system(size: mainFontSize, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(sliceIsOvertime ? Color(red: 0.7, green: 0.18, blue: 0.15) : .primary)
                    #if DEBUG
                        .onTapGesture {
                            guard NSEvent.modifierFlags.contains(.option) else { return }
                            onSliceTap?()
                        }
                    #endif
                Text(outerTimeFormatted)
                    .font(.system(size: subFontSize, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .contentShape(Rectangle())
                    #if DEBUG
                        .onTapGesture {
                            guard NSEvent.modifierFlags.contains(.option) else { return }
                            onBlockTap?()
                        }
                    #endif
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Slice timer")
        .accessibilityValue("\(sliceTimeFormatted) slice, \(outerTimeFormatted) block")
    }
}
