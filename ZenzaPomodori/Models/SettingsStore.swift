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

    var selectedSound: String {
        didSet { defaults.set(selectedSound, forKey: SettingsKeys.selectedSound) }
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

        if let sound = defaults.string(forKey: SettingsKeys.selectedSound) {
            self.selectedSound = sound
        } else {
            self.selectedSound = Defaults.selectedSound
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
    }
}
