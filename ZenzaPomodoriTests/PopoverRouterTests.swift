import Testing
@testable import ZenzaPomodori

@Suite("PopoverRouter")
@MainActor
struct PopoverRouterTests {
    @Test func defaultsToTimerPanel() {
        let router = PopoverRouter()
        #expect(router.activePanel == .timer)
    }

    @Test func canSwitchToSettings() {
        let router = PopoverRouter()
        router.activePanel = .settings
        #expect(router.activePanel == .settings)
    }

    @Test func canSwitchBackToTimer() {
        let router = PopoverRouter()
        router.activePanel = .settings
        router.activePanel = .timer
        #expect(router.activePanel == .timer)
    }

    @Test func sliceSetupPanel() {
        let router = PopoverRouter()
        router.activePanel = .sliceSetup
        #expect(router.activePanel == .sliceSetup)
    }

    @Test func sliceActivePanel() {
        let router = PopoverRouter()
        router.activePanel = .sliceActive
        #expect(router.activePanel == .sliceActive)
    }

    @Test func canSwitchToShortcuts() {
        let router = PopoverRouter()
        router.activePanel = .shortcuts
        #expect(router.activePanel == .shortcuts)
    }

    @Test func returnToContextPanel_fromTimer() {
        let router = PopoverRouter()
        router.activePanel = .timer
        let result = router.returnToContextPanel(sliceEngineActive: false, lastBlockType: .focus)
        #expect(result == .timer)
    }

    @Test func returnToContextPanel_fromSliceActive() {
        let router = PopoverRouter()
        let result = router.returnToContextPanel(sliceEngineActive: true, lastBlockType: .slices)
        #expect(result == .sliceActive)
    }

    @Test func returnToContextPanel_fromSliceSetup() {
        let router = PopoverRouter()
        let result = router.returnToContextPanel(sliceEngineActive: false, lastBlockType: .slices)
        #expect(result == .sliceSetup)
    }

    @Test func returnToContextPanel_defaultsToTimer() {
        let router = PopoverRouter()
        let result = router.returnToContextPanel(sliceEngineActive: false, lastBlockType: .focus)
        #expect(result == .timer)
    }

}
