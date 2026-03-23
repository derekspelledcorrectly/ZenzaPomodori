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
    static let focusEndSound: String = "Calm"
    static let breakEndSound: String = "Chord"
    static let notificationsEnabled: Bool = false
    static let autoDismissSeconds: Int = 5
    static let focusNameMaxRecents: Int = 25
    static let microBlocksEnabled: Bool = false
    static let microRotationInterval: Int = 180
    static let microBlockSoundEnabled: Bool = true
    static let microBlockEndSound: String = "Taptap"
    static let stealFocusOnRotation: Bool = false
    static let microBlockMenuBarFormat: MicroBlockMenuBarFormat = .dualTimer
    static let lastBlockType: BlockType = .regular
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
    static let focusEndSound = "focusEndSound"
    static let breakEndSound = "breakEndSound"
    static let notificationsEnabled = "notificationsEnabled"
    static let autoDismissSeconds = "autoDismissSeconds"
    static let focusNameEntries = "focusNameEntries"
    static let focusNameDraft = "focusNameDraft"
    static let microBlocksEnabled = "microBlocksEnabled"
    static let microRotationInterval = "microRotationInterval"
    static let microBlockSoundEnabled = "microBlockSoundEnabled"
    static let microBlockEndSound = "microBlockEndSound"
    static let stealFocusOnRotation = "stealFocusOnRotation"
    static let microBlockMenuBarFormat = "microBlockMenuBarFormat"
    static let lastBlockType = "lastBlockType"
    static let savedRotations = "savedRotations"
}
