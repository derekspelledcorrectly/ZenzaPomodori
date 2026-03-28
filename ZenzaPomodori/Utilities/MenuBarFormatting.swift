import Foundation

enum MenuBarFormatting {
    static func truncatedFocusName(_ name: String, maxLength: Int = 20) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if trimmed.count <= maxLength {
            return trimmed
        }
        return String(trimmed.prefix(maxLength)) + "..."
    }

    static func sliceFormatted(
        sliceSeconds: Int,
        outerFormattedTime: String,
        focusName: String?,
        position: Int,
        total: Int,
        format: SliceMenuBarFormat,
        showTimer: Bool,
        showFocus: Bool
    ) -> String {
        guard showTimer else {
            if showFocus, let name = focusName {
                return truncatedFocusName(name, maxLength: 20)
            }
            return ""
        }

        let slice = TimeFormatting.formatted(seconds: sliceSeconds)
        let name: String
        if showFocus, let focusName {
            name = " [\(truncatedFocusName(focusName, maxLength: 15))]"
        } else {
            name = ""
        }

        switch format {
        case .sliceOnly:
            return "\(slice)\(name)"
        case .dualTimer:
            return "\(slice)/\(outerFormattedTime)\(name)"
        case .slicePosition:
            return "\(slice) \(position)/\(total)\(name)"
        case .compact:
            return slice
        }
    }
}
