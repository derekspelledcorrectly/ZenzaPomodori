import Foundation

enum MenuBarFormatting {
    static func truncatedFocusName(_ name: String, maxLength: Int = 20) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if trimmed.count <= maxLength {
            return trimmed
        }
        return String(trimmed.prefix(maxLength)) + "..."
    }
}
