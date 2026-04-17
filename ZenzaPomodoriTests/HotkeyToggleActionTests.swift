import Testing

@testable import ZenzaPomodori

@Suite("HotkeyToggleAction")
struct HotkeyToggleActionTests {
    @Test func hiddenPanelShowsAndActivates() {
        let action = hotkeyToggleAction(panelVisible: false, panelIsKey: false)
        #expect(action == .showActivated)
    }

    @Test func visibleKeyPanelHides() {
        let action = hotkeyToggleAction(panelVisible: true, panelIsKey: true)
        #expect(action == .hide)
    }

    @Test func visibleNonKeyPanelActivates() {
        let action = hotkeyToggleAction(panelVisible: true, panelIsKey: false)
        #expect(action == .activate)
    }
}
