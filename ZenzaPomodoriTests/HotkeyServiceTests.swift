import Foundation
import Testing
@testable import ZenzaPomodori

@Suite("HotkeyService")
@MainActor
struct HotkeyServiceTests {
    private func makeSettings() -> SettingsStore {
        let defaults = UserDefaults(suiteName: "test-hotkey-\(UUID().uuidString)")!
        return SettingsStore(defaults: defaults)
    }

    @Test func defaultHotkeySettings() {
        let settings = makeSettings()
        #expect(settings.globalHotkeyEnabled == true)
        #expect(settings.globalHotkeyKeyCode == 6)
        #expect(settings.globalHotkeyModifiers == 4608)
    }

    @Test func hotkeySettingsPersist() {
        let suiteName = "test-hotkey-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let store1 = SettingsStore(defaults: defaults)
        store1.globalHotkeyEnabled = false
        store1.globalHotkeyKeyCode = 0
        store1.globalHotkeyModifiers = 256
        let store2 = SettingsStore(defaults: defaults)
        #expect(store2.globalHotkeyEnabled == false)
        #expect(store2.globalHotkeyKeyCode == 0)
        #expect(store2.globalHotkeyModifiers == 256)
    }

    @Test func serviceInitializesWithSettings() {
        let settings = makeSettings()
        let service = HotkeyService(settings: settings)
        #expect(service.isRegistered == false)
        #expect(service.registrationError == nil)
    }

    @Test func onHotkeySettingsChangedFiresOnEnabledChange() {
        let settings = makeSettings()
        var callCount = 0
        settings.onHotkeySettingsChanged = { callCount += 1 }
        settings.globalHotkeyEnabled = false
        #expect(callCount == 1)
    }

    @Test func onHotkeySettingsChangedFiresOnKeyCodeChange() {
        let settings = makeSettings()
        var callCount = 0
        settings.onHotkeySettingsChanged = { callCount += 1 }
        settings.globalHotkeyKeyCode = 0
        #expect(callCount == 1)
    }

    @Test func onHotkeySettingsChangedFiresOnModifiersChange() {
        let settings = makeSettings()
        var callCount = 0
        settings.onHotkeySettingsChanged = { callCount += 1 }
        settings.globalHotkeyModifiers = 256
        #expect(callCount == 1)
    }
}
