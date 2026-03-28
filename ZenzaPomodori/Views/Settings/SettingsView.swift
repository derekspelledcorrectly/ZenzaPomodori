import SwiftUI

struct SettingsView: View {
    @Bindable var settings: SettingsStore
    let soundService: SoundService
    var onBack: (() -> Void)?

    private static let focusOptions = [5, 10, 15, 20, 25, 30, 45, 60, 90, 120]
    private static let shortBreakOptions = [1, 2, 3, 5, 10, 15, 20]
    private static let longBreakOptions = [5, 10, 15, 20, 25, 30, 45, 60]

    var body: some View {
        VStack(spacing: 0) {
            if let onBack {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                    }
                    .buttonStyle(.borderless)
                    Text("Settings")
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 4)
            }
            settingsForm
            if let onBack {
                Button("Done", action: onBack)
                    .keyboardShortcut(.defaultAction)
                    .padding(.bottom, 12)
            }
        }
        .frame(width: 320)
        .fixedSize()
    }

    private var settingsForm: some View {
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
                    soundPicker("Focus end", sound: Binding(
                        get: { settings.focusEndSound },
                        set: { settings.focusEndSound = $0 }
                    ))
                    soundPicker("Break end", sound: Binding(
                        get: { settings.breakEndSound },
                        set: { settings.breakEndSound = $0 }
                    ))
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

            Section("Global Hotkey") {
                Toggle("Enable global hotkey", isOn: $settings.globalHotkeyEnabled)

                if settings.globalHotkeyEnabled {
                    HStack {
                        Text("Shortcut")
                        Spacer()
                        HotkeyRecorderView(
                            keyCode: $settings.globalHotkeyKeyCode,
                            modifiers: $settings.globalHotkeyModifiers
                        )
                        .frame(width: 120, height: 24)
                    }
                }
            }

            Section("Slices") {
                Toggle("Enable Slices mode", isOn: $settings.slicesEnabled)

                if settings.slicesEnabled {
                    Picker("Max rotation interval", selection: sliceIntervalBinding) {
                        ForEach([1, 2, 3, 4, 5, 7, 10], id: \.self) { min in
                            Text("\(min) min").tag(min)
                        }
                    }

                    Toggle("Sound on rotation", isOn: $settings.sliceSoundEnabled)

                    if settings.sliceSoundEnabled {
                        soundPicker("Rotation sound", sound: Binding(
                            get: { settings.sliceEndSound },
                            set: { settings.sliceEndSound = $0 }
                        ))
                    }

                    Toggle("Steal focus on rotation", isOn: $settings.stealFocusOnRotation)

                    Picker("Menu bar format", selection: $settings.sliceMenuBarFormat) {
                        Text("Slice timer only").tag(SliceMenuBarFormat.sliceOnly)
                        Text("Both timers").tag(SliceMenuBarFormat.dualTimer)
                        Text("Timer + position").tag(SliceMenuBarFormat.slicePosition)
                        Text("Compact").tag(SliceMenuBarFormat.compact)
                    }

                    Toggle("Rotation hotkey", isOn: $settings.rotationHotkeyEnabled)

                    if settings.rotationHotkeyEnabled {
                        HStack {
                            Text("Shortcut")
                            Spacer()
                            HotkeyRecorderView(
                                keyCode: $settings.rotationHotkeyKeyCode,
                                modifiers: $settings.rotationHotkeyModifiers
                            )
                            .frame(width: 120, height: 24)
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
    }

    private var sliceIntervalBinding: Binding<Int> {
        Binding(
            get: { settings.sliceRotationInterval / 60 },
            set: { settings.sliceRotationInterval = $0 * 60 }
        )
    }

    private func soundPicker(_ label: String, sound: Binding<String>) -> some View {
        HStack {
            Picker(label, selection: Binding(
                get: { sound.wrappedValue },
                set: { newValue in
                    sound.wrappedValue = newValue
                    soundService.play(newValue)
                }
            )) {
                ForEach(SoundService.availableSounds, id: \.self) { name in
                    Text(name).tag(name)
                }
            }

            Button(action: { soundService.play(sound.wrappedValue) }) {
                Image(systemName: "play.circle")
            }
            .buttonStyle(.borderless)
            .help("Preview sound")
        }
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
