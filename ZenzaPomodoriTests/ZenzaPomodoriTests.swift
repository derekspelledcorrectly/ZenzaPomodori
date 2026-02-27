import Testing
@testable import ZenzaPomodori

@Suite("TimerPhase")
struct TimerPhaseTests {
    @Test func idleLabel() {
        #expect(TimerPhase.idle.label == "Idle")
    }

    @Test func focusLabel() {
        #expect(TimerPhase.focus(block: 2).label == "Focus 2/4")
    }

    @Test func shortBreakLabel() {
        #expect(TimerPhase.shortBreak(afterBlock: 1).label == "Short Break")
    }

    @Test func longBreakLabel() {
        #expect(TimerPhase.longBreak.label == "Long Break")
    }

    @Test func isFocus() {
        #expect(TimerPhase.focus(block: 1).isFocus)
        #expect(!TimerPhase.idle.isFocus)
        #expect(!TimerPhase.shortBreak(afterBlock: 1).isFocus)
        #expect(!TimerPhase.longBreak.isFocus)
    }

    @Test func isBreak() {
        #expect(TimerPhase.shortBreak(afterBlock: 1).isBreak)
        #expect(TimerPhase.longBreak.isBreak)
        #expect(!TimerPhase.idle.isBreak)
        #expect(!TimerPhase.focus(block: 1).isBreak)
    }

    @Test func equality() {
        #expect(TimerPhase.focus(block: 1) == TimerPhase.focus(block: 1))
        #expect(TimerPhase.focus(block: 1) != TimerPhase.focus(block: 2))
        #expect(TimerPhase.idle == TimerPhase.idle)
    }
}

@Suite("TimeFormatting")
struct TimeFormattingTests {
    @Test func formattedZero() {
        #expect(TimeFormatting.formatted(seconds: 0) == "00:00")
    }

    @Test func formattedMinutesAndSeconds() {
        #expect(TimeFormatting.formatted(seconds: 90) == "01:30")
        #expect(TimeFormatting.formatted(seconds: 1500) == "25:00")
        #expect(TimeFormatting.formatted(seconds: 305) == "05:05")
    }

    @Test func shortFormattedRoundsUp() {
        #expect(TimeFormatting.shortFormatted(seconds: 1500) == "25m")
        #expect(TimeFormatting.shortFormatted(seconds: 1499) == "25m")
        #expect(TimeFormatting.shortFormatted(seconds: 1441) == "25m")
        #expect(TimeFormatting.shortFormatted(seconds: 1440) == "24m")
        #expect(TimeFormatting.shortFormatted(seconds: 59) == "1m")
        #expect(TimeFormatting.shortFormatted(seconds: 0) == "0m")
    }
}

@Suite("Defaults")
struct DefaultsTests {
    @Test func defaultValues() {
        #expect(Defaults.focusDuration == 1500)
        #expect(Defaults.shortBreakDuration == 300)
        #expect(Defaults.longBreakDuration == 1500)
        #expect(Defaults.blocksBeforeLongBreak == 4)
    }
}
