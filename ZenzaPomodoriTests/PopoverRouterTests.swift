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

}
