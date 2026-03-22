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
}
