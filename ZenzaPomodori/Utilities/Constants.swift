import Foundation

enum Defaults {
    static let focusDuration: Int = 25 * 60
    static let shortBreakDuration: Int = 5 * 60
    static let longBreakDuration: Int = 25 * 60
    static let blocksBeforeLongBreak: Int = 4
    static let autoAdvance: Bool = false
    static let soundEnabled: Bool = true
    static let showTimerInMenuBar: Bool = true
    static let popOnComplete: Bool = true
    static let showFocusInMenuBar: Bool = true
    static let selectedSound: String = "Calm"
    static let notificationsEnabled: Bool = false
    static let autoDismissSeconds: Int = 5
    static let focusNameMaxRecents: Int = 25
}

enum SettingsKeys {
    static let focusDuration = "focusDuration"
    static let shortBreakDuration = "shortBreakDuration"
    static let longBreakDuration = "longBreakDuration"
    static let blocksBeforeLongBreak = "blocksBeforeLongBreak"
    static let autoAdvance = "autoAdvance"
    static let soundEnabled = "soundEnabled"
    static let showTimerInMenuBar = "showTimerInMenuBar"
    static let popOnComplete = "popOnComplete"
    static let showFocusInMenuBar = "showFocusInMenuBar"
    static let selectedSound = "selectedSound"
    static let notificationsEnabled = "notificationsEnabled"
    static let autoDismissSeconds = "autoDismissSeconds"
    static let focusNameEntries = "focusNameEntries"
    static let focusNameDraft = "focusNameDraft"
}
