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
        makeTestSettingsStore()
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

    @Test func defaultPopOnComplete() {
        let store = makeStore()
        #expect(store.popOnComplete == true)
    }

    @Test func defaultShowFocusInMenuBar() {
        let store = makeStore()
        #expect(store.showFocusInMenuBar == true)
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

    @Test func setPopOnComplete() {
        let store = makeStore()
        store.popOnComplete = false
        #expect(store.popOnComplete == false)
    }

    @Test func setShowFocusInMenuBar() {
        let store = makeStore()
        store.showFocusInMenuBar = false
        #expect(store.showFocusInMenuBar == false)
    }

    // MARK: - Persistence

    @Test func valuesPersistInUserDefaults() {
        let defaults = makeTestDefaults()

        let store1 = SettingsStore(defaults: defaults)
        store1.focusDuration = 45 * 60
        store1.autoAdvance = true
        store1.popOnComplete = false

        let store2 = SettingsStore(defaults: defaults)
        #expect(store2.focusDuration == 45 * 60)
        #expect(store2.autoAdvance == true)
        #expect(store2.popOnComplete == false)
    }

    @Test func showFocusInMenuBarPersists() {
        let defaults = makeTestDefaults()

        let store1 = SettingsStore(defaults: defaults)
        store1.showFocusInMenuBar = false

        let store2 = SettingsStore(defaults: defaults)
        #expect(store2.showFocusInMenuBar == false)
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

    // MARK: - Focus End Sound

    @Test func defaultFocusEndSound() {
        let store = makeStore()
        #expect(store.focusEndSound == "Reverie")
    }

    @Test func setFocusEndSound() {
        let store = makeStore()
        store.focusEndSound = "Glass"
        #expect(store.focusEndSound == "Glass")
    }

    @Test func focusEndSoundPersists() {
        let defaults = makeTestDefaults()
        let store1 = SettingsStore(defaults: defaults)
        store1.focusEndSound = "Sharp"
        let store2 = SettingsStore(defaults: defaults)
        #expect(store2.focusEndSound == "Sharp")
    }

    // MARK: - Break End Sound

    @Test func defaultBreakEndSound() {
        let store = makeStore()
        #expect(store.breakEndSound == "Cloud")
    }

    @Test func setBreakEndSound() {
        let store = makeStore()
        store.breakEndSound = "Polite"
        #expect(store.breakEndSound == "Polite")
    }

    @Test func breakEndSoundPersists() {
        let defaults = makeTestDefaults()
        let store1 = SettingsStore(defaults: defaults)
        store1.breakEndSound = "Reverie"
        let store2 = SettingsStore(defaults: defaults)
        #expect(store2.breakEndSound == "Reverie")
    }

    // MARK: - Notifications Enabled

    @Test func defaultNotificationsEnabled() {
        let store = makeStore()
        #expect(store.notificationsEnabled == false)
    }

    @Test func setNotificationsEnabled() {
        let store = makeStore()
        store.notificationsEnabled = true
        #expect(store.notificationsEnabled == true)
    }

    @Test func notificationsEnabledPersists() {
        let defaults = makeTestDefaults()
        let store1 = SettingsStore(defaults: defaults)
        store1.notificationsEnabled = true
        let store2 = SettingsStore(defaults: defaults)
        #expect(store2.notificationsEnabled == true)
    }

    // MARK: - Auto-Dismiss Seconds

    @Test func defaultAutoDismissSeconds() {
        let store = makeStore()
        #expect(store.autoDismissSeconds == 5)
    }

    @Test func setAutoDismissSeconds() {
        let store = makeStore()
        store.autoDismissSeconds = 10
        #expect(store.autoDismissSeconds == 10)
    }

    @Test func autoDismissSecondsClampsToZero() {
        let store = makeStore()
        store.autoDismissSeconds = -3
        #expect(store.autoDismissSeconds == 0)
    }

    @Test func autoDismissSecondsClampsToThirty() {
        let store = makeStore()
        store.autoDismissSeconds = 60
        #expect(store.autoDismissSeconds == 30)
    }

    @Test func autoDismissSecondsPersists() {
        let defaults = makeTestDefaults()
        let store1 = SettingsStore(defaults: defaults)
        store1.autoDismissSeconds = 15
        let store2 = SettingsStore(defaults: defaults)
        #expect(store2.autoDismissSeconds == 15)
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

    // MARK: - Slice Auto-Advance

    @Test func defaultSliceAutoAdvance() {
        let store = makeStore()
        #expect(store.sliceAutoAdvance == true)
    }

    @Test func setSliceAutoAdvance() {
        let store = makeStore()
        store.sliceAutoAdvance = false
        #expect(store.sliceAutoAdvance == false)
    }

    @Test func sliceAutoAdvancePersists() {
        let defaults = makeTestDefaults()
        let store1 = SettingsStore(defaults: defaults)
        store1.sliceAutoAdvance = false
        let store2 = SettingsStore(defaults: defaults)
        #expect(store2.sliceAutoAdvance == false)
    }

    // MARK: - Focus Overtime Reminder

    @Test func defaultFocusOvertimeReminderInterval() {
        let store = makeStore()
        #expect(store.focusOvertimeReminderInterval == 300)
    }

    @Test func setFocusOvertimeReminderInterval() {
        let store = makeStore()
        store.focusOvertimeReminderInterval = 600
        #expect(store.focusOvertimeReminderInterval == 600)
    }

    @Test func focusOvertimeReminderIntervalClampsLow() {
        let store = makeStore()
        store.focusOvertimeReminderInterval = 30
        #expect(store.focusOvertimeReminderInterval == 60)
    }

    @Test func focusOvertimeReminderIntervalClampsHigh() {
        let store = makeStore()
        store.focusOvertimeReminderInterval = 2000
        #expect(store.focusOvertimeReminderInterval == 1200)
    }

    @Test func defaultFocusOvertimeReminderSound() {
        let store = makeStore()
        #expect(store.focusOvertimeReminderSound == "Glass")
    }

    @Test func setFocusOvertimeReminderSound() {
        let store = makeStore()
        store.focusOvertimeReminderSound = "Sharp"
        #expect(store.focusOvertimeReminderSound == "Sharp")
    }

    // MARK: - Slice Overtime Reminder

    @Test func defaultSliceOvertimeReminderInterval() {
        let store = makeStore()
        #expect(store.sliceOvertimeReminderInterval == 20)
    }

    @Test func setSliceOvertimeReminderInterval() {
        let store = makeStore()
        store.sliceOvertimeReminderInterval = 30
        #expect(store.sliceOvertimeReminderInterval == 30)
    }

    @Test func sliceOvertimeReminderIntervalClampsLow() {
        let store = makeStore()
        store.sliceOvertimeReminderInterval = 2
        #expect(store.sliceOvertimeReminderInterval == 5)
    }

    @Test func sliceOvertimeReminderIntervalClampsHigh() {
        let store = makeStore()
        store.sliceOvertimeReminderInterval = 120
        #expect(store.sliceOvertimeReminderInterval == 60)
    }

    @Test func defaultSliceOvertimeReminderSound() {
        let store = makeStore()
        #expect(store.sliceOvertimeReminderSound == "Sharp")
    }

    @Test func setSliceOvertimeReminderSound() {
        let store = makeStore()
        store.sliceOvertimeReminderSound = "Glass"
        #expect(store.sliceOvertimeReminderSound == "Glass")
    }
}
