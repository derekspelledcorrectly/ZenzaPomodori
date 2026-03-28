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
    var onClosePopover: (() -> Void)?

    var body: some View {
        Group {
            switch router.activePanel {
            case .timer:
                MenuBarView(
                    timer: timer,
                    onOpenSettings: { router.activePanel = .settings }
                )

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

            case .sliceTransition:
                sliceTransitionPanel
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
    }

    private var isEditingActiveRotation: Bool {
        router.sliceEngine?.isActive == true
    }

    // MARK: - Panels

    private var sliceIdlePanel: some View {
        VStack(spacing: 16) {
            // Match TimerDisplayView's 140px frame so the picker stays
            // at the same Y position in both Regular and Slices panels.
            // This means NSPopover only grows/shrinks at the bottom (no reposition needed).
            ConcentricTimerView(
                microProgress: Double(settings.sliceRotationInterval) / Double(max(1, settings.focusDuration)),
                outerProgress: 1.0,
                microTimeFormatted: timer.formattedTime,
                outerTimeFormatted: "\(settings.sliceRotationInterval / 60) min each",
                outerColor: .accentColor.opacity(0.25)
            )

            BlockTypePickerView(
                blockType: Binding(
                    get: { settings.lastBlockType },
                    set: { settings.lastBlockType = $0 }
                )
            )

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
        .frame(width: 320)
        .overlay(alignment: .topTrailing) {
            Button(action: { router.activePanel = .settings }) {
                Image(systemName: "gearshape")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
            .padding(8)
        }
    }

    @ViewBuilder
    private var sliceActivePanel: some View {
        if let engine = router.sliceEngine {
            ActiveRotationView(
                engine: engine,
                timer: timer,
                onNext: { engine.skip() },
                onEditList: {
                    engine.pause()
                    timer.pause()
                    workingItems = engine.rotationItems
                    router.activePanel = .sliceSetup
                },
                onPause: {
                    if engine.isPaused { engine.resume() } else { engine.pause() }
                },
                onCompleteBlock: {
                    engine.deactivate()
                    timer.next()
                },
                onAbandonBlock: {
                    engine.deactivate()
                    timer.abandonBlock()
                    router.activePanel = .sliceSetup
                }
            )
            .overlay(alignment: .topTrailing) {
                Button(action: { router.activePanel = .settings }) {
                    Image(systemName: "gearshape")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.borderless)
                .padding(8)
            }
        } else {
            Color.clear.onAppear { router.activePanel = .timer }
        }
    }

    @ViewBuilder
    private var sliceTransitionPanel: some View {
        if let engine = router.sliceEngine {
            RotationTransitionCard(
                currentName: engine.currentItemName ?? "",
                nextName: engine.nextItemName,
                positionText: "\(engine.currentIndex + 1)/\(engine.rotationItems.count)",
                outerTimeRemaining: timer.formattedTime,
                rotationProgress: Double(engine.currentIndex + 1) / Double(max(1, engine.rotationItems.count)),
                onDismiss: {
                    router.activePanel = .sliceActive
                },
                onClose: {
                    router.transitionDismissed = true
                    router.activePanel = .sliceActive
                    onClosePopover?()
                }
            )
        } else {
            Color.clear.onAppear { router.activePanel = .timer }
        }
    }
}
