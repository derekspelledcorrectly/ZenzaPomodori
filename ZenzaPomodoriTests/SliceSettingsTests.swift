import Foundation
import Testing
@testable import ZenzaPomodori

@Suite("Slice Settings")
struct SliceSettingsTests {
    private func makeStore() -> SettingsStore {
        makeTestSettingsStore()
    }

    @Test func defaultSlicesEnabled() {
        let store = makeStore()
        #expect(store.slicesEnabled == true)
    }
    @Test func defaultSliceRotationInterval() {
        let store = makeStore()
        #expect(store.sliceRotationInterval == 120)
    }
    @Test func defaultSliceSoundEnabled() {
        let store = makeStore()
        #expect(store.sliceSoundEnabled == true)
    }
    @Test func defaultSliceEndSound() {
        let store = makeStore()
        #expect(store.sliceEndSound == "Polite")
    }
    @Test func defaultStealFocusOnPop() {
        let store = makeStore()
        #expect(store.stealFocusOnPop == false)
    }
    @Test func defaultShowSliceTimerInMenuBar() {
        let store = makeStore()
        #expect(store.showSliceTimerInMenuBar == true)
    }
    @Test func defaultShowSliceFocusInMenuBar() {
        let store = makeStore()
        #expect(store.showSliceFocusInMenuBar == true)
    }
    @Test func defaultShowSessionTimerInMenuBar() {
        let store = makeStore()
        #expect(store.showSessionTimerInMenuBar == false)
    }
    @Test func defaultShowSlicePositionInMenuBar() {
        let store = makeStore()
        #expect(store.showSlicePositionInMenuBar == false)
    }
    @Test func defaultLastBlockType() {
        let store = makeStore()
        #expect(store.lastBlockType == .focus)
    }
    @Test func sliceRotationIntervalClampsMin() {
        let store = makeStore()
        store.sliceRotationInterval = 30
        #expect(store.sliceRotationInterval == 60)
    }
    @Test func sliceRotationIntervalClampsMax() {
        let store = makeStore()
        store.sliceRotationInterval = 900
        #expect(store.sliceRotationInterval == 600)
    }
    @Test func stealFocusOnPopPersists() {
        let defaults = makeTestDefaults()
        let store1 = SettingsStore(defaults: defaults)
        store1.stealFocusOnPop = true
        let store2 = SettingsStore(defaults: defaults)
        #expect(store2.stealFocusOnPop == true)
    }
    @Test func sliceSettingsPersist() {
        let defaults = makeTestDefaults()
        let store1 = SettingsStore(defaults: defaults)
        store1.slicesEnabled = true
        store1.sliceRotationInterval = 120
        store1.sliceEndSound = "Glass"
        store1.lastBlockType = .slices
        store1.showSliceTimerInMenuBar = false
        store1.showSliceFocusInMenuBar = false
        store1.showSessionTimerInMenuBar = true
        store1.showSlicePositionInMenuBar = true
        let store2 = SettingsStore(defaults: defaults)
        #expect(store2.slicesEnabled == true)
        #expect(store2.sliceRotationInterval == 120)
        #expect(store2.sliceEndSound == "Glass")
        #expect(store2.lastBlockType == .slices)
        #expect(store2.showSliceTimerInMenuBar == false)
        #expect(store2.showSliceFocusInMenuBar == false)
        #expect(store2.showSessionTimerInMenuBar == true)
        #expect(store2.showSlicePositionInMenuBar == true)
    }
}
