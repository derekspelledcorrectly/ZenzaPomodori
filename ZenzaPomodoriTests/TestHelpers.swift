import Foundation

@testable import ZenzaPomodori

/// Creates an isolated UserDefaults suite for testing.
/// Each call returns a fresh suite so tests don't interfere with each other.
func makeTestDefaults() -> UserDefaults {
    UserDefaults(suiteName: "test-\(UUID().uuidString)")!
}

/// Creates a SettingsStore backed by isolated test defaults.
func makeTestSettingsStore(
    configure: ((SettingsStore) -> Void)? = nil
) -> SettingsStore {
    let store = SettingsStore(defaults: makeTestDefaults())
    configure?(store)
    return store
}

/// Advance a PomodoroTimer by the given number of ticks.
@MainActor
func advanceTimer(_ timer: PomodoroTimer, ticks: Int) {
    for _ in 0..<ticks {
        timer.tick()
    }
}

/// Advance a SliceEngine by the given number of ticks.
@MainActor
func advanceEngine(_ engine: SliceEngine, ticks: Int) {
    for _ in 0..<ticks {
        engine.tick()
    }
}
