import Foundation

enum TimeFormatting {
    static func formatted(seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    static func shortFormatted(seconds: Int) -> String {
        let minutes = (seconds + 59) / 60
        return "\(minutes)m"
    }
}
