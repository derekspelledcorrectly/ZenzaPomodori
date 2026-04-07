import Foundation
import Testing
@testable import ZenzaPomodori

@Suite("SliceEngine")
@MainActor
struct SliceEngineTests {
    private func makeEngine(
        items: [RotationItem]? = nil,
        interval: Int = 180,
        autoAdvance: Bool = true,
        settings: SettingsStore? = nil
    ) -> SliceEngine {
        let defaultItems = items ?? [
            RotationItem(name: "API"),
            RotationItem(name: "CI"),
            RotationItem(name: "Frontend"),
        ]
        return SliceEngine(
            items: defaultItems,
            interval: interval,
            autoAdvance: autoAdvance,
            settings: settings ?? makeTestSettingsStore()
        )
    }

    // MARK: - Initial State
    @Test func startsInactive() {
        let engine = makeEngine()
        #expect(engine.isActive == false)
        #expect(engine.isPaused == false)
        #expect(engine.currentIndex == 0)
    }

    @Test func storesItemsAndInterval() {
        let engine = makeEngine(interval: 120)
        #expect(engine.rotationItems.count == 3)
        #expect(engine.interval == 120)
    }

    // MARK: - Activation
    @Test func activateSetsFirstItemAndCountdown() {
        let engine = makeEngine(interval: 180)
        engine.activate()
        #expect(engine.isActive == true)
        #expect(engine.currentIndex == 0)
        #expect(engine.sliceSecondsRemaining == 180)
        #expect(engine.currentItemName == "API")
        engine.deactivate()
    }

    @Test func activateWhileActiveIsNoOp() {
        let engine = makeEngine()
        engine.activate()
        engine.tick()
        engine.activate()
        #expect(engine.sliceSecondsRemaining == 179)
        engine.deactivate()
    }

    @Test func deactivateResetsState() {
        let engine = makeEngine()
        engine.activate()
        engine.tick()
        engine.deactivate()
        #expect(engine.isActive == false)
        #expect(engine.currentIndex == 0)
        #expect(engine.sliceSecondsRemaining == 0)
    }

    // MARK: - Tick
    @Test func tickDecrementsCountdown() {
        let engine = makeEngine(interval: 180)
        engine.activate()
        engine.tick()
        #expect(engine.sliceSecondsRemaining == 179)
        engine.deactivate()
    }

    @Test func tickWhileInactiveIsNoOp() {
        let engine = makeEngine()
        engine.tick()
        #expect(engine.sliceSecondsRemaining == 0)
    }

    @Test func tickWhilePausedIsNoOp() {
        let engine = makeEngine(interval: 180)
        engine.activate()
        engine.pause()
        engine.tick()
        #expect(engine.sliceSecondsRemaining == 180)
        engine.deactivate()
    }

    // MARK: - Rotation
    @Test func tickToZeroAdvancesToNextItem() {
        let engine = makeEngine(interval: 3)
        engine.activate()
        advanceEngine(engine, ticks: 3)
        #expect(engine.currentIndex == 1)
        #expect(engine.currentItemName == "CI")
        #expect(engine.sliceSecondsRemaining == 3)
        engine.deactivate()
    }

    @Test func rotationLoopsBackToFirst() {
        let engine = makeEngine(interval: 1)
        engine.activate()
        advanceEngine(engine, ticks: 3)
        #expect(engine.currentIndex == 0)
        #expect(engine.currentItemName == "API")
        engine.deactivate()
    }

    @Test func rotationChangeCallbackFires() {
        let engine = makeEngine(interval: 1)
        var changes: [(Int, String)] = []
        engine.onRotationChange = { index, name in changes.append((index, name)) }
        engine.activate()
        engine.tick()
        #expect(changes.count == 1)
        #expect(changes[0].0 == 1)
        #expect(changes[0].1 == "CI")
        engine.deactivate()
    }

    @Test func rotationCompleteCallbackFires() {
        let engine = makeEngine(interval: 1)
        var completeCount = 0
        engine.onRotationComplete = { completeCount += 1 }
        engine.activate()
        engine.tick()
        #expect(completeCount == 1)
        engine.deactivate()
    }

    // MARK: - Skip
    @Test func skipAdvancesImmediately() {
        let engine = makeEngine(interval: 180)
        engine.activate()
        engine.tick()
        engine.skip()
        #expect(engine.currentIndex == 1)
        #expect(engine.currentItemName == "CI")
        #expect(engine.sliceSecondsRemaining == 180)
        engine.deactivate()
    }

    @Test func skipWhileInactiveIsNoOp() {
        let engine = makeEngine()
        engine.skip()
        #expect(engine.currentIndex == 0)
    }

    // MARK: - Pause / Resume
    @Test func pauseAndResume() {
        let engine = makeEngine(interval: 180)
        engine.activate()
        engine.tick()
        engine.pause()
        #expect(engine.isPaused == true)
        engine.tick()
        #expect(engine.sliceSecondsRemaining == 179)
        engine.resume()
        #expect(engine.isPaused == false)
        engine.tick()
        #expect(engine.sliceSecondsRemaining == 178)
        engine.deactivate()
    }

    // MARK: - Edge Cases
    @Test func singleItemRotation() {
        let engine = makeEngine(items: [RotationItem(name: "Solo")], interval: 1)
        engine.activate()
        engine.tick()
        #expect(engine.currentIndex == 0)
        #expect(engine.currentItemName == "Solo")
        engine.deactivate()
    }

    @Test func emptyItemsActivateIsNoOp() {
        let engine = SliceEngine(items: [], interval: 180, settings: makeTestSettingsStore())
        engine.activate()
        #expect(engine.isActive == false)
        #expect(engine.currentItemName == nil)
    }

    @Test func skipFiresRotationChangeCallback() {
        let engine = makeEngine(interval: 180)
        var changes: [(Int, String)] = []
        engine.onRotationChange = { index, name in changes.append((index, name)) }
        engine.activate()
        engine.skip()
        #expect(changes.count == 1)
        #expect(changes[0].1 == "CI")
        engine.deactivate()
    }

    // MARK: - Progress
    @Test func progressCalculation() {
        let engine = makeEngine(interval: 100)
        engine.activate()
        #expect(engine.progress == 0.0)
        advanceEngine(engine, ticks: 50)
        #expect(engine.progress == 0.5)
        engine.deactivate()
    }

    @Test func nextItemName() {
        let engine = makeEngine()
        engine.activate()
        #expect(engine.nextItemName == "CI")
        engine.deactivate()
    }

    // MARK: - Update Items

    @Test func updateItemsPreservesCurrentPosition() {
        let items = [
            RotationItem(name: "API"),
            RotationItem(name: "CI"),
            RotationItem(name: "Frontend"),
        ]
        let engine = SliceEngine(items: items, interval: 180, settings: makeTestSettingsStore())
        engine.activate()
        engine.skip() // now on CI (index 1)
        #expect(engine.currentItemName == "CI")

        var newItems = items
        newItems.append(RotationItem(name: "Docs"))
        engine.updateItems(newItems)

        #expect(engine.currentItemName == "CI")
        #expect(engine.rotationItems.count == 4)
    }

    @Test func updateItemsWhenCurrentRemovedClamps() {
        let items = [
            RotationItem(name: "API"),
            RotationItem(name: "CI"),
            RotationItem(name: "Frontend"),
        ]
        let engine = SliceEngine(items: items, interval: 180, settings: makeTestSettingsStore())
        engine.activate()
        engine.skip() // now on CI (index 1)
        engine.skip() // now on Frontend (index 2)
        #expect(engine.currentItemName == "Frontend")

        let newItems = [items[0]] // only API remains
        engine.updateItems(newItems)

        #expect(engine.currentIndex == 0)
        #expect(engine.currentItemName == "API")
    }

    // MARK: - Restart Slice

    @Test func restartSliceResetsCountdown() {
        let engine = makeEngine(interval: 180)
        engine.activate()
        advanceEngine(engine, ticks: 50)
        #expect(engine.sliceSecondsRemaining == 130)
        engine.restartSlice()
        #expect(engine.sliceSecondsRemaining == 180)
        #expect(engine.currentIndex == 0)
        engine.deactivate()
    }

    @Test func restartSliceWhileInactiveIsNoOp() {
        let engine = makeEngine(interval: 180)
        engine.restartSlice()
        #expect(engine.sliceSecondsRemaining == 0)
    }

    @Test func updateItemsWhileInactiveIsNoOp() {
        let engine = makeEngine()
        engine.updateItems([RotationItem(name: "New")])
        #expect(engine.rotationItems.count == 3) // unchanged
    }

    @Test func updateItemsEmptyListIsNoOp() {
        let engine = makeEngine()
        engine.activate()
        engine.updateItems([])
        #expect(engine.rotationItems.count == 3)
        engine.deactivate()
    }

    @Test func restartSliceDuringOvertimeClearsOvertime() {
        let engine = makeEngine(interval: 2, autoAdvance: false)
        engine.activate()
        advanceEngine(engine, ticks: 2) // enter overtime
        #expect(engine.isOvertime == true)
        engine.restartSlice()
        #expect(engine.isOvertime == false)
        #expect(engine.overtimeSeconds == 0)
        #expect(engine.sliceSecondsRemaining == 2)
        // Verify ticking works normally after restart
        engine.tick()
        #expect(engine.sliceSecondsRemaining == 1)
        engine.deactivate()
    }

    // MARK: - Overtime (auto-advance off)

    @Test func noAutoAdvanceEntersOvertimeAtZero() {
        let engine = makeEngine(interval: 3, autoAdvance: false)
        engine.activate()
        advanceEngine(engine, ticks: 3)
        #expect(engine.isOvertime == true)
        #expect(engine.overtimeSeconds == 0)
        #expect(engine.currentIndex == 0) // did NOT advance
        engine.deactivate()
    }

    @Test func overtimeCountsUp() {
        let engine = makeEngine(interval: 2, autoAdvance: false)
        engine.activate()
        advanceEngine(engine, ticks: 2) // reach zero, enter overtime
        advanceEngine(engine, ticks: 3) // 3 overtime ticks
        #expect(engine.overtimeSeconds == 3)
        #expect(engine.isOvertime == true)
        engine.deactivate()
    }

    @Test func overtimeFiresRotationCompleteOnce() {
        let engine = makeEngine(interval: 2, autoAdvance: false)
        var completeCount = 0
        engine.onRotationComplete = { completeCount += 1 }
        engine.activate()
        advanceEngine(engine, ticks: 2) // enter overtime
        advanceEngine(engine, ticks: 3) // keep ticking in overtime
        #expect(completeCount == 1)
        engine.deactivate()
    }

    @Test func overtimeFiresOvertimeStartCallback() {
        let engine = makeEngine(interval: 2, autoAdvance: false)
        var started = false
        engine.onOvertimeStart = { started = true }
        engine.activate()
        advanceEngine(engine, ticks: 2)
        #expect(started == true)
        engine.deactivate()
    }

    @Test func skipDuringOvertimeAdvancesAndClearsOvertime() {
        let engine = makeEngine(interval: 2, autoAdvance: false)
        engine.activate()
        advanceEngine(engine, ticks: 2) // enter overtime
        #expect(engine.isOvertime == true)
        engine.skip()
        #expect(engine.isOvertime == false)
        #expect(engine.overtimeSeconds == 0)
        #expect(engine.currentIndex == 1)
        #expect(engine.sliceSecondsRemaining == 2)
        engine.deactivate()
    }

    @Test func deactivateClearsOvertime() {
        let engine = makeEngine(interval: 2, autoAdvance: false)
        engine.activate()
        advanceEngine(engine, ticks: 2)
        #expect(engine.isOvertime == true)
        engine.deactivate()
        #expect(engine.isOvertime == false)
        #expect(engine.overtimeSeconds == 0)
    }

    @Test func autoAdvanceOnStillAdvancesImmediately() {
        let engine = makeEngine(interval: 3, autoAdvance: true)
        engine.activate()
        advanceEngine(engine, ticks: 3)
        #expect(engine.isOvertime == false)
        #expect(engine.currentIndex == 1)
        #expect(engine.sliceSecondsRemaining == 3)
        engine.deactivate()
    }

    @Test func progressClampsAtOneInOvertime() {
        let engine = makeEngine(interval: 2, autoAdvance: false)
        engine.activate()
        advanceEngine(engine, ticks: 2)
        #expect(engine.progress == 1.0)
        engine.deactivate()
    }

    @Test func formattedOvertimeTime() {
        let engine = makeEngine(interval: 2, autoAdvance: false)
        engine.activate()
        advanceEngine(engine, ticks: 2) // enter overtime
        advanceEngine(engine, ticks: 65) // 65 seconds overtime
        #expect(engine.overtimeSeconds == 65)
        engine.deactivate()
    }

    // MARK: - formattedTime

    @Test func formattedTimeShowsCountdown() {
        let engine = makeEngine(interval: 125)
        engine.activate()
        #expect(engine.formattedTime == "02:05")
        engine.deactivate()
    }

    @Test func formattedTimeShowsOvertimePrefix() {
        let engine = makeEngine(interval: 2, autoAdvance: false)
        engine.activate()
        advanceEngine(engine, ticks: 2) // enter overtime
        advanceEngine(engine, ticks: 65) // 65s overtime
        #expect(engine.formattedTime == "+01:05")
        engine.deactivate()
    }

    @Test func formattedTimeWhenInactive() {
        let engine = makeEngine(interval: 180)
        #expect(engine.formattedTime == "00:00")
    }

    @Test func formattedTimeAtOvertimeBoundary() {
        let engine = makeEngine(interval: 2, autoAdvance: false)
        engine.activate()
        advanceEngine(engine, ticks: 2) // enter overtime, overtimeSeconds == 0
        #expect(engine.formattedTime == "+00:00")
        engine.deactivate()
    }

    // MARK: - Overtime Reminder

    @Test func overtimeReminderFiresAtInterval() {
        let settings = makeTestSettingsStore {
            $0.sliceOvertimeReminderInterval = 5
        }
        let engine = makeEngine(interval: 2, autoAdvance: false, settings: settings)
        var reminderCount = 0
        engine.onOvertimeReminder = { reminderCount += 1 }
        engine.activate()
        advanceEngine(engine, ticks: 2) // enter overtime
        advanceEngine(engine, ticks: 5) // 5 seconds overtime
        #expect(reminderCount == 1)
        advanceEngine(engine, ticks: 5) // 10 seconds overtime
        #expect(reminderCount == 2)
        engine.deactivate()
    }

    @Test func overtimeReminderDoesNotFireAtZero() {
        let settings = makeTestSettingsStore {
            $0.sliceOvertimeReminderInterval = 5
        }
        let engine = makeEngine(interval: 2, autoAdvance: false, settings: settings)
        var reminderCount = 0
        engine.onOvertimeReminder = { reminderCount += 1 }
        engine.activate()
        advanceEngine(engine, ticks: 2) // enter overtime (overtimeSeconds == 0)
        #expect(reminderCount == 0)
        engine.deactivate()
    }

    @Test func overtimeReminderNotFiredWhenIntervalZero() {
        let settings = makeTestSettingsStore { _ in }
        let engine = makeEngine(interval: 2, autoAdvance: false, settings: settings)
        var reminderCount = 0
        engine.onOvertimeReminder = { reminderCount += 1 }
        engine.activate()
        advanceEngine(engine, ticks: 2)
        advanceEngine(engine, ticks: 10)
        #expect(reminderCount == 0)
        engine.deactivate()
    }

    // MARK: - Live Settings

    @Test func overtimeReminderRespectsLiveSettingsChanges() {
        let settings = makeTestSettingsStore {
            $0.sliceOvertimeReminderInterval = 5
        }
        let engine = SliceEngine(
            items: [RotationItem(name: "API"), RotationItem(name: "CI")],
            interval: 2,
            autoAdvance: false,
            settings: settings
        )
        var reminderCount = 0
        engine.onOvertimeReminder = { reminderCount += 1 }
        engine.activate()
        advanceEngine(engine, ticks: 2) // enter overtime
        advanceEngine(engine, ticks: 5) // 5s overtime, fires at 5
        #expect(reminderCount == 1)
        // Change interval mid-overtime (min valid value is 5, so use 10)
        settings.sliceOvertimeReminderInterval = 10
        advanceEngine(engine, ticks: 5) // 10s overtime (divisible by 10)
        #expect(reminderCount == 2)
        engine.deactivate()
    }

    @Test func overtimeReminderStopsWhenIntervalSetToZero() {
        let settings = makeTestSettingsStore {
            $0.sliceOvertimeReminderInterval = 5
        }
        let engine = SliceEngine(
            items: [RotationItem(name: "API"), RotationItem(name: "CI")],
            interval: 2,
            autoAdvance: false,
            settings: settings
        )
        var reminderCount = 0
        engine.onOvertimeReminder = { reminderCount += 1 }
        engine.activate()
        advanceEngine(engine, ticks: 2) // enter overtime
        advanceEngine(engine, ticks: 5) // fires
        #expect(reminderCount == 1)
        settings.sliceOvertimeReminderInterval = 0
        advanceEngine(engine, ticks: 5) // should NOT fire
        #expect(reminderCount == 1)
        engine.deactivate()
    }

    @Test func overtimeReminderStartsWhenIntervalSetFromZero() {
        let settings = makeTestSettingsStore { _ in }
        let engine = SliceEngine(
            items: [RotationItem(name: "API"), RotationItem(name: "CI")],
            interval: 2,
            autoAdvance: false,
            settings: settings
        )
        var reminderCount = 0
        engine.onOvertimeReminder = { reminderCount += 1 }
        engine.activate()
        advanceEngine(engine, ticks: 2) // enter overtime
        advanceEngine(engine, ticks: 5) // no reminders (interval is 0)
        #expect(reminderCount == 0)
        settings.sliceOvertimeReminderInterval = 5
        advanceEngine(engine, ticks: 5) // 10s overtime, divisible by 5
        #expect(reminderCount == 1)
        engine.deactivate()
    }
}
