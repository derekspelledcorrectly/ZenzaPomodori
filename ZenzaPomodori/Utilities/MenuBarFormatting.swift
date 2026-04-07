import Foundation

struct SliceDisplayInfo {
    let sliceFormattedTime: String
    let outerFormattedTime: String
    let focusName: String?
    let position: Int
    let total: Int
    let showTimer: Bool
    let showSessionTimer: Bool
    let showPosition: Bool
    let showFocus: Bool
}

struct SliceFormattedResult {
    let timerPart: String
    let focusPart: String?
    let positionPart: String?
}

enum MenuBarFormatting {
    static func truncatedFocusName(_ name: String, maxLength: Int = 20) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if trimmed.count <= maxLength {
            return trimmed
        }
        return String(trimmed.prefix(maxLength)) + "..."
    }

    static func sliceFormatted(_ info: SliceDisplayInfo) -> SliceFormattedResult {
        let focus: String?
        if info.showFocus, let name = info.focusName, !name.isEmpty {
            let maxLen = info.showTimer ? 15 : 20
            focus = truncatedFocusName(name, maxLength: maxLen)
        } else {
            focus = nil
        }

        let position: String?
        if info.showPosition {
            position = "\(info.position)/\(info.total)"
        } else {
            position = nil
        }

        guard info.showTimer else {
            return SliceFormattedResult(timerPart: "", focusPart: focus, positionPart: position)
        }

        var parts = [info.sliceFormattedTime]
        if info.showSessionTimer {
            parts.append(info.outerFormattedTime)
        }

        return SliceFormattedResult(timerPart: parts.joined(separator: " · "), focusPart: focus, positionPart: position)
    }
}
