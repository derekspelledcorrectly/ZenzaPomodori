import Foundation

enum PopoverPanel {
    case timer
    case settings
    case sliceSetup
    case sliceActive
    case shortcuts
}

@Observable
@MainActor
final class PopoverRouter {
    var activePanel: PopoverPanel = .timer
    var sliceEngine: SliceEngine?

    func returnToContextPanel(sliceEngineActive: Bool, lastBlockType: BlockType) -> PopoverPanel {
        if sliceEngineActive {
            return .sliceActive
        } else if lastBlockType == .slices {
            return .sliceSetup
        } else {
            return .timer
        }
    }
}
