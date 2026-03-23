import SwiftUI

struct ConcentricTimerView: View {
    let microProgress: Double
    let outerProgress: Double
    let microTimeFormatted: String
    let outerTimeFormatted: String

    private let size: CGFloat = 64
    private let outerRadius: CGFloat = 29
    private let innerRadius: CGFloat = 21
    private let outerStroke: CGFloat = 3
    private let innerStroke: CGFloat = 4.5

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.18), lineWidth: outerStroke)
                .frame(width: outerRadius * 2, height: outerRadius * 2)
            Circle()
                .trim(from: 0, to: outerProgress)
                .stroke(
                    Color(.sRGB, red: 0.29, green: 0.44, blue: 0.65).opacity(0.7),
                    style: StrokeStyle(lineWidth: outerStroke, lineCap: .round)
                )
                .frame(width: outerRadius * 2, height: outerRadius * 2)
                .rotationEffect(.degrees(-90))

            Circle()
                .stroke(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.18), lineWidth: innerStroke)
                .frame(width: innerRadius * 2, height: innerRadius * 2)
            Circle()
                .trim(from: 0, to: microProgress)
                .stroke(
                    Color(.sRGB, red: 0.91, green: 0.27, blue: 0.38),
                    style: StrokeStyle(lineWidth: innerStroke, lineCap: .round)
                )
                .frame(width: innerRadius * 2, height: innerRadius * 2)
                .rotationEffect(.degrees(-90))

            Text(microTimeFormatted)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(.primary)
        }
        .frame(width: size, height: size)
    }
}
