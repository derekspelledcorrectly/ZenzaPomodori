import Foundation

enum PopoverPanel {
    case timer
    case settings
}

@Observable
@MainActor
final class PopoverRouter {
    var activePanel: PopoverPanel = .timer
}
