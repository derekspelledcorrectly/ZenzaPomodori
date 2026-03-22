import SwiftUI

struct SettingsView: View {
    @Bindable var settings: SettingsStore
    let soundService: SoundService

    private static let focusOptions = [5, 10, 15, 20, 25, 30, 45, 60, 90, 120]
    private static let shortBreakOptions = [1, 2, 3, 5, 10, 15, 20]
    private static let longBreakOptions = [5, 10, 15, 20, 25, 30, 45, 60]

    var body: some View {
        Form {
            Section("Timer Durations") {
                Picker("Focus", selection: minutesBinding(\.focusDuration)) {
                    ForEach(Self.focusOptions, id: \.self) { min in
                        Text("\(min) min").tag(min)
                    }
                }

                Picker("Short Break", selection: minutesBinding(\.shortBreakDuration)) {
                    ForEach(Self.shortBreakOptions, id: \.self) { min in
                        Text("\(min) min").tag(min)
                    }
                }

                Picker("Long Break", selection: minutesBinding(\.longBreakDuration)) {
                    ForEach(Self.longBreakOptions, id: \.self) { min in
                        Text("\(min) min").tag(min)
                    }
                }

                HStack {
                    Text("Blocks before long break")
                    Spacer()
                    HStack(spacing: 4) {
                        Button(action: { settings.blocksBeforeLongBreak -= 1 }) {
                            Image(systemName: "minus")
                        }
                        .disabled(settings.blocksBeforeLongBreak <= 1)

                        Text("\(settings.blocksBeforeLongBreak)")
                            .monospacedDigit()
                            .frame(minWidth: 20, alignment: .center)

                        Button(action: { settings.blocksBeforeLongBreak += 1 }) {
                            Image(systemName: "plus")
                        }
                        .disabled(settings.blocksBeforeLongBreak >= 10)
                    }
                }
            }

            Section("Sound") {
                Toggle("Play sound on complete", isOn: Binding(
                    get: { settings.soundEnabled },
                    set: { settings.soundEnabled = $0 }
                ))

                if settings.soundEnabled {
                    HStack {
                        Picker("Sound", selection: Binding(
                            get: { settings.selectedSound },
                            set: { settings.selectedSound = $0 }
                        )) {
                            ForEach(SoundService.availableSounds, id: \.self) { name in
                                Text(name).tag(name)
                            }
                        }

                        Button(action: { soundService.play(settings.selectedSound) }) {
                            Image(systemName: "play.circle")
                        }
                        .buttonStyle(.borderless)
                        .help("Preview sound")
                    }
                }
            }

            Section("Behavior") {
                Toggle("Auto-advance", isOn: Binding(
                    get: { settings.autoAdvance },
                    set: { settings.autoAdvance = $0 }
                ))

                Toggle("Pop open on complete", isOn: Binding(
                    get: { settings.popOnComplete },
                    set: { settings.popOnComplete = $0 }
                ))

                if settings.popOnComplete {
                    HStack {
                        Text("Auto-dismiss after")
                        Spacer()
                        HStack(spacing: 4) {
                            Button(action: { settings.autoDismissSeconds -= 1 }) {
                                Image(systemName: "minus")
                            }
                            .disabled(settings.autoDismissSeconds <= 0)

                            Text(settings.autoDismissSeconds == 0
                                 ? "Off"
                                 : "\(settings.autoDismissSeconds)s")
                                .monospacedDigit()
                                .frame(minWidth: 30, alignment: .center)

                            Button(action: { settings.autoDismissSeconds += 1 }) {
                                Image(systemName: "plus")
                            }
                            .disabled(settings.autoDismissSeconds >= 30)
                        }
                    }
                }

                Toggle("Show timer in menu bar", isOn: Binding(
                    get: { settings.showTimerInMenuBar },
                    set: { settings.showTimerInMenuBar = $0 }
                ))

                Toggle("Show focus in menu bar", isOn: Binding(
                    get: { settings.showFocusInMenuBar },
                    set: { settings.showFocusInMenuBar = $0 }
                ))
            }

            Section("Notifications") {
                Toggle("Send notifications", isOn: Binding(
                    get: { settings.notificationsEnabled },
                    set: { settings.notificationsEnabled = $0 }
                ))
            }
        }
        .formStyle(.grouped)
        .frame(width: 320)
        .fixedSize()
    }

    private func minutesBinding(_ keyPath: ReferenceWritableKeyPath<SettingsStore, Int>) -> Binding<Int> {
        Binding(
            get: { settings[keyPath: keyPath] / 60 },
            set: { settings[keyPath: keyPath] = $0 * 60 }
        )
    }
}

#Preview {
    SettingsView(settings: SettingsStore(), soundService: SoundService())
}
