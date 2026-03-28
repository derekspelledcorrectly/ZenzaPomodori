import Testing
import AppKit
@testable import ZenzaPomodori

@Suite("FloatingPanel")
@MainActor
struct FloatingPanelTests {
    @Test func hasNonActivatingPanelStyleMask() {
        let panel = FloatingPanel()
        #expect(panel.styleMask.contains(.nonactivatingPanel))
    }

    @Test func hasBorderlessStyleMask() {
        let panel = FloatingPanel()
        #expect(panel.styleMask.contains(.borderless))
    }

    @Test func hasFullSizeContentViewStyleMask() {
        let panel = FloatingPanel()
        #expect(panel.styleMask.contains(.fullSizeContentView))
    }

    @Test func windowLevelIsPopUpMenu() {
        let panel = FloatingPanel()
        #expect(panel.level == .popUpMenu)
    }

    @Test func canBecomeKeyIsTrue() {
        let panel = FloatingPanel()
        #expect(panel.canBecomeKey == true)
    }

    @Test func canBecomeMainIsFalse() {
        let panel = FloatingPanel()
        #expect(panel.canBecomeMain == false)
    }

    @Test func doesNotHideOnDeactivate() {
        let panel = FloatingPanel()
        #expect(panel.hidesOnDeactivate == false)
    }

    @Test func isNotOpaque() {
        let panel = FloatingPanel()
        #expect(panel.isOpaque == false)
    }

    @Test func backgroundColorIsClear() {
        let panel = FloatingPanel()
        #expect(panel.backgroundColor == .clear)
    }

    @Test func hasShadow() {
        let panel = FloatingPanel()
        #expect(panel.hasShadow == true)
    }

    @Test func isNotMovableByWindowBackground() {
        let panel = FloatingPanel()
        #expect(panel.isMovableByWindowBackground == false)
    }

    @Test func cancelOperationCallsOnClose() {
        let panel = FloatingPanel()
        var called = false
        panel.onClose = { called = true }
        panel.cancelOperation(nil)
        #expect(called)
    }
}
