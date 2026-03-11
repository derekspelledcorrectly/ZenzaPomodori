import Foundation
import Testing
@testable import ZenzaPomodori

@Suite("SettingsWindowManager")
@MainActor
struct SettingsWindowManagerTests {
    private func makeManager() -> SettingsWindowManager {
        let defaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let store = SettingsStore(defaults: defaults)
        return SettingsWindowManager(settings: store)
    }

    @Test func showSettingsCreatesWindow() {
        let manager = makeManager()
        manager.showSettings()
        #expect(manager.isWindowVisible)
    }

    @Test func showSettingsTwiceReusesSameWindow() {
        let manager = makeManager()
        manager.showSettings()
        manager.showSettings()
        #expect(manager.isWindowVisible)
    }
}
