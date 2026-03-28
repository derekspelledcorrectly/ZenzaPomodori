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

    var soundEnabled: Bool {
        didSet { defaults.set(soundEnabled, forKey: SettingsKeys.soundEnabled) }
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

    var microRotationInterval: Int {
        didSet {
            let validated = max(60, min(600, microRotationInterval))
            defaults.set(validated, forKey: SettingsKeys.microRotationInterval)
            if microRotationInterval != validated { microRotationInterval = validated }
        }
    }

    var sliceSoundEnabled: Bool {
        didSet { defaults.set(sliceSoundEnabled, forKey: SettingsKeys.sliceSoundEnabled) }
    }

    var sliceEndSound: String {
        didSet { defaults.set(sliceEndSound, forKey: SettingsKeys.sliceEndSound) }
    }

    var stealFocusOnRotation: Bool {
        didSet { defaults.set(stealFocusOnRotation, forKey: SettingsKeys.stealFocusOnRotation) }
    }

    var sliceMenuBarFormat: SliceMenuBarFormat {
        didSet {
            defaults.set(sliceMenuBarFormat.rawValue, forKey: SettingsKeys.sliceMenuBarFormat)
        }
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

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let focus = defaults.integer(forKey: SettingsKeys.focusDuration)
        self.focusDuration = focus > 0 ? focus : Defaults.focusDuration

        let shortBreak = defaults.integer(forKey: SettingsKeys.shortBreakDuration)
        self.shortBreakDuration = shortBreak > 0 ? shortBreak : Defaults.shortBreakDuration

        let longBreak = defaults.integer(forKey: SettingsKeys.longBreakDuration)
        self.longBreakDuration = longBreak > 0 ? longBreak : Defaults.longBreakDuration

        let blocks = defaults.integer(forKey: SettingsKeys.blocksBeforeLongBreak)
        self.blocksBeforeLongBreak = blocks > 0 ? blocks : Defaults.blocksBeforeLongBreak

        if defaults.object(forKey: SettingsKeys.autoAdvance) != nil {
            self.autoAdvance = defaults.bool(forKey: SettingsKeys.autoAdvance)
        } else {
            self.autoAdvance = Defaults.autoAdvance
        }

        if defaults.object(forKey: SettingsKeys.soundEnabled) != nil {
            self.soundEnabled = defaults.bool(forKey: SettingsKeys.soundEnabled)
        } else {
            self.soundEnabled = Defaults.soundEnabled
        }

        if defaults.object(forKey: SettingsKeys.showTimerInMenuBar) != nil {
            self.showTimerInMenuBar = defaults.bool(forKey: SettingsKeys.showTimerInMenuBar)
        } else {
            self.showTimerInMenuBar = Defaults.showTimerInMenuBar
        }

        if defaults.object(forKey: SettingsKeys.popOnComplete) != nil {
            self.popOnComplete = defaults.bool(forKey: SettingsKeys.popOnComplete)
        } else {
            self.popOnComplete = Defaults.popOnComplete
        }

        if defaults.object(forKey: SettingsKeys.showFocusInMenuBar) != nil {
            self.showFocusInMenuBar = defaults.bool(forKey: SettingsKeys.showFocusInMenuBar)
        } else {
            self.showFocusInMenuBar = Defaults.showFocusInMenuBar
        }

        if let sound = defaults.string(forKey: SettingsKeys.focusEndSound) {
            self.focusEndSound = sound
        } else {
            self.focusEndSound = Defaults.focusEndSound
        }

        if let sound = defaults.string(forKey: SettingsKeys.breakEndSound) {
            self.breakEndSound = sound
        } else {
            self.breakEndSound = Defaults.breakEndSound
        }

        if defaults.object(forKey: SettingsKeys.notificationsEnabled) != nil {
            self.notificationsEnabled = defaults.bool(forKey: SettingsKeys.notificationsEnabled)
        } else {
            self.notificationsEnabled = Defaults.notificationsEnabled
        }

        let dismiss = defaults.integer(forKey: SettingsKeys.autoDismissSeconds)
        if defaults.object(forKey: SettingsKeys.autoDismissSeconds) != nil {
            self.autoDismissSeconds = max(0, min(30, dismiss))
        } else {
            self.autoDismissSeconds = Defaults.autoDismissSeconds
        }

        if defaults.object(forKey: SettingsKeys.slicesEnabled) != nil {
            self.slicesEnabled = defaults.bool(forKey: SettingsKeys.slicesEnabled)
        } else {
            self.slicesEnabled = Defaults.slicesEnabled
        }

        let microInterval = defaults.integer(forKey: SettingsKeys.microRotationInterval)
        self.microRotationInterval = microInterval > 0 ? microInterval : Defaults.microRotationInterval

        if defaults.object(forKey: SettingsKeys.sliceSoundEnabled) != nil {
            self.sliceSoundEnabled = defaults.bool(forKey: SettingsKeys.sliceSoundEnabled)
        } else {
            self.sliceSoundEnabled = Defaults.sliceSoundEnabled
        }

        if let sound = defaults.string(forKey: SettingsKeys.sliceEndSound) {
            self.sliceEndSound = sound
        } else {
            self.sliceEndSound = Defaults.sliceEndSound
        }

        if defaults.object(forKey: SettingsKeys.stealFocusOnRotation) != nil {
            self.stealFocusOnRotation = defaults.bool(forKey: SettingsKeys.stealFocusOnRotation)
        } else {
            self.stealFocusOnRotation = Defaults.stealFocusOnRotation
        }

        if let raw = defaults.string(forKey: SettingsKeys.sliceMenuBarFormat),
           let format = SliceMenuBarFormat(rawValue: raw) {
            self.sliceMenuBarFormat = format
        } else {
            self.sliceMenuBarFormat = Defaults.sliceMenuBarFormat
        }

        if let raw = defaults.string(forKey: SettingsKeys.lastBlockType),
           let blockType = BlockType(rawValue: raw) {
            self.lastBlockType = blockType
        } else {
            self.lastBlockType = Defaults.lastBlockType
        }

        if defaults.object(forKey: SettingsKeys.globalHotkeyEnabled) != nil {
            self.globalHotkeyEnabled = defaults.bool(forKey: SettingsKeys.globalHotkeyEnabled)
        } else {
            self.globalHotkeyEnabled = Defaults.globalHotkeyEnabled
        }

        let keyCode = defaults.object(forKey: SettingsKeys.globalHotkeyKeyCode)
        if keyCode != nil {
            self.globalHotkeyKeyCode = UInt32(defaults.integer(forKey: SettingsKeys.globalHotkeyKeyCode))
        } else {
            self.globalHotkeyKeyCode = Defaults.globalHotkeyKeyCode
        }

        let modifiers = defaults.object(forKey: SettingsKeys.globalHotkeyModifiers)
        if modifiers != nil {
            self.globalHotkeyModifiers = UInt32(defaults.integer(forKey: SettingsKeys.globalHotkeyModifiers))
        } else {
            self.globalHotkeyModifiers = Defaults.globalHotkeyModifiers
        }

        if defaults.object(forKey: SettingsKeys.rotationHotkeyEnabled) != nil {
            self.rotationHotkeyEnabled = defaults.bool(forKey: SettingsKeys.rotationHotkeyEnabled)
        } else {
            self.rotationHotkeyEnabled = Defaults.rotationHotkeyEnabled
        }

        let rotKeyCode = defaults.object(forKey: SettingsKeys.rotationHotkeyKeyCode)
        if rotKeyCode != nil {
            self.rotationHotkeyKeyCode = UInt32(defaults.integer(forKey: SettingsKeys.rotationHotkeyKeyCode))
        } else {
            self.rotationHotkeyKeyCode = Defaults.rotationHotkeyKeyCode
        }

        let rotModifiers = defaults.object(forKey: SettingsKeys.rotationHotkeyModifiers)
        if rotModifiers != nil {
            self.rotationHotkeyModifiers = UInt32(defaults.integer(forKey: SettingsKeys.rotationHotkeyModifiers))
        } else {
            self.rotationHotkeyModifiers = Defaults.rotationHotkeyModifiers
        }
    }
}
