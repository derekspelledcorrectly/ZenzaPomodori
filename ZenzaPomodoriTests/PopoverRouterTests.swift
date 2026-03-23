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

    @Test func microBlockSetupPanel() {
        let router = PopoverRouter()
        router.activePanel = .microBlockSetup
        #expect(router.activePanel == .microBlockSetup)
    }

    @Test func microBlockActivePanel() {
        let router = PopoverRouter()
        router.activePanel = .microBlockActive
        #expect(router.activePanel == .microBlockActive)
    }

    @Test func microBlockTransitionPanel() {
        let router = PopoverRouter()
        router.activePanel = .microBlockTransition
        #expect(router.activePanel == .microBlockTransition)
    }
}
