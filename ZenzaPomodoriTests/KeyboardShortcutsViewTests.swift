import Testing
@testable import ZenzaPomodori

@Suite("KeyboardShortcutsView")
struct KeyboardShortcutsViewTests {
    @Test func allSectionsPresent() {
        let sections = ShortcutData.sections
        let names = sections.map(\.title)
        #expect(names.contains("General"))
        #expect(names.contains("Timer Running"))
        #expect(names.contains("Slices Active"))
    }

    @Test func generalSectionHasExpectedShortcuts() {
        let general = ShortcutData.sections.first { $0.title == "General" }!
        let actions = general.shortcuts.map(\.action)
        #expect(actions.contains("Start timer"))
        #expect(actions.contains("Pause / Resume"))
        #expect(actions.contains("Settings"))
        #expect(actions.contains("Keyboard Shortcuts"))
        #expect(actions.contains("Dismiss / Go back"))
    }

    @Test func timerRunningSectionHasExpectedShortcuts() {
        let section = ShortcutData.sections.first { $0.title == "Timer Running" }!
        let actions = section.shortcuts.map(\.action)
        #expect(actions.contains("Finish Block / Break"))
        #expect(actions.contains("Restart Timer"))
        #expect(actions.contains("Abandon Block"))
    }

    @Test func slicesActiveSectionHasExpectedShortcuts() {
        let section = ShortcutData.sections.first { $0.title == "Slices Active" }!
        let actions = section.shortcuts.map(\.action)
        #expect(actions.contains("Edit Rotation List"))
        #expect(actions.contains("Restart Slice"))
        #expect(actions.contains("Restart Block Timer"))
    }

    @Test func noEmptyKeys() {
        for section in ShortcutData.sections {
            for shortcut in section.shortcuts {
                #expect(!shortcut.keys.isEmpty, "Shortcut '\(shortcut.action)' has empty keys")
            }
        }
    }
}
