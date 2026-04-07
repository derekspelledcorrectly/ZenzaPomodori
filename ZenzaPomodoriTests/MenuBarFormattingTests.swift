import Testing
@testable import ZenzaPomodori

@Suite("MenuBarFormatting")
struct MenuBarFormattingTests {
    @Test func shortNameUnchanged() {
        #expect(MenuBarFormatting.truncatedFocusName("API work") == "API work")
    }

    @Test func exactBoundaryUnchanged() {
        let name = String(repeating: "a", count: 20)
        #expect(MenuBarFormatting.truncatedFocusName(name) == name)
    }

    @Test func overLimitTruncatesWithEllipsis() {
        let name = String(repeating: "a", count: 25)
        let expected = String(repeating: "a", count: 20) + "..."
        #expect(MenuBarFormatting.truncatedFocusName(name) == expected)
    }

    @Test func trailingWhitespaceTrimmedBeforeMeasuring() {
        let name = "short   "
        #expect(MenuBarFormatting.truncatedFocusName(name) == "short")
    }

    @Test func leadingWhitespaceTrimmedBeforeMeasuring() {
        let name = "   short"
        #expect(MenuBarFormatting.truncatedFocusName(name) == "short")
    }

    @Test func allWhitespaceReturnsEmpty() {
        #expect(MenuBarFormatting.truncatedFocusName("     ") == "")
    }

    @Test func emptyStringReturnsEmpty() {
        #expect(MenuBarFormatting.truncatedFocusName("") == "")
    }

    @Test func customMaxLengthTruncates() {
        #expect(MenuBarFormatting.truncatedFocusName("Hello World", maxLength: 5) == "Hello...")
    }

    @Test func customMaxLengthUnderLimitUnchanged() {
        #expect(MenuBarFormatting.truncatedFocusName("Hi", maxLength: 5) == "Hi")
    }

    // MARK: - Slice Formatting

    private func sliceFormatted(
        sliceFormattedTime: String = "01:47",
        outerTime: String = "18:42",
        focusName: String? = "API Refactor",
        position: Int = 3,
        total: Int = 5,
        format: SliceMenuBarFormat = .dualTimer,
        showTimer: Bool = true,
        showFocus: Bool = true
    ) -> SliceFormattedResult {
        MenuBarFormatting.sliceFormatted(SliceDisplayInfo(
            sliceFormattedTime: sliceFormattedTime,
            outerFormattedTime: outerTime,
            focusName: focusName,
            position: position,
            total: total,
            format: format,
            showTimer: showTimer,
            showFocus: showFocus
        ))
    }

    @Test func sliceOnlyFormat() {
        let result = sliceFormatted(format: .sliceOnly)
        #expect(result.timerPart == "01:47")
        #expect(result.focusPart == "API Refactor")
    }

    @Test func dualTimerFormat() {
        let result = sliceFormatted(format: .dualTimer)
        #expect(result.timerPart == "01:47/18:42")
        #expect(result.focusPart == "API Refactor")
    }

    @Test func slicePositionFormat() {
        let result = sliceFormatted(format: .slicePosition)
        #expect(result.timerPart == "01:47 3/5")
        #expect(result.focusPart == "API Refactor")
    }

    @Test func compactFormat() {
        let result = sliceFormatted(format: .compact)
        #expect(result.timerPart == "01:47")
        #expect(result.focusPart == nil)
    }

    @Test func noFocusNameOmitsName() {
        let result = sliceFormatted(focusName: nil, format: .dualTimer)
        #expect(result.timerPart == "01:47/18:42")
        #expect(result.focusPart == nil)
    }

    @Test func showFocusFalseOmitsName() {
        let result = sliceFormatted(format: .dualTimer, showFocus: false)
        #expect(result.timerPart == "01:47/18:42")
        #expect(result.focusPart == nil)
    }

    @Test func showTimerFalseWithFocusReturnsName() {
        let result = sliceFormatted(showTimer: false)
        #expect(result.timerPart == "")
        #expect(result.focusPart == "API Refactor")
    }

    @Test func showTimerFalseNoFocusReturnsEmpty() {
        let result = sliceFormatted(showTimer: false, showFocus: false)
        #expect(result.timerPart == "")
        #expect(result.focusPart == nil)
    }

    @Test func sliceOvertimeShowsPlusPrefix() {
        let result = sliceFormatted(
            sliceFormattedTime: "+00:45",
            focusName: "API",
            position: 1,
            total: 3,
            format: .sliceOnly
        )
        #expect(result.timerPart == "+00:45")
        #expect(result.focusPart == "API")
    }

    @Test func sliceOvertimeDualTimerFormat() {
        let result = sliceFormatted(
            sliceFormattedTime: "+00:45",
            outerTime: "20:00",
            focusName: "API",
            position: 1,
            total: 3,
            format: .dualTimer
        )
        #expect(result.timerPart == "+00:45/20:00")
        #expect(result.focusPart == "API")
    }
}
