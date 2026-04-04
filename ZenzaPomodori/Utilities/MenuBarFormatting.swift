import Foundation

struct SliceDisplayInfo {
    let sliceSeconds: Int
    let outerFormattedTime: String
    let focusName: String?
    let position: Int
    let total: Int
    let format: SliceMenuBarFormat
    let showTimer: Bool
    let showFocus: Bool
    var isOvertime: Bool = false
    var overtimeSeconds: Int = 0
}

enum MenuBarFormatting {
    static func truncatedFocusName(_ name: String, maxLength: Int = 20) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if trimmed.count <= maxLength {
            return trimmed
        }
        return String(trimmed.prefix(maxLength)) + "..."
    }

    static func sliceFormatted(_ info: SliceDisplayInfo) -> String {
        guard info.showTimer else {
            if info.showFocus, let name = info.focusName {
                return truncatedFocusName(name, maxLength: 20)
            }
            return ""
        }

        let slice = info.isOvertime
            ? "+\(TimeFormatting.formatted(seconds: info.overtimeSeconds))"
            : TimeFormatting.formatted(seconds: info.sliceSeconds)
        let name: String
        if info.showFocus, let focusName = info.focusName {
            name = " [\(truncatedFocusName(focusName, maxLength: 15))]"
        } else {
            name = ""
        }

        switch info.format {
        case .sliceOnly:
            return "\(slice)\(name)"
        case .dualTimer:
            return "\(slice)/\(info.outerFormattedTime)\(name)"
        case .slicePosition:
            return "\(slice) \(info.position)/\(info.total)\(name)"
        case .compact:
            return slice
        }
    }
}
