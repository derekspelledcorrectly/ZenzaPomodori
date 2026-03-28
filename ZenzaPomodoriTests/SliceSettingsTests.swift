import Foundation
import Testing
@testable import ZenzaPomodori

@Suite("MicroBlock Settings")
struct MicroBlockSettingsTests {
    private func makeStore() -> SettingsStore {
        let suiteName = "test-settings-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        return SettingsStore(defaults: defaults)
    }

    @Test func defaultMicroBlocksEnabled() {
        let store = makeStore()
        #expect(store.microBlocksEnabled == false)
    }
    @Test func defaultMicroRotationInterval() {
        let store = makeStore()
        #expect(store.microRotationInterval == 180)
    }
    @Test func defaultMicroBlockSoundEnabled() {
        let store = makeStore()
        #expect(store.microBlockSoundEnabled == true)
    }
    @Test func defaultMicroBlockEndSound() {
        let store = makeStore()
        #expect(store.microBlockEndSound == "Taptap")
    }
    @Test func defaultStealFocusOnRotation() {
        let store = makeStore()
        #expect(store.stealFocusOnRotation == false)
    }
    @Test func defaultMicroBlockMenuBarFormat() {
        let store = makeStore()
        #expect(store.microBlockMenuBarFormat == .dualTimer)
    }
    @Test func defaultLastBlockType() {
        let store = makeStore()
        #expect(store.lastBlockType == .regular)
    }
    @Test func microRotationIntervalClampsMin() {
        let store = makeStore()
        store.microRotationInterval = 30
        #expect(store.microRotationInterval == 60)
    }
    @Test func microRotationIntervalClampsMax() {
        let store = makeStore()
        store.microRotationInterval = 900
        #expect(store.microRotationInterval == 600)
    }
    @Test func microBlockSettingsPersist() {
        let suiteName = "test-settings-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let store1 = SettingsStore(defaults: defaults)
        store1.microBlocksEnabled = true
        store1.microRotationInterval = 120
        store1.microBlockEndSound = "Glass"
        store1.lastBlockType = .microBlocks
        store1.microBlockMenuBarFormat = .compact
        let store2 = SettingsStore(defaults: defaults)
        #expect(store2.microBlocksEnabled == true)
        #expect(store2.microRotationInterval == 120)
        #expect(store2.microBlockEndSound == "Glass")
        #expect(store2.lastBlockType == .microBlocks)
        #expect(store2.microBlockMenuBarFormat == .compact)
    }
}
