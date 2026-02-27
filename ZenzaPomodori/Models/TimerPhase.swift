import Foundation

enum TimerPhase: Equatable, Sendable {
    case idle
    case focus(block: Int)
    case shortBreak(afterBlock: Int)
    case longBreak

    var label: String {
        switch self {
        case .idle:
            "Idle"
        case .focus(let block):
            "Focus \(block)/\(Defaults.blocksBeforeLongBreak)"
        case .shortBreak:
            "Short Break"
        case .longBreak:
            "Long Break"
        }
    }

    var isFocus: Bool {
        if case .focus = self { return true }
        return false
    }

    var isBreak: Bool {
        switch self {
        case .shortBreak, .longBreak: true
        default: false
        }
    }
}
