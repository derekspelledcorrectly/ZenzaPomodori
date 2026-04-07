import Foundation

struct SliceDisplayInfo {
    let sliceFormattedTime: String
    let outerFormattedTime: String
    let focusName: String?
    let position: Int
    let total: Int
    let format: SliceMenuBarFormat
    let showTimer: Bool
    let showFocus: Bool
}

struct SliceFormattedResult {
    let timerPart: String
    let focusPart: String?
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

        guard info.showTimer else {
            return SliceFormattedResult(timerPart: "", focusPart: focus)
        }

        let slice = info.sliceFormattedTime

        let timerPart: String
        switch info.format {
        case .sliceOnly:
            timerPart = slice
        case .dualTimer:
            timerPart = "\(slice) · \(info.outerFormattedTime)"
        case .slicePosition:
            timerPart = "\(slice) · \(info.position)/\(info.total)"
        case .compact:
            return SliceFormattedResult(timerPart: slice, focusPart: nil)
        }

        return SliceFormattedResult(timerPart: timerPart, focusPart: focus)
    }
}
