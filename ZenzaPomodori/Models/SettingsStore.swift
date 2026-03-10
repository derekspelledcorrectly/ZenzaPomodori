import Foundation
import Observation

@Observable
final class SettingsStore {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var focusDuration: Int {
        get {
            let value = defaults.integer(forKey: SettingsKeys.focusDuration)
            return value > 0 ? value : Defaults.focusDuration
        }
        set {
            defaults.set(max(60, newValue), forKey: SettingsKeys.focusDuration)
        }
    }

    var shortBreakDuration: Int {
        get {
            let value = defaults.integer(forKey: SettingsKeys.shortBreakDuration)
            return value > 0 ? value : Defaults.shortBreakDuration
        }
        set {
            defaults.set(max(60, newValue), forKey: SettingsKeys.shortBreakDuration)
        }
    }

    var longBreakDuration: Int {
        get {
            let value = defaults.integer(forKey: SettingsKeys.longBreakDuration)
            return value > 0 ? value : Defaults.longBreakDuration
        }
        set {
            defaults.set(max(60, newValue), forKey: SettingsKeys.longBreakDuration)
        }
    }

    var blocksBeforeLongBreak: Int {
        get {
            let value = defaults.integer(forKey: SettingsKeys.blocksBeforeLongBreak)
            return value > 0 ? value : Defaults.blocksBeforeLongBreak
        }
        set {
            defaults.set(max(1, newValue), forKey: SettingsKeys.blocksBeforeLongBreak)
        }
    }

    var autoAdvance: Bool {
        get {
            if defaults.object(forKey: SettingsKeys.autoAdvance) == nil {
                return Defaults.autoAdvance
            }
            return defaults.bool(forKey: SettingsKeys.autoAdvance)
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.autoAdvance)
        }
    }

    var soundEnabled: Bool {
        get {
            if defaults.object(forKey: SettingsKeys.soundEnabled) == nil {
                return Defaults.soundEnabled
            }
            return defaults.bool(forKey: SettingsKeys.soundEnabled)
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.soundEnabled)
        }
    }
}
