import SwiftUI

enum SettingsTab: String, CaseIterable {
    case timer = "Timer"
    case soundsAndAlerts = "Sounds"
    case behavior = "Behavior"
}

struct SettingsView: View {
    @Bindable var settings: SettingsStore
    let soundService: SoundService
    var onBack: (() -> Void)?

    @State private var selectedTab: SettingsTab = .timer
    @AppStorage("behaviorAdvancedExpanded") private var advancedExpanded = false

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
                    .accessibilityLabel("Back")
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
                Button(action: onBack) { EmptyView() }
                    .keyboardShortcut(.escape, modifiers: [])
                    .frame(width: 0, height: 0)
                    .opacity(0)
            }
        }
        .frame(width: 320)
    }

    private var settingsForm: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                ForEach(SettingsTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 4)

            switch selectedTab {
            case .timer:
                timerTab
            case .soundsAndAlerts:
                soundsTab
            case .behavior:
                behaviorTab
            }

            tabCycleButtons
        }
    }

    private var tabCycleButtons: some View {
        Group {
            Button("") { cycleTab(forward: false) }
                .keyboardShortcut(.leftArrow, modifiers: .command)
            Button("") { cycleTab(forward: true) }
                .keyboardShortcut(.rightArrow, modifiers: .command)
        }
        .frame(width: 0, height: 0)
        .opacity(0)
    }

    private func cycleTab(forward: Bool) {
        let tabs = SettingsTab.allCases
        guard let index = tabs.firstIndex(of: selectedTab) else { return }
        if forward, index < tabs.count - 1 {
            selectedTab = tabs[index + 1]
        } else if !forward, index > 0 {
            selectedTab = tabs[index - 1]
        }
    }

    // MARK: - Timer Tab

    private var timerTab: some View {
        Form {
            Section("Durations") {
                Picker("Focus", selection: minutesBinding(\.focusDuration)) {
                    ForEach(Self.focusOptions, id: \.self) { min in
                        Text("\(min) min").tag(min)
                    }
                }
                .help("How long each focus block lasts before a break")

                Picker("Short Break", selection: minutesBinding(\.shortBreakDuration)) {
                    ForEach(Self.shortBreakOptions, id: \.self) { min in
                        Text("\(min) min").tag(min)
                    }
                }
                .help("Rest period between focus blocks")

                Picker("Long Break", selection: minutesBinding(\.longBreakDuration)) {
                    ForEach(Self.longBreakOptions, id: \.self) { min in
                        Text("\(min) min").tag(min)
                    }
                }
                .help("Extended rest after completing a full cycle of focus blocks")

                StepperRow(
                    label: "Blocks before long break",
                    value: $settings.blocksBeforeLongBreak,
                    range: 1...10,
                    helpText: "How many focus blocks to complete before earning a long break"
                )
            }

            Section("Slices") {
                Toggle("Enable Slices mode", isOn: $settings.slicesEnabled)
                    .help("Split focus blocks into shorter intervals to rotate between tasks in your list")

                if settings.slicesEnabled {
                    Picker("Max rotation interval", selection: sliceIntervalBinding) {
                        ForEach([1, 2, 3, 4, 5, 7, 10], id: \.self) { min in
                            Text("\(min) min").tag(min)
                        }
                    }
                    .help("Maximum time on one slice before rotating to the next in your list")
                }
            }
        }
        .formStyle(.grouped)
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Sounds & Alerts Tab

    private var soundsTab: some View {
        Form {
            Section("Completion Sounds") {
                soundPickerWithNone(
                    "Focus end",
                    sound: Binding(
                        get: { settings.focusEndSound },
                        set: { settings.focusEndSound = $0 }
                    ))

                soundPickerWithNone(
                    "Break end",
                    sound: Binding(
                        get: { settings.breakEndSound },
                        set: { settings.breakEndSound = $0 }
                    ))

                if settings.slicesEnabled {
                    soundPickerWithNone(
                        "Slice rotation",
                        sound: Binding(
                            get: { settings.sliceEndSound },
                            set: { settings.sliceEndSound = $0 }
                        ))
                }
            }

            Section {
                Picker("Every", selection: focusReminderMinutesBinding) {
                    Text("Never").tag(0)
                    Text("1 min").tag(1)
                    Text("2 min").tag(2)
                    Text("3 min").tag(3)
                    Text("5 min").tag(5)
                    Text("10 min").tag(10)
                    Text("15 min").tag(15)
                    Text("20 min").tag(20)
                }
                .help("How often the reminder repeats during focus overtime")
                .disabled(settings.autoAdvance)
                .opacity(settings.autoAdvance ? 0.4 : 1)

                if settings.autoAdvance {
                    Text("Turn off Auto-advance blocks in Behavior to use")
                        .font(.caption)
                        .foregroundStyle(.primary.opacity(0.9))
                        .help("Turn off Auto-advance blocks in Behavior to use")
                }

                if settings.focusOvertimeReminderInterval > 0 && !settings.autoAdvance {
                    soundPickerWithNone(
                        "Reminder sound",
                        sound: Binding(
                            get: { settings.focusOvertimeReminderSound },
                            set: { settings.focusOvertimeReminderSound = $0 }
                        ))
                }
            } header: {
                Text("Focus Overtime Reminder")
                    .foregroundStyle(settings.autoAdvance ? .tertiary : .primary)
            }

            if settings.slicesEnabled {
                Section {
                    Picker("Every", selection: $settings.sliceOvertimeReminderInterval) {
                        Text("Never").tag(0)
                        Text("5s").tag(5)
                        Text("10s").tag(10)
                        Text("15s").tag(15)
                        Text("20s").tag(20)
                        Text("30s").tag(30)
                        Text("45s").tag(45)
                        Text("60s").tag(60)
                    }
                    .help("How often the reminder repeats during slice overtime")
                    .disabled(settings.sliceAutoAdvance)
                    .opacity(settings.sliceAutoAdvance ? 0.4 : 1)

                    if settings.sliceAutoAdvance {
                        Text("Turn off Auto-advance slices in Behavior to use")
                            .font(.caption)
                            .foregroundStyle(.primary.opacity(0.9))
                            .help("Turn off Auto-advance slices in Behavior to use")
                    }

                    if settings.sliceOvertimeReminderInterval > 0 && !settings.sliceAutoAdvance {
                        soundPickerWithNone(
                            "Reminder sound",
                            sound: Binding(
                                get: { settings.sliceOvertimeReminderSound },
                                set: { settings.sliceOvertimeReminderSound = $0 }
                            ))
                    }
                } header: {
                    Text("Slice Overtime Reminder")
                        .foregroundStyle(settings.sliceAutoAdvance ? .tertiary : .primary)
                }
            }

            Section("Notifications") {
                Toggle(
                    "Send notifications",
                    isOn: Binding(
                        get: { settings.notificationsEnabled },
                        set: { settings.notificationsEnabled = $0 }
                    )
                )
                .help("Show macOS notifications when timers complete")
            }
        }
        .formStyle(.grouped)
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Behavior Tab

    private var behaviorTab: some View {
        Form {
            Section("Automation") {
                Toggle(
                    "Auto-advance blocks",
                    isOn: Binding(
                        get: { settings.autoAdvance },
                        set: { settings.autoAdvance = $0 }
                    )
                )
                .help("Automatically advance to the next block or break without waiting")

                if settings.slicesEnabled {
                    Toggle("Auto-advance slices", isOn: $settings.sliceAutoAdvance)
                        .help("Automatically rotate to the next task when the slice interval ends")
                }

                Toggle(
                    "Pop open on complete",
                    isOn: Binding(
                        get: { settings.popOnComplete },
                        set: { settings.popOnComplete = $0 }
                    )
                )
                .help("Open the timer popover when a block or break finishes")

                if settings.popOnComplete {
                    StepperRow(
                        label: "Auto-dismiss after",
                        value: $settings.autoDismissSeconds,
                        range: 0...30,
                        formatter: { $0 == 0 ? "Off" : "\($0)s" },
                        helpText: "Automatically close the popover after this many seconds (0 to keep it open)"
                    )
                }
            }

            Section(header: advancedHeader) {
                if advancedExpanded {
                    Toggle("Steal focus on pop open", isOn: $settings.stealFocusOnPop)
                        .help("Bring the timer to the front when it pops open, switching away from your current app")
                }
            }

            if advancedExpanded {
                Section("Menu Bar") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Focus mode:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Toggle(
                            "Show timer",
                            isOn: Binding(
                                get: { settings.showTimerInMenuBar },
                                set: { settings.showTimerInMenuBar = $0 }
                            )
                        )
                        .help("Display the countdown timer next to the menu bar icon during focus blocks")

                        Toggle(
                            "Show focus name",
                            isOn: Binding(
                                get: { settings.showFocusInMenuBar },
                                set: { settings.showFocusInMenuBar = $0 }
                            )
                        )
                        .help("Display the focus task name in the menu bar during focus blocks")
                    }

                    if settings.slicesEnabled {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Slices mode:")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Toggle("Show slice timer", isOn: $settings.showSliceTimerInMenuBar)
                                .help("Display the slice countdown timer in the menu bar")

                            Toggle("Show focus name", isOn: $settings.showSliceFocusInMenuBar)
                                .help("Show the current slice item name in the menu bar")

                            Toggle("Show slice position", isOn: $settings.showSlicePositionInMenuBar)
                                .help("Show the current slice position (e.g. 2/5)")

                            Toggle("Show session timer", isOn: $settings.showSessionTimerInMenuBar)
                                .help("Show the overall block timer alongside the slice timer")
                        }
                    }
                }

                Section("Global Hotkeys") {
                    VStack(alignment: .trailing, spacing: 6) {
                        Toggle("Show/hide timer", isOn: $settings.globalHotkeyEnabled)
                            .help("Register a global keyboard shortcut to toggle the timer popover from any app")

                        if settings.globalHotkeyEnabled {
                            HotkeyRecorderView(
                                keyCode: $settings.globalHotkeyKeyCode,
                                modifiers: $settings.globalHotkeyModifiers
                            )
                            .frame(width: 120, height: 24)
                            .help("Click to record a new shortcut. Press Escape to cancel, Delete to clear.")
                        }
                    }

                    if settings.slicesEnabled {
                        VStack(alignment: .trailing, spacing: 6) {
                            Toggle("Next slice", isOn: $settings.rotationHotkeyEnabled)
                                .help("Register a global keyboard shortcut to advance to the next slice from any app")

                            if settings.rotationHotkeyEnabled {
                                HotkeyRecorderView(
                                    keyCode: $settings.rotationHotkeyKeyCode,
                                    modifiers: $settings.rotationHotkeyModifiers
                                )
                                .frame(width: 120, height: 24)
                                .help("Click to record a new shortcut. Press Escape to cancel, Delete to clear.")
                            }
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Bindings

    private var sliceIntervalBinding: Binding<Int> {
        Binding(
            get: { settings.sliceRotationInterval / 60 },
            set: { settings.sliceRotationInterval = $0 * 60 }
        )
    }

    private var focusReminderMinutesBinding: Binding<Int> {
        Binding(
            get: { settings.focusOvertimeReminderInterval / 60 },
            set: { settings.focusOvertimeReminderInterval = $0 * 60 }
        )
    }

    private func soundPickerWithNone(_ label: String, sound: Binding<String>) -> some View {
        HStack {
            Picker(
                label,
                selection: Binding(
                    get: { sound.wrappedValue },
                    set: { newValue in
                        sound.wrappedValue = newValue
                        if newValue != SoundService.disabled {
                            soundService.play(newValue)
                        }
                    }
                )
            ) {
                Text("None").tag(SoundService.disabled)
                ForEach(SoundService.availableSounds, id: \.self) { name in
                    Text(name).tag(name)
                }
            }

            if sound.wrappedValue != SoundService.disabled {
                Button(action: { soundService.play(sound.wrappedValue) }) {
                    Image(systemName: "play.circle")
                }
                .buttonStyle(.borderless)
                .help("Preview sound")
                .accessibilityLabel("Preview \(sound.wrappedValue) sound")
            }
        }
    }

    private var advancedHeader: some View {
        Button {
            withAnimation { advancedExpanded.toggle() }
        } label: {
            HStack(spacing: 4) {
                Text("Advanced")
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .rotationEffect(.degrees(advancedExpanded ? 90 : 0))
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(advancedExpanded ? .primary : .tertiary)
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
