import Foundation

enum MenuBarFormatting {
    static func truncatedFocusName(_ name: String, maxLength: Int = 20) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if trimmed.count <= maxLength {
            return trimmed
        }
        return String(trimmed.prefix(maxLength)) + "..."
    }

    static func microBlockFormatted(
        microSeconds: Int,
        outerFormattedTime: String,
        focusName: String?,
        position: Int,
        total: Int,
        format: MicroBlockMenuBarFormat,
        showTimer: Bool,
        showFocus: Bool
    ) -> String {
        guard showTimer else {
            if showFocus, let name = focusName {
                return truncatedFocusName(name, maxLength: 20)
            }
            return ""
        }

        let micro = TimeFormatting.formatted(seconds: microSeconds)
        let name = (showFocus && focusName != nil)
            ? " \(truncatedFocusName(focusName!, maxLength: 15))"
            : ""

        switch format {
        case .microOnly:
            return "\(micro)\(name)"
        case .dualTimer:
            return "\(micro)/\(outerFormattedTime)\(name)"
        case .microPosition:
            return "\(micro) [\(position)/\(total)]\(name)"
        case .compact:
            return micro
        }
    }
}
