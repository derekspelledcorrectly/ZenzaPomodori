import Foundation

enum PopoverPanel {
    case timer
    case settings
    case sliceSetup
    case sliceActive
    case sliceTransition
}

@Observable
@MainActor
final class PopoverRouter {
    var activePanel: PopoverPanel = .timer
    var sliceEngine: SliceEngine?
    var transitionDismissed: Bool = false
}
