import Foundation

enum PopoverPanel {
    case timer
    case settings
    case sliceSetup
    case sliceActive
}

@Observable
@MainActor
final class PopoverRouter {
    var activePanel: PopoverPanel = .timer
    var sliceEngine: SliceEngine?
}
