import Foundation
import Observation

@Observable
final class SettingsStore {
    private let defaults: UserDefaults

    var focusDuration: Int {
        didSet {
            let validated = max(60, focusDuration)
            defaults.set(validated, forKey: SettingsKeys.focusDuration)
            if focusDuration != validated { focusDuration = validated }
        }
    }

    var shortBreakDuration: Int {
        didSet {
            let validated = max(60, shortBreakDuration)
            defaults.set(validated, forKey: SettingsKeys.shortBreakDuration)
            if shortBreakDuration != validated { shortBreakDuration = validated }
        }
    }

    var longBreakDuration: Int {
        didSet {
            let validated = max(60, longBreakDuration)
            defaults.set(validated, forKey: SettingsKeys.longBreakDuration)
            if longBreakDuration != validated { longBreakDuration = validated }
        }
    }

    var blocksBeforeLongBreak: Int {
        didSet {
            let validated = max(1, blocksBeforeLongBreak)
            defaults.set(validated, forKey: SettingsKeys.blocksBeforeLongBreak)
            if blocksBeforeLongBreak != validated { blocksBeforeLongBreak = validated }
        }
    }

    var autoAdvance: Bool {
        didSet { defaults.set(autoAdvance, forKey: SettingsKeys.autoAdvance) }
    }

    var showTimerInMenuBar: Bool {
        didSet { defaults.set(showTimerInMenuBar, forKey: SettingsKeys.showTimerInMenuBar) }
    }

    var popOnComplete: Bool {
        didSet { defaults.set(popOnComplete, forKey: SettingsKeys.popOnComplete) }
    }

    var showFocusInMenuBar: Bool {
        didSet { defaults.set(showFocusInMenuBar, forKey: SettingsKeys.showFocusInMenuBar) }
    }

    var focusEndSound: String {
        didSet { defaults.set(focusEndSound, forKey: SettingsKeys.focusEndSound) }
    }

    var breakEndSound: String {
        didSet { defaults.set(breakEndSound, forKey: SettingsKeys.breakEndSound) }
    }

    var onNotificationsEnabled: (() -> Void)?

    var notificationsEnabled: Bool {
        didSet {
            defaults.set(notificationsEnabled, forKey: SettingsKeys.notificationsEnabled)
            if notificationsEnabled { onNotificationsEnabled?() }
        }
    }

    var autoDismissSeconds: Int {
        didSet {
            let validated = max(0, min(30, autoDismissSeconds))
            defaults.set(validated, forKey: SettingsKeys.autoDismissSeconds)
            if autoDismissSeconds != validated { autoDismissSeconds = validated }
        }
    }

    var slicesEnabled: Bool {
        didSet { defaults.set(slicesEnabled, forKey: SettingsKeys.slicesEnabled) }
    }

    var sliceRotationInterval: Int {
        didSet {
            let validated = max(60, min(600, sliceRotationInterval))
            defaults.set(validated, forKey: SettingsKeys.sliceRotationInterval)
            if sliceRotationInterval != validated { sliceRotationInterval = validated }
        }
    }

    var sliceEndSound: String {
        didSet { defaults.set(sliceEndSound, forKey: SettingsKeys.sliceEndSound) }
    }

    var stealFocusOnPop: Bool {
        didSet { defaults.set(stealFocusOnPop, forKey: SettingsKeys.stealFocusOnPop) }
    }

    var sliceAutoAdvance: Bool {
        didSet { defaults.set(sliceAutoAdvance, forKey: SettingsKeys.sliceAutoAdvance) }
    }

    var focusOvertimeReminderInterval: Int {
        didSet {
            let validated = max(60, min(1200, focusOvertimeReminderInterval))
            defaults.set(validated, forKey: SettingsKeys.focusOvertimeReminderInterval)
            if focusOvertimeReminderInterval != validated { focusOvertimeReminderInterval = validated }
        }
    }

    var focusOvertimeReminderSound: String {
        didSet { defaults.set(focusOvertimeReminderSound, forKey: SettingsKeys.focusOvertimeReminderSound) }
    }

    var sliceOvertimeReminderInterval: Int {
        didSet {
            let validated = max(5, min(60, sliceOvertimeReminderInterval))
            defaults.set(validated, forKey: SettingsKeys.sliceOvertimeReminderInterval)
            if sliceOvertimeReminderInterval != validated { sliceOvertimeReminderInterval = validated }
        }
    }

    var sliceOvertimeReminderSound: String {
        didSet { defaults.set(sliceOvertimeReminderSound, forKey: SettingsKeys.sliceOvertimeReminderSound) }
    }

    var showSliceTimerInMenuBar: Bool {
        didSet { defaults.set(showSliceTimerInMenuBar, forKey: SettingsKeys.showSliceTimerInMenuBar) }
    }

    var showSliceFocusInMenuBar: Bool {
        didSet { defaults.set(showSliceFocusInMenuBar, forKey: SettingsKeys.showSliceFocusInMenuBar) }
    }

    var showSessionTimerInMenuBar: Bool {
        didSet { defaults.set(showSessionTimerInMenuBar, forKey: SettingsKeys.showSessionTimerInMenuBar) }
    }

    var showSlicePositionInMenuBar: Bool {
        didSet { defaults.set(showSlicePositionInMenuBar, forKey: SettingsKeys.showSlicePositionInMenuBar) }
    }

    var lastBlockType: BlockType {
        didSet {
            defaults.set(lastBlockType.rawValue, forKey: SettingsKeys.lastBlockType)
        }
    }

    var onHotkeySettingsChanged: (() -> Void)?

    var globalHotkeyEnabled: Bool {
        didSet {
            defaults.set(globalHotkeyEnabled, forKey: SettingsKeys.globalHotkeyEnabled)
            onHotkeySettingsChanged?()
        }
    }

    var globalHotkeyKeyCode: UInt32 {
        didSet {
            defaults.set(globalHotkeyKeyCode, forKey: SettingsKeys.globalHotkeyKeyCode)
            onHotkeySettingsChanged?()
        }
    }

    var globalHotkeyModifiers: UInt32 {
        didSet {
            defaults.set(globalHotkeyModifiers, forKey: SettingsKeys.globalHotkeyModifiers)
            onHotkeySettingsChanged?()
        }
    }

    var rotationHotkeyEnabled: Bool {
        didSet {
            defaults.set(rotationHotkeyEnabled, forKey: SettingsKeys.rotationHotkeyEnabled)
            onHotkeySettingsChanged?()
        }
    }

    var rotationHotkeyKeyCode: UInt32 {
        didSet {
            defaults.set(rotationHotkeyKeyCode, forKey: SettingsKeys.rotationHotkeyKeyCode)
            onHotkeySettingsChanged?()
        }
    }

    var rotationHotkeyModifiers: UInt32 {
        didSet {
            defaults.set(rotationHotkeyModifiers, forKey: SettingsKeys.rotationHotkeyModifiers)
            onHotkeySettingsChanged?()
        }
    }

    var bulkEditMode: Bool {
        didSet { defaults.set(bulkEditMode, forKey: SettingsKeys.bulkEditMode) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        // Durations (must be positive)
        self.focusDuration = Self.loadInt(from: defaults, key: SettingsKeys.focusDuration, default: Defaults.focusDuration)
        self.shortBreakDuration = Self.loadInt(from: defaults, key: SettingsKeys.shortBreakDuration, default: Defaults.shortBreakDuration)
        self.longBreakDuration = Self.loadInt(from: defaults, key: SettingsKeys.longBreakDuration, default: Defaults.longBreakDuration)
        self.blocksBeforeLongBreak = Self.loadInt(from: defaults, key: SettingsKeys.blocksBeforeLongBreak, default: Defaults.blocksBeforeLongBreak)

        // Booleans
        self.autoAdvance = Self.loadBool(from: defaults, key: SettingsKeys.autoAdvance, default: Defaults.autoAdvance)
        self.showTimerInMenuBar = Self.loadBool(from: defaults, key: SettingsKeys.showTimerInMenuBar, default: Defaults.showTimerInMenuBar)
        self.popOnComplete = Self.loadBool(from: defaults, key: SettingsKeys.popOnComplete, default: Defaults.popOnComplete)
        self.showFocusInMenuBar = Self.loadBool(from: defaults, key: SettingsKeys.showFocusInMenuBar, default: Defaults.showFocusInMenuBar)
        self.notificationsEnabled = Self.loadBool(from: defaults, key: SettingsKeys.notificationsEnabled, default: Defaults.notificationsEnabled)
        self.slicesEnabled = Self.loadBool(from: defaults, key: SettingsKeys.slicesEnabled, default: Defaults.slicesEnabled)
        self.stealFocusOnPop = Self.loadBool(from: defaults, key: SettingsKeys.stealFocusOnPop, default: Defaults.stealFocusOnPop)
        self.sliceAutoAdvance = Self.loadBool(from: defaults, key: SettingsKeys.sliceAutoAdvance, default: Defaults.sliceAutoAdvance)
        self.globalHotkeyEnabled = Self.loadBool(from: defaults, key: SettingsKeys.globalHotkeyEnabled, default: Defaults.globalHotkeyEnabled)
        self.rotationHotkeyEnabled = Self.loadBool(from: defaults, key: SettingsKeys.rotationHotkeyEnabled, default: Defaults.rotationHotkeyEnabled)
        self.bulkEditMode = Self.loadBool(from: defaults, key: SettingsKeys.bulkEditMode, default: Defaults.bulkEditMode)

        // Strings
        self.focusEndSound = Self.loadString(from: defaults, key: SettingsKeys.focusEndSound, default: Defaults.focusEndSound)
        self.breakEndSound = Self.loadString(from: defaults, key: SettingsKeys.breakEndSound, default: Defaults.breakEndSound)
        self.sliceEndSound = Self.loadString(from: defaults, key: SettingsKeys.sliceEndSound, default: Defaults.sliceEndSound)
        self.focusOvertimeReminderSound = Self.loadString(from: defaults, key: SettingsKeys.focusOvertimeReminderSound, default: Defaults.focusOvertimeReminderSound)
        self.sliceOvertimeReminderSound = Self.loadString(from: defaults, key: SettingsKeys.sliceOvertimeReminderSound, default: Defaults.sliceOvertimeReminderSound)

        // Clamped integers
        self.autoDismissSeconds = Self.loadInt(from: defaults, key: SettingsKeys.autoDismissSeconds, default: Defaults.autoDismissSeconds, min: 0, max: 30)
        self.sliceRotationInterval = Self.loadInt(from: defaults, key: SettingsKeys.sliceRotationInterval, default: Defaults.sliceRotationInterval)
        self.focusOvertimeReminderInterval = Self.loadInt(from: defaults, key: SettingsKeys.focusOvertimeReminderInterval, default: Defaults.focusOvertimeReminderInterval, min: 60, max: 1200)
        self.sliceOvertimeReminderInterval = Self.loadInt(from: defaults, key: SettingsKeys.sliceOvertimeReminderInterval, default: Defaults.sliceOvertimeReminderInterval, min: 5, max: 60)

        self.showSliceTimerInMenuBar = Self.loadBool(from: defaults, key: SettingsKeys.showSliceTimerInMenuBar, default: Defaults.showSliceTimerInMenuBar)
        self.showSliceFocusInMenuBar = Self.loadBool(from: defaults, key: SettingsKeys.showSliceFocusInMenuBar, default: Defaults.showSliceFocusInMenuBar)
        self.showSessionTimerInMenuBar = Self.loadBool(from: defaults, key: SettingsKeys.showSessionTimerInMenuBar, default: Defaults.showSessionTimerInMenuBar)
        self.showSlicePositionInMenuBar = Self.loadBool(from: defaults, key: SettingsKeys.showSlicePositionInMenuBar, default: Defaults.showSlicePositionInMenuBar)

        // Enum-backed
        self.lastBlockType = Self.loadRawRepresentable(from: defaults, key: SettingsKeys.lastBlockType, default: Defaults.lastBlockType)

        // UInt32 (hotkey codes)
        self.globalHotkeyKeyCode = Self.loadUInt32(from: defaults, key: SettingsKeys.globalHotkeyKeyCode, default: Defaults.globalHotkeyKeyCode)
        self.globalHotkeyModifiers = Self.loadUInt32(from: defaults, key: SettingsKeys.globalHotkeyModifiers, default: Defaults.globalHotkeyModifiers)
        self.rotationHotkeyKeyCode = Self.loadUInt32(from: defaults, key: SettingsKeys.rotationHotkeyKeyCode, default: Defaults.rotationHotkeyKeyCode)
        self.rotationHotkeyModifiers = Self.loadUInt32(from: defaults, key: SettingsKeys.rotationHotkeyModifiers, default: Defaults.rotationHotkeyModifiers)
    }

    // MARK: - UserDefaults Helpers

    private static func loadInt(
        from defaults: UserDefaults,
        key: String,
        default defaultValue: Int,
        min minValue: Int? = nil,
        max maxValue: Int? = nil
    ) -> Int {
        let raw = defaults.integer(forKey: key)
        guard raw > 0 || defaults.object(forKey: key) != nil else {
            return defaultValue
        }
        var value = raw > 0 ? raw : defaultValue
        if let minValue { value = Swift.max(minValue, value) }
        if let maxValue { value = Swift.min(maxValue, value) }
        return value
    }

    private static func loadBool(
        from defaults: UserDefaults,
        key: String,
        default defaultValue: Bool
    ) -> Bool {
        defaults.object(forKey: key) != nil
            ? defaults.bool(forKey: key)
            : defaultValue
    }

    private static func loadString(
        from defaults: UserDefaults,
        key: String,
        default defaultValue: String
    ) -> String {
        defaults.string(forKey: key) ?? defaultValue
    }

    private static func loadUInt32(
        from defaults: UserDefaults,
        key: String,
        default defaultValue: UInt32
    ) -> UInt32 {
        defaults.object(forKey: key) != nil
            ? UInt32(defaults.integer(forKey: key))
            : defaultValue
    }

    private static func loadRawRepresentable<T: RawRepresentable>(
        from defaults: UserDefaults,
        key: String,
        default defaultValue: T
    ) -> T where T.RawValue == String {
        if let raw = defaults.string(forKey: key),
           let value = T(rawValue: raw) {
            return value
        }
        return defaultValue
    }
}
