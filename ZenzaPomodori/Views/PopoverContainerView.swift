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
    var onMicroBlockStart: (([RotationItem]) -> Void)?

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
                    onBack: { router.activePanel = .timer }
                )

            case .microBlockSetup:
                microBlockIdlePanel

            case .microBlockActive:
                microBlockActivePanel

            case .microBlockTransition:
                microBlockTransitionPanel
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
        .onChange(of: timer.phase) { _, _ in
            if router.activePanel == .timer {
                onPanelChange(.timer)
            }
        }
        .onChange(of: settings.microBlocksEnabled) { _, enabled in
            if !enabled && router.activePanel == .microBlockSetup {
                router.activePanel = .timer
            }
        }
        .onChange(of: settings.lastBlockType) { _, newType in
            if timer.phase == .idle {
                router.activePanel = newType == .microBlocks ? .microBlockSetup : .timer
            }
        }
    }

    // MARK: - Panels

    private var microBlockIdlePanel: some View {
        VStack(spacing: 16) {
            // Match TimerDisplayView's 140px frame so the picker stays
            // at the same Y position in both Regular and MicroBlocks panels.
            // This means NSPopover only grows/shrinks at the bottom (no reposition needed).
            ConcentricTimerView(
                microProgress: Double(settings.microRotationInterval) / Double(max(1, settings.focusDuration)),
                outerProgress: 1.0,
                microTimeFormatted: timer.formattedTime,
                outerTimeFormatted: "\(settings.microRotationInterval / 60) min each",
                size: 120
            )
            .frame(height: 140)

            BlockTypePickerView(
                blockType: Binding(
                    get: { settings.lastBlockType },
                    set: { settings.lastBlockType = $0 }
                )
            )

            MicroBlockSetupView(
                rotationStore: rotationStore,
                focusNameStore: focusNameStore,
                workingItems: $workingItems,
                onStart: { onMicroBlockStart?(workingItems) }
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
    private var microBlockActivePanel: some View {
        if let engine = router.microBlockEngine {
            ActiveRotationView(
                engine: engine,
                timer: timer,
                onSkip: { engine.skip() },
                onEditList: { router.activePanel = .microBlockSetup },
                onPause: {
                    if engine.isPaused { engine.resume() } else { engine.pause() }
                },
                onEndBlock: {
                    engine.deactivate()
                    timer.next()
                }
            )
        }
    }

    @ViewBuilder
    private var microBlockTransitionPanel: some View {
        if let engine = router.microBlockEngine {
            RotationTransitionCard(
                currentName: engine.currentItemName ?? "",
                nextName: engine.nextItemName,
                positionText: "\(engine.currentIndex + 1)/\(engine.rotationItems.count)",
                outerTimeRemaining: timer.formattedTime,
                rotationProgress: Double(engine.currentIndex + 1) / Double(max(1, engine.rotationItems.count)),
                onDismiss: {
                    engine.skip()
                    router.activePanel = .microBlockActive
                },
                onAutoDismiss: {
                    router.activePanel = .microBlockActive
                }
            )
        }
    }
}
