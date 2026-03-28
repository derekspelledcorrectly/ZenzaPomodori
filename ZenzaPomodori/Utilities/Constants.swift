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
    static let slicesEnabled: Bool = false
    static let sliceRotationInterval: Int = 180
    static let sliceSoundEnabled: Bool = true
    static let sliceEndSound: String = "Taptap"
    static let stealFocusOnRotation: Bool = false
    static let sliceMenuBarFormat: SliceMenuBarFormat = .dualTimer
    static let lastBlockType: BlockType = .focus
    static let globalHotkeyEnabled: Bool = true
    static let globalHotkeyKeyCode: UInt32 = 35 // P
    static let globalHotkeyModifiers: UInt32 = 4608 // controlKey + shiftKey
    static let rotationHotkeyEnabled: Bool = true
    static let rotationHotkeyKeyCode: UInt32 = 36 // Return
    static let rotationHotkeyModifiers: UInt32 = 4608 // controlKey + shiftKey
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
    static let slicesEnabled = "slicesEnabled"
    static let sliceRotationInterval = "sliceRotationInterval"
    static let sliceSoundEnabled = "sliceSoundEnabled"
    static let sliceEndSound = "sliceEndSound"
    static let stealFocusOnRotation = "stealFocusOnRotation"
    static let sliceMenuBarFormat = "sliceMenuBarFormat"
    static let lastBlockType = "lastBlockType"
    static let savedRotations = "savedRotations"
    static let globalHotkeyEnabled = "globalHotkeyEnabled"
    static let globalHotkeyKeyCode = "globalHotkeyKeyCode"
    static let globalHotkeyModifiers = "globalHotkeyModifiers"
    static let rotationHotkeyEnabled = "rotationHotkeyEnabled"
    static let rotationHotkeyKeyCode = "rotationHotkeyKeyCode"
    static let rotationHotkeyModifiers = "rotationHotkeyModifiers"
}
