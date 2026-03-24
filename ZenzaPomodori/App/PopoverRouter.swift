import Foundation

enum PopoverPanel {
    case timer
    case settings
    case microBlockSetup
    case microBlockActive
    case microBlockTransition
}

@Observable
@MainActor
final class PopoverRouter {
    var activePanel: PopoverPanel = .timer
    var microBlockEngine: MicroBlockEngine?
}
