import Foundation

enum Defaults {
    static let focusDuration: Int = 25 * 60
    static let shortBreakDuration: Int = 5 * 60
    static let longBreakDuration: Int = 20 * 60
    static let blocksBeforeLongBreak: Int = 4
    static let autoAdvance: Bool = false
    static let showTimerInMenuBar: Bool = true
    static let popOnComplete: Bool = true
    static let showFocusInMenuBar: Bool = true
    static let focusEndSound: String = "Reverie"
    static let breakEndSound: String = "Cloud"
    static let notificationsEnabled: Bool = false
    static let autoDismissSeconds: Int = 5
    static let focusNameMaxRecents: Int = 25
    static let slicesEnabled: Bool = true
    static let sliceRotationInterval: Int = 120
    static let sliceEndSound: String = "Polite"
    static let stealFocusOnPop: Bool = false
    static let showSliceTimerInMenuBar: Bool = true
    static let showSliceFocusInMenuBar: Bool = true
    static let showSessionTimerInMenuBar: Bool = false
    static let showSlicePositionInMenuBar: Bool = false
    static let sliceAutoAdvance: Bool = true
    static let focusOvertimeReminderInterval: Int = 300
    static let focusOvertimeReminderSound: String = "Glass"
    static let sliceOvertimeReminderInterval: Int = 20
    static let sliceOvertimeReminderSound: String = "Sharp"
    static let lastBlockType: BlockType = .focus
    static let globalHotkeyEnabled: Bool = false
    static let globalHotkeyKeyCode: UInt32 = 42  // \
    static let globalHotkeyModifiers: UInt32 = 4608  // controlKey + shiftKey
    static let rotationHotkeyEnabled: Bool = false
    static let rotationHotkeyKeyCode: UInt32 = 36  // Return
    static let rotationHotkeyModifiers: UInt32 = 4608  // controlKey + shiftKey
    static let bulkEditMode: Bool = false
}

enum SettingsKeys {
    static let focusDuration = "focusDuration"
    static let shortBreakDuration = "shortBreakDuration"
    static let longBreakDuration = "longBreakDuration"
    static let blocksBeforeLongBreak = "blocksBeforeLongBreak"
    static let autoAdvance = "autoAdvance"
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
    static let sliceEndSound = "sliceEndSound"
    static let stealFocusOnPop = "stealFocusOnRotation"
    static let showSliceTimerInMenuBar = "showSliceTimerInMenuBar"
    static let showSliceFocusInMenuBar = "showSliceFocusInMenuBar"
    static let showSessionTimerInMenuBar = "showSessionTimerInMenuBar"
    static let showSlicePositionInMenuBar = "showSlicePositionInMenuBar"
    static let sliceAutoAdvance = "sliceAutoAdvance"
    static let focusOvertimeReminderInterval = "focusOvertimeReminderInterval"
    static let focusOvertimeReminderSound = "focusOvertimeReminderSound"
    static let sliceOvertimeReminderInterval = "sliceOvertimeReminderInterval"
    static let sliceOvertimeReminderSound = "sliceOvertimeReminderSound"
    static let lastBlockType = "lastBlockType"
    static let savedRotations = "savedRotations"
    static let globalHotkeyEnabled = "globalHotkeyEnabled"
    static let globalHotkeyKeyCode = "globalHotkeyKeyCode"
    static let globalHotkeyModifiers = "globalHotkeyModifiers"
    static let rotationHotkeyEnabled = "rotationHotkeyEnabled"
    static let rotationHotkeyKeyCode = "rotationHotkeyKeyCode"
    static let rotationHotkeyModifiers = "rotationHotkeyModifiers"
    static let lastUsedRotationItems = "lastUsedRotationItems"
    static let bulkEditMode = "bulkEditMode"
}
