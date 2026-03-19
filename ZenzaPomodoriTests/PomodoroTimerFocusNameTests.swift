import Foundation
import Testing
@testable import ZenzaPomodori

@Suite("PomodoroTimer Focus Name")
@MainActor
struct PomodoroTimerFocusNameTests {
    private func makeTimer(
        focusName: String = "",
        configure: ((SettingsStore) -> Void)? = nil
    ) -> PomodoroTimer {
        let defaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let settings = SettingsStore(defaults: defaults)
        configure?(settings)
        let focusStore = FocusNameStore(defaults: defaults)
        focusStore.draftName = focusName
        return PomodoroTimer(settings: settings, focusNameStore: focusStore)
    }

    // MARK: - Active Focus Name

    @Test func activeFocusNameIsNilWhenIdle() {
        let timer = makeTimer()
        #expect(timer.activeFocusName == nil)
    }

    @Test func activeFocusNameSetOnStart() {
        let timer = makeTimer(focusName: "Deep Work")
        timer.start()
        #expect(timer.activeFocusName == "Deep Work")
        timer.reset()
    }

    @Test func emptyDraftProducesNilActiveName() {
        let timer = makeTimer(focusName: "")
        timer.start()
        #expect(timer.activeFocusName == nil)
        timer.reset()
    }

    @Test func activeFocusNameClearedOnReset() {
        let timer = makeTimer(focusName: "Deep Work")
        timer.start()
        timer.reset()
        #expect(timer.activeFocusName == nil)
    }

    // MARK: - History Integration

    @Test func startCommitsNonEmptyNameToHistory() {
        let timer = makeTimer(focusName: "Deep Work")
        timer.start()
        #expect(timer.focusNameStore.entries.count == 1)
        #expect(timer.focusNameStore.entries[0].name == "Deep Work")
        timer.reset()
    }

    @Test func startSkipsHistoryForEmptyName() {
        let timer = makeTimer(focusName: "")
        timer.start()
        #expect(timer.focusNameStore.entries.isEmpty)
        timer.reset()
    }

    // MARK: - Pre-population and Ready State

    @Test func draftNamePrePopulatesInReadyState() {
        let timer = makeTimer(focusName: "Deep Work")
        timer.start()   // focus block 1
        timer.next()     // -> short break
        timer.next()     // -> ready (idle with pendingBlock)
        #expect(timer.focusNameStore.draftName == "Deep Work")
        #expect(timer.pendingBlock == 2)
        timer.reset()
    }

    @Test func startFromReadyCommitsFocusName() {
        let timer = makeTimer(focusName: "Deep Work")
        timer.start()   // focus block 1
        timer.next()     // -> short break
        timer.next()     // -> ready
        timer.focusNameStore.draftName = "Code Review"
        timer.start()    // -> focus block 2
        #expect(timer.activeFocusName == "Code Review")
        #expect(timer.focusNameStore.entries.count == 2)
        timer.reset()
    }

    @Test func resetClearsPendingBlock() {
        let timer = makeTimer(focusName: "Deep Work")
        timer.start()
        timer.next()     // -> short break
        timer.next()     // -> ready
        #expect(timer.pendingBlock == 2)
        timer.reset()
        #expect(timer.pendingBlock == nil)
    }

    // MARK: - Lock State

    @Test func focusNameLockedDuringFocus() {
        let timer = makeTimer(focusName: "Deep Work")
        timer.start()
        #expect(timer.focusNameIsLocked == true)
        timer.reset()
    }

    @Test func focusNameUnlockedWhenIdle() {
        let timer = makeTimer()
        #expect(timer.focusNameIsLocked == false)
    }

    @Test func focusNameUnlockedDuringBreak() {
        let timer = makeTimer(focusName: "Deep Work")
        timer.start()
        timer.next()  // -> short break
        #expect(timer.focusNameIsLocked == false)
        timer.reset()
    }

    @Test func focusNameLockedEvenWhenPaused() {
        let timer = makeTimer(focusName: "Deep Work")
        timer.start()
        timer.pause()
        #expect(timer.focusNameIsLocked == true)
        timer.reset()
    }
}
