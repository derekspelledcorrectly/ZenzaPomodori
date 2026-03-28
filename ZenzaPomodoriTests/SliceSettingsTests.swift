import Foundation
import Testing
@testable import ZenzaPomodori

@Suite("Slice Settings")
struct SliceSettingsTests {
    private func makeStore() -> SettingsStore {
        let suiteName = "test-settings-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        return SettingsStore(defaults: defaults)
    }

    @Test func defaultSlicesEnabled() {
        let store = makeStore()
        #expect(store.slicesEnabled == false)
    }
    @Test func defaultMicroRotationInterval() {
        let store = makeStore()
        #expect(store.microRotationInterval == 180)
    }
    @Test func defaultSliceSoundEnabled() {
        let store = makeStore()
        #expect(store.sliceSoundEnabled == true)
    }
    @Test func defaultSliceEndSound() {
        let store = makeStore()
        #expect(store.sliceEndSound == "Taptap")
    }
    @Test func defaultStealFocusOnRotation() {
        let store = makeStore()
        #expect(store.stealFocusOnRotation == false)
    }
    @Test func defaultSliceMenuBarFormat() {
        let store = makeStore()
        #expect(store.sliceMenuBarFormat == .dualTimer)
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
    @Test func sliceSettingsPersist() {
        let suiteName = "test-settings-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let store1 = SettingsStore(defaults: defaults)
        store1.slicesEnabled = true
        store1.microRotationInterval = 120
        store1.sliceEndSound = "Glass"
        store1.lastBlockType = .slices
        store1.sliceMenuBarFormat = .compact
        let store2 = SettingsStore(defaults: defaults)
        #expect(store2.slicesEnabled == true)
        #expect(store2.microRotationInterval == 120)
        #expect(store2.sliceEndSound == "Glass")
        #expect(store2.lastBlockType == .slices)
        #expect(store2.sliceMenuBarFormat == .compact)
    }
}
