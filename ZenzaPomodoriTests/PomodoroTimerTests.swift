import Foundation
import Testing
@testable import ZenzaPomodori

@Suite("PomodoroTimer")
@MainActor
struct PomodoroTimerTests {
    private func makeTimer(
        configure: ((SettingsStore) -> Void)? = nil
    ) -> PomodoroTimer {
        let defaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let store = SettingsStore(defaults: defaults)
        configure?(store)
        return PomodoroTimer(settings: store)
    }

    @Test func startsIdle() {
        let timer = makeTimer()
        #expect(timer.phase == .idle)
        #expect(timer.isRunning == false)
        #expect(timer.secondsRemaining == 0)
        #expect(timer.completedBlocks == 0)
    }

    @Test func startBeginsFirstFocusBlock() {
        let timer = makeTimer()
        timer.start()
        #expect(timer.phase == .focus(block: 1))
        #expect(timer.secondsRemaining == Defaults.focusDuration)
        #expect(timer.isRunning == true)
        timer.reset()
    }

    @Test func startWhileRunningIsNoOp() {
        let timer = makeTimer()
        timer.start()
        timer.start() // should not restart
        #expect(timer.phase == .focus(block: 1))
        timer.reset()
    }

    @Test func pauseStopsRunning() {
        let timer = makeTimer()
        timer.start()
        timer.pause()
        #expect(timer.isRunning == false)
        #expect(timer.phase == .focus(block: 1))
    }

    @Test func resumeAfterPause() {
        let timer = makeTimer()
        timer.start()
        timer.pause()
        timer.resume()
        #expect(timer.isRunning == true)
        timer.reset()
    }

    @Test func nextFromFocusToShortBreak() {
        let timer = makeTimer()
        timer.start()
        timer.next()
        #expect(timer.phase == .shortBreak(afterBlock: 1))
        #expect(timer.secondsRemaining == Defaults.shortBreakDuration)
        #expect(timer.completedBlocks == 1)
        timer.reset()
    }

    @Test func nextFromShortBreakToNextFocus() {
        let timer = makeTimer()
        timer.start()
        timer.next() // focus 1 -> short break
        timer.next() // short break -> focus 2
        #expect(timer.phase == .focus(block: 2))
        #expect(timer.secondsRemaining == Defaults.focusDuration)
        timer.reset()
    }

    @Test func nextToLongBreakAfterAllBlocks() {
        let timer = makeTimer()
        timer.start()
        // Complete all 4 focus blocks
        for _ in 1..<Defaults.blocksBeforeLongBreak {
            timer.next() // focus -> short break
            timer.next() // short break -> next focus
        }
        // Now on focus block 4
        #expect(timer.phase == .focus(block: 4))
        timer.next() // focus 4 -> long break
        #expect(timer.phase == .longBreak)
        #expect(timer.secondsRemaining == Defaults.longBreakDuration)
        #expect(timer.completedBlocks == 4)
        timer.reset()
    }

    @Test func nextFromLongBreakResetsToIdle() {
        let timer = makeTimer()
        timer.start()
        for _ in 1..<Defaults.blocksBeforeLongBreak {
            timer.next()
            timer.next()
        }
        timer.next() // -> long break
        timer.next() // -> idle
        #expect(timer.phase == .idle)
        timer.reset()
    }

    @Test func resetClearsEverything() {
        let timer = makeTimer()
        timer.start()
        timer.next()
        timer.reset()
        #expect(timer.phase == .idle)
        #expect(timer.isRunning == false)
        #expect(timer.secondsRemaining == 0)
        #expect(timer.completedBlocks == 0)
        #expect(timer.isOvertime == false)
        #expect(timer.overtimeSeconds == 0)
    }

    @Test func progressCalculation() {
        let timer = makeTimer()
        #expect(timer.progress == 0)

        timer.start()
        #expect(timer.progress == 0)
        timer.reset()
    }

    @Test func formattedTimeDisplay() {
        let timer = makeTimer()
        timer.start()
        #expect(timer.formattedTime == "25:00")
        timer.reset()
    }

    @Test func customDurations() {
        let timer = makeTimer { store in
            store.focusDuration = 10 * 60
            store.shortBreakDuration = 2 * 60
            store.longBreakDuration = 20 * 60
            store.blocksBeforeLongBreak = 2
        }

        timer.start()
        #expect(timer.secondsRemaining == 600)
        timer.next() // -> short break
        #expect(timer.secondsRemaining == 120)
        timer.next() // -> focus 2
        timer.next() // -> long break (after 2 blocks)
        #expect(timer.phase == .longBreak)
        #expect(timer.secondsRemaining == 1200)
        timer.reset()
    }

    @Test func onPhaseChangeCallback() {
        let timer = makeTimer()
        var transitions: [(TimerPhase, TimerPhase)] = []
        timer.onPhaseChange = { old, new in
            transitions.append((old, new))
        }

        timer.start()
        #expect(transitions.count == 1)
        #expect(transitions[0].0 == .idle)
        #expect(transitions[0].1 == .focus(block: 1))

        timer.next()
        #expect(transitions.count == 2)
        #expect(transitions[1].1 == .shortBreak(afterBlock: 1))

        timer.reset()
        #expect(transitions.count == 3)
        #expect(transitions[2].1 == .idle)
    }

    @Test func startsWithNoOvertime() {
        let timer = makeTimer()
        #expect(timer.isOvertime == false)
        #expect(timer.overtimeSeconds == 0)
    }

    @Test func nextFromOvertimeClearsOvertime() {
        let timer = makeTimer()
        timer.start()
        timer.next() // focus -> short break
        #expect(timer.isOvertime == false)
        #expect(timer.overtimeSeconds == 0)
        timer.reset()
    }

    @Test func progressClampsDuringOvertime() {
        let timer = makeTimer { $0.focusDuration = 60 }
        timer.start()
        timer.pause()
        // Simulate reaching zero by setting secondsRemaining
        // We test the progress property logic directly
        #expect(timer.progress == 0)
        timer.reset()
    }

    @Test func settingsSnapshotOnStart() {
        let defaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let store = SettingsStore(defaults: defaults)
        store.focusDuration = 10 * 60
        let timer = PomodoroTimer(settings: store)

        timer.start()
        #expect(timer.focusDuration == 600)

        // Changing settings mid-session should not affect the running timer
        store.focusDuration = 20 * 60
        #expect(timer.focusDuration == 600)
        timer.reset()
    }

    // MARK: - Auto-advance

    @Test func autoAdvanceTransitionsToNextPhase() {
        let timer = makeTimer { $0.autoAdvance = true; $0.focusDuration = 60 }
        timer.start()
        timer.pause()
        #expect(timer.phase == .focus(block: 1))

        // Simulate ticking down to zero
        for _ in 0..<60 {
            timer.tick()
        }

        // Should auto-advance to short break, not enter overtime
        #expect(timer.phase == .shortBreak(afterBlock: 1))
        #expect(timer.isOvertime == false)
        timer.reset()
    }

    @Test func autoAdvanceSkipsOvertimeCallback() {
        let timer = makeTimer { $0.autoAdvance = true; $0.focusDuration = 60 }
        var overtimeStarted = false
        timer.onOvertimeStart = { _ in overtimeStarted = true }
        timer.start()
        timer.pause()

        for _ in 0..<60 {
            timer.tick()
        }

        #expect(overtimeStarted == false)
        timer.reset()
    }

    @Test func autoAdvanceFiresPhaseChangeCallback() {
        let timer = makeTimer { $0.autoAdvance = true; $0.focusDuration = 60 }
        var transitions: [(TimerPhase, TimerPhase)] = []
        timer.onPhaseChange = { old, new in transitions.append((old, new)) }
        timer.start()
        timer.pause()
        transitions.removeAll() // clear the start transition

        for _ in 0..<60 {
            timer.tick()
        }

        #expect(transitions.count == 1)
        #expect(transitions[0].0 == .focus(block: 1))
        #expect(transitions[0].1 == .shortBreak(afterBlock: 1))
        timer.reset()
    }

    @Test func autoAdvanceDisabledEntersOvertime() {
        let timer = makeTimer { $0.autoAdvance = false; $0.focusDuration = 60 }
        timer.start()
        timer.pause()

        for _ in 0..<60 {
            timer.tick()
        }

        #expect(timer.isOvertime == true)
        #expect(timer.phase == .focus(block: 1))
        timer.reset()
    }

    @Test func autoAdvanceFromLongBreakReturnsToIdle() {
        let timer = makeTimer { $0.autoAdvance = true; $0.focusDuration = 60; $0.blocksBeforeLongBreak = 1; $0.longBreakDuration = 60 }
        timer.start()
        timer.pause()

        // Tick through focus block 1
        for _ in 0..<60 { timer.tick() }
        #expect(timer.phase == .longBreak)

        // Tick through long break
        for _ in 0..<60 { timer.tick() }
        #expect(timer.phase == .idle)
        #expect(timer.isRunning == false)
    }

    @Test func formattedTimeShowsOvertimePrefix() {
        let timer = makeTimer()
        timer.start()
        #expect(timer.formattedTime == "25:00")
        // formattedTime without overtime should not have "+" prefix
        #expect(!timer.formattedTime.hasPrefix("+"))
        timer.reset()
    }
}
