import SwiftUI

struct SettingsView: View {
    @Bindable var settings: SettingsStore

    var body: some View {
        Form {
            Section("Timer Durations") {
                Stepper(
                    "Focus: \(settings.focusDuration / 60) min",
                    value: Binding(
                        get: { settings.focusDuration / 60 },
                        set: { settings.focusDuration = $0 * 60 }
                    ),
                    in: 1...120
                )

                Stepper(
                    "Short Break: \(settings.shortBreakDuration / 60) min",
                    value: Binding(
                        get: { settings.shortBreakDuration / 60 },
                        set: { settings.shortBreakDuration = $0 * 60 }
                    ),
                    in: 1...60
                )

                Stepper(
                    "Long Break: \(settings.longBreakDuration / 60) min",
                    value: Binding(
                        get: { settings.longBreakDuration / 60 },
                        set: { settings.longBreakDuration = $0 * 60 }
                    ),
                    in: 1...120
                )

                Stepper(
                    "Blocks before long break: \(settings.blocksBeforeLongBreak)",
                    value: Binding(
                        get: { settings.blocksBeforeLongBreak },
                        set: { settings.blocksBeforeLongBreak = $0 }
                    ),
                    in: 1...10
                )
            }

            Section("Behavior") {
                Toggle("Auto-advance", isOn: Binding(
                    get: { settings.autoAdvance },
                    set: { settings.autoAdvance = $0 }
                ))

                Toggle("Notification sound", isOn: Binding(
                    get: { settings.soundEnabled },
                    set: { settings.soundEnabled = $0 }
                ))
            }
        }
        .formStyle(.grouped)
        .frame(width: 320)
        .fixedSize()
    }
}

#Preview {
    SettingsView(settings: SettingsStore())
}
