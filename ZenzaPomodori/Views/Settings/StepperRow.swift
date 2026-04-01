import SwiftUI

struct StepperRow: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    var formatter: ((Int) -> String)? = nil

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            HStack(spacing: 4) {
                Button(action: { value -= 1 }) {
                    Image(systemName: "minus")
                }
                .disabled(value <= range.lowerBound)
                .accessibilityLabel("Decrease \(label)")

                Text(displayValue)
                    .monospacedDigit()
                    .frame(minWidth: 30, alignment: .center)

                Button(action: { value += 1 }) {
                    Image(systemName: "plus")
                }
                .disabled(value >= range.upperBound)
                .accessibilityLabel("Increase \(label)")
            }
        }
    }

    private var displayValue: String {
        formatter?(value) ?? "\(value)"
    }
}
