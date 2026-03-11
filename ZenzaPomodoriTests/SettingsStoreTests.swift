import Foundation
import Testing
@testable import ZenzaPomodori

private final class MutableBox<T>: @unchecked Sendable {
    var value: T
    init(_ value: T) { self.value = value }
}

@Suite("SettingsStore")
struct SettingsStoreTests {
    private func makeStore() -> SettingsStore {
        let suiteName = "test-settings-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        return SettingsStore(defaults: defaults)
    }

    // MARK: - Default Values

    @Test func defaultFocusDuration() {
        let store = makeStore()
        #expect(store.focusDuration == Defaults.focusDuration)
    }

    @Test func defaultShortBreakDuration() {
        let store = makeStore()
        #expect(store.shortBreakDuration == Defaults.shortBreakDuration)
    }

    @Test func defaultLongBreakDuration() {
        let store = makeStore()
        #expect(store.longBreakDuration == Defaults.longBreakDuration)
    }

    @Test func defaultBlocksBeforeLongBreak() {
        let store = makeStore()
        #expect(store.blocksBeforeLongBreak == Defaults.blocksBeforeLongBreak)
    }

    @Test func defaultAutoAdvance() {
        let store = makeStore()
        #expect(store.autoAdvance == false)
    }

    @Test func defaultSoundEnabled() {
        let store = makeStore()
        #expect(store.soundEnabled == true)
    }

    // MARK: - Read/Write

    @Test func setFocusDuration() {
        let store = makeStore()
        store.focusDuration = 30 * 60
        #expect(store.focusDuration == 30 * 60)
    }

    @Test func setShortBreakDuration() {
        let store = makeStore()
        store.shortBreakDuration = 10 * 60
        #expect(store.shortBreakDuration == 10 * 60)
    }

    @Test func setLongBreakDuration() {
        let store = makeStore()
        store.longBreakDuration = 30 * 60
        #expect(store.longBreakDuration == 30 * 60)
    }

    @Test func setBlocksBeforeLongBreak() {
        let store = makeStore()
        store.blocksBeforeLongBreak = 6
        #expect(store.blocksBeforeLongBreak == 6)
    }

    @Test func setAutoAdvance() {
        let store = makeStore()
        store.autoAdvance = true
        #expect(store.autoAdvance == true)
    }

    @Test func setSoundEnabled() {
        let store = makeStore()
        store.soundEnabled = false
        #expect(store.soundEnabled == false)
    }

    // MARK: - Persistence

    @Test func valuesPersistInUserDefaults() {
        let suiteName = "test-settings-persist-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!

        let store1 = SettingsStore(defaults: defaults)
        store1.focusDuration = 45 * 60
        store1.autoAdvance = true

        let store2 = SettingsStore(defaults: defaults)
        #expect(store2.focusDuration == 45 * 60)
        #expect(store2.autoAdvance == true)
    }

    // MARK: - Validation

    @Test func focusDurationMinimum() {
        let store = makeStore()
        store.focusDuration = 30
        #expect(store.focusDuration == 60)
    }

    @Test func blocksBeforeLongBreakMinimum() {
        let store = makeStore()
        store.blocksBeforeLongBreak = 0
        #expect(store.blocksBeforeLongBreak == 1)
    }

    // MARK: - Observation

    @Test func observationTracksChanges() {
        let store = makeStore()
        let changed = MutableBox(false)

        withObservationTracking {
            _ = store.focusDuration
        } onChange: {
            changed.value = true
        }

        store.focusDuration = 30 * 60
        #expect(changed.value == true)
    }
}
