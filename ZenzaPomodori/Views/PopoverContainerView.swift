import SwiftUI

struct PopoverContainerView: View {
    @Bindable var router: PopoverRouter
    let timer: PomodoroTimer
    let settings: SettingsStore
    let soundService: SoundService
    let onPanelChange: (PopoverPanel) -> Void
    let rotationStore: RotationStore
    let focusNameStore: FocusNameStore
    @State private var workingItems: [RotationItem] = []
    var onSliceStart: (([RotationItem]) -> Void)?

    var body: some View {
        Group {
            switch router.activePanel {
            case .timer:
                MenuBarView(timer: timer) {
                    gearMenu
                }

            case .settings:
                SettingsView(
                    settings: settings,
                    soundService: soundService,
                    onBack: {
                        if router.sliceEngine?.isActive == true {
                            router.activePanel = .sliceActive
                        } else if settings.lastBlockType == .slices {
                            router.activePanel = .sliceSetup
                        } else {
                            router.activePanel = .timer
                        }
                    }
                )

            case .sliceSetup:
                sliceIdlePanel

            case .sliceActive:
                sliceActivePanel
            }
        }
        .onChange(of: router.activePanel) { _, panel in
            onPanelChange(panel)
        }
        .onChange(of: timer.isRunning) { _, _ in
            if router.activePanel == .timer {
                onPanelChange(.timer)
            }
        }
        .onChange(of: timer.phase) { _, newPhase in
            if newPhase == .idle && router.sliceEngine?.isActive != true {
                router.activePanel = settings.lastBlockType == .slices
                    ? .sliceSetup : .timer
            }
            if router.activePanel == .timer {
                onPanelChange(.timer)
            }
        }
        .onChange(of: settings.slicesEnabled) { _, enabled in
            if !enabled && router.activePanel == .sliceSetup {
                router.activePanel = .timer
            }
        }
        .onChange(of: settings.lastBlockType) { _, newType in
            if timer.phase == .idle {
                router.activePanel = newType == .slices ? .sliceSetup : .timer
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        )
    }

    private var isEditingActiveRotation: Bool {
        router.sliceEngine?.isActive == true
    }

    // MARK: - Gear Menu

    @ViewBuilder
    private var gearMenu: some View {
        Menu {
            if timer.phase != .idle {
                if router.activePanel == .sliceActive, let engine = router.sliceEngine {
                    Button(action: {
                        engine.pause()
                        timer.pause()
                        workingItems = engine.rotationItems
                        router.activePanel = .sliceSetup
                    }) {
                        Label("Edit Rotation List", systemImage: "list.bullet")
                    }
                    .keyboardShortcut("e", modifiers: .command)
                }

                Button(action: {
                    timer.next()
                }) {
                    Label(
                        timer.phase.isFocus ? "Finish Block" : "Finish Break",
                        systemImage: "checkmark.circle"
                    )
                }
                .keyboardShortcut(.return, modifiers: .command)

                if router.activePanel == .sliceActive, let engine = router.sliceEngine {
                    Button(action: {
                        engine.restartSlice()
                    }) {
                        Label("Restart Slice", systemImage: "arrow.counterclockwise")
                    }
                    .keyboardShortcut("r", modifiers: .command)

                    Button(action: {
                        timer.restartPhase()
                    }) {
                        Label("Restart Block Timer", systemImage: "arrow.counterclockwise.circle")
                    }
                    .keyboardShortcut("r", modifiers: [.command, .shift])
                } else {
                    Button(action: {
                        timer.restartPhase()
                    }) {
                        Label("Restart Timer", systemImage: "arrow.counterclockwise")
                    }
                    .keyboardShortcut("r", modifiers: .command)
                }

                if timer.phase.isFocus {
                    Divider()

                    Button(role: .destructive, action: {
                        if let engine = router.sliceEngine, engine.isActive {
                            engine.deactivate()
                            router.activePanel = .sliceSetup
                        } else {
                            timer.abandonBlock()
                        }
                    }) {
                        Label("Abandon Block", systemImage: "xmark.circle")
                    }
                    .keyboardShortcut(.delete, modifiers: .command)
                }

                Divider()
            }

            Button(action: {
                router.activePanel = .settings
            }) {
                Label("Settings...", systemImage: "gearshape")
            }
            .keyboardShortcut(",", modifiers: .command)
        } label: {
            Image(systemName: "gearshape")
                .foregroundStyle(.secondary)
                .overlay(alignment: .topTrailing) {
                    if timer.phase != .idle {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 6, height: 6)
                            .offset(x: 2, y: -2)
                    }
                }
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .padding(8)
        .background { gearMenuShortcuts }
    }

    @ViewBuilder
    private var gearMenuShortcuts: some View {
        if timer.phase != .idle {
            if isEditingActiveRotation, let engine = router.sliceEngine {
                hiddenShortcut(.return, modifiers: .command) {
                    engine.updateItems(workingItems)
                    engine.resume()
                    timer.resume()
                    router.activePanel = .sliceActive
                }
            } else {
                hiddenShortcut(.return, modifiers: .command) {
                    timer.next()
                }
            }
            if router.activePanel == .sliceActive, let engine = router.sliceEngine {
                hiddenShortcut("r", modifiers: .command) {
                    engine.restartSlice()
                }
                hiddenShortcut("r", modifiers: [.command, .shift]) {
                    timer.restartPhase()
                }
                hiddenShortcut("e", modifiers: .command) {
                    engine.pause()
                    timer.pause()
                    workingItems = engine.rotationItems
                    router.activePanel = .sliceSetup
                }
            } else {
                hiddenShortcut("r", modifiers: .command) {
                    timer.restartPhase()
                }
            }
            if timer.phase.isFocus {
                hiddenShortcut(.delete, modifiers: .command) {
                    if let engine = router.sliceEngine, engine.isActive {
                        engine.deactivate()
                        router.activePanel = .sliceSetup
                    } else {
                        timer.abandonBlock()
                    }
                }
            }
        }
        hiddenShortcut(",", modifiers: .command) {
            router.activePanel = .settings
        }
    }

    private func hiddenShortcut(
        _ key: KeyEquivalent,
        modifiers: EventModifiers,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) { EmptyView() }
            .keyboardShortcut(key, modifiers: modifiers)
            .frame(width: 0, height: 0)
            .opacity(0)
    }

    // MARK: - Panels

    private var sliceIdlePanel: some View {
        VStack(spacing: 12) {
            // Match TimerDisplayView's 140px frame so the picker stays
            // at the same Y position in both Focus and Slices panels.
            ConcentricTimerView(
                sliceProgress: timer.phase == .idle ? 1.0 : timer.progress,
                outerProgress: router.sliceEngine?.progress ?? 1.0,
                sliceTimeFormatted: router.sliceEngine != nil
                    ? TimeFormatting.formatted(seconds: router.sliceEngine!.sliceSecondsRemaining)
                    : TimeFormatting.formatted(seconds: settings.sliceRotationInterval),
                outerTimeFormatted: timer.formattedTime,
                outerColor: .orange,
                innerColor: timer.phase == .idle ? .accentColor.opacity(0.25) : .accentColor
            )

            if !isEditingActiveRotation {
                BlockTypePickerView(
                    blockType: Binding(
                        get: { settings.lastBlockType },
                        set: { settings.lastBlockType = $0 }
                    )
                )
            }

            SliceSetupView(
                rotationStore: rotationStore,
                focusNameStore: focusNameStore,
                workingItems: $workingItems,
                isEditing: isEditingActiveRotation,
                onStart: { onSliceStart?(workingItems) },
                onResume: {
                    if let engine = router.sliceEngine {
                        engine.updateItems(workingItems)
                        engine.resume()
                        timer.resume()
                        router.activePanel = .sliceActive
                    }
                }
            )
        }
        .padding()
        .frame(width: 280)
        .overlay(alignment: .topTrailing) {
            gearMenu
        }
    }

    @ViewBuilder
    private var sliceActivePanel: some View {
        if let engine = router.sliceEngine {
            ActiveRotationView(
                engine: engine,
                timer: timer,
                onNext: { engine.skip() },
                onPause: {
                    if engine.isPaused {
                        engine.resume()
                        timer.resume()
                    } else {
                        engine.pause()
                        timer.pause()
                    }
                },
                onFinishBlock: { timer.next() },
                autoAdvance: settings.autoAdvance
            )
            .overlay(alignment: .topTrailing) {
                gearMenu
            }
        } else {
            Color.clear.onAppear { router.activePanel = .timer }
        }
    }

}
