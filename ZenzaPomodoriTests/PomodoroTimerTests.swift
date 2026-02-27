import Testing
@testable import ZenzaPomodori

@Suite("PomodoroTimer")
@MainActor
struct PomodoroTimerTests {
    @Test func startsIdle() {
        let timer = PomodoroTimer()
        #expect(timer.phase == .idle)
        #expect(timer.isRunning == false)
        #expect(timer.secondsRemaining == 0)
        #expect(timer.completedBlocks == 0)
    }

    @Test func startBeginsFirstFocusBlock() {
        let timer = PomodoroTimer()
        timer.start()
        #expect(timer.phase == .focus(block: 1))
        #expect(timer.secondsRemaining == Defaults.focusDuration)
        #expect(timer.isRunning == true)
        timer.reset()
    }

    @Test func startWhileRunningIsNoOp() {
        let timer = PomodoroTimer()
        timer.start()
        timer.start() // should not restart
        #expect(timer.phase == .focus(block: 1))
        timer.reset()
    }

    @Test func pauseStopsRunning() {
        let timer = PomodoroTimer()
        timer.start()
        timer.pause()
        #expect(timer.isRunning == false)
        #expect(timer.phase == .focus(block: 1))
    }

    @Test func resumeAfterPause() {
        let timer = PomodoroTimer()
        timer.start()
        timer.pause()
        timer.resume()
        #expect(timer.isRunning == true)
        timer.reset()
    }

    @Test func skipFromFocusToShortBreak() {
        let timer = PomodoroTimer()
        timer.start()
        timer.skip()
        #expect(timer.phase == .shortBreak(afterBlock: 1))
        #expect(timer.secondsRemaining == Defaults.shortBreakDuration)
        #expect(timer.completedBlocks == 1)
        timer.reset()
    }

    @Test func skipFromShortBreakToNextFocus() {
        let timer = PomodoroTimer()
        timer.start()
        timer.skip() // focus 1 -> short break
        timer.skip() // short break -> focus 2
        #expect(timer.phase == .focus(block: 2))
        #expect(timer.secondsRemaining == Defaults.focusDuration)
        timer.reset()
    }

    @Test func skipToLongBreakAfterAllBlocks() {
        let timer = PomodoroTimer()
        timer.start()
        // Complete all 4 focus blocks
        for _ in 1..<Defaults.blocksBeforeLongBreak {
            timer.skip() // focus -> short break
            timer.skip() // short break -> next focus
        }
        // Now on focus block 4
        #expect(timer.phase == .focus(block: 4))
        timer.skip() // focus 4 -> long break
        #expect(timer.phase == .longBreak)
        #expect(timer.secondsRemaining == Defaults.longBreakDuration)
        #expect(timer.completedBlocks == 4)
        timer.reset()
    }

    @Test func skipFromLongBreakResetsToIdle() {
        let timer = PomodoroTimer()
        timer.start()
        for _ in 1..<Defaults.blocksBeforeLongBreak {
            timer.skip()
            timer.skip()
        }
        timer.skip() // -> long break
        timer.skip() // -> idle
        #expect(timer.phase == .idle)
        timer.reset()
    }

    @Test func resetClearsEverything() {
        let timer = PomodoroTimer()
        timer.start()
        timer.skip()
        timer.reset()
        #expect(timer.phase == .idle)
        #expect(timer.isRunning == false)
        #expect(timer.secondsRemaining == 0)
        #expect(timer.completedBlocks == 0)
    }

    @Test func progressCalculation() {
        let timer = PomodoroTimer()
        #expect(timer.progress == 0)

        timer.start()
        #expect(timer.progress == 0)
        timer.reset()
    }

    @Test func formattedTimeDisplay() {
        let timer = PomodoroTimer()
        timer.start()
        #expect(timer.formattedTime == "25:00")
        timer.reset()
    }

    @Test func customDurations() {
        let timer = PomodoroTimer()
        timer.focusDuration = 10 * 60
        timer.shortBreakDuration = 2 * 60
        timer.longBreakDuration = 20 * 60
        timer.blocksBeforeLongBreak = 2

        timer.start()
        #expect(timer.secondsRemaining == 600)
        timer.skip() // -> short break
        #expect(timer.secondsRemaining == 120)
        timer.skip() // -> focus 2
        timer.skip() // -> long break (after 2 blocks)
        #expect(timer.phase == .longBreak)
        #expect(timer.secondsRemaining == 1200)
        timer.reset()
    }

    @Test func onPhaseChangeCallback() {
        let timer = PomodoroTimer()
        var transitions: [(TimerPhase, TimerPhase)] = []
        timer.onPhaseChange = { old, new in
            transitions.append((old, new))
        }

        timer.start()
        #expect(transitions.count == 1)
        #expect(transitions[0].0 == .idle)
        #expect(transitions[0].1 == .focus(block: 1))

        timer.skip()
        #expect(transitions.count == 2)
        #expect(transitions[1].1 == .shortBreak(afterBlock: 1))

        timer.reset()
        #expect(transitions.count == 3)
        #expect(transitions[2].1 == .idle)
    }
}
