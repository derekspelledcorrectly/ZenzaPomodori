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

    private func microFormatted(
        microSeconds: Int = 107,
        outerTime: String = "18:42",
        focusName: String? = "API Refactor",
        position: Int = 3,
        total: Int = 5,
        format: SliceMenuBarFormat = .dualTimer,
        showTimer: Bool = true,
        showFocus: Bool = true
    ) -> String {
        MenuBarFormatting.sliceFormatted(
            microSeconds: microSeconds,
            outerFormattedTime: outerTime,
            focusName: focusName,
            position: position,
            total: total,
            format: format,
            showTimer: showTimer,
            showFocus: showFocus
        )
    }

    @Test func microOnlyFormat() {
        #expect(microFormatted(format: .microOnly) == "01:47 [API Refactor]")
    }

    @Test func dualTimerFormat() {
        #expect(microFormatted(format: .dualTimer) == "01:47/18:42 [API Refactor]")
    }

    @Test func microPositionFormat() {
        #expect(microFormatted(format: .microPosition) == "01:47 3/5 [API Refactor]")
    }

    @Test func compactFormat() {
        #expect(microFormatted(format: .compact) == "01:47")
    }

    @Test func noFocusNameOmitsName() {
        #expect(microFormatted(focusName: nil, format: .dualTimer) == "01:47/18:42")
    }

    @Test func showFocusFalseOmitsName() {
        #expect(microFormatted(format: .dualTimer, showFocus: false) == "01:47/18:42")
    }

    @Test func showTimerFalseWithFocusReturnsName() {
        #expect(microFormatted(showTimer: false) == "API Refactor")
    }

    @Test func showTimerFalseNoFocusReturnsEmpty() {
        #expect(microFormatted(showTimer: false, showFocus: false) == "")
    }
}
