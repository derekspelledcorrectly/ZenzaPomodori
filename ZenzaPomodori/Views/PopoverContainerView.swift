import SwiftUI

struct PopoverContainerView: View {
    @Bindable var router: PopoverRouter
    let timer: PomodoroTimer
    let settings: SettingsStore
    let soundService: SoundService
    let onPanelChange: (PopoverPanel) -> Void
    let microBlockEngine: MicroBlockEngine?
    let rotationStore: RotationStore
    let focusNameStore: FocusNameStore
    @State private var workingItems: [RotationItem] = []
    var onMicroBlockStart: (([RotationItem]) -> Void)?
    var onContentSizeChanged: (() -> Void)?

    var body: some View {
        Group {
            switch router.activePanel {
            case .timer:
                timerPanel

            case .settings:
                SettingsView(
                    settings: settings,
                    soundService: soundService,
                    onBack: { router.activePanel = .timer }
                )

            case .microBlockSetup:
                microBlockSetupPanel

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
        .onChange(of: settings.microBlocksEnabled) { _, _ in
            onPanelChange(router.activePanel)
        }
        .onChange(of: settings.lastBlockType) { _, _ in
            onPanelChange(router.activePanel)
        }
    }

    // MARK: - Panels

    @ViewBuilder
    private var timerPanel: some View {
        if timer.phase == .idle
            && settings.microBlocksEnabled
            && settings.lastBlockType == .microBlocks {
            microBlockIdlePanel
        } else {
            MenuBarView(
                timer: timer,
                onOpenSettings: { router.activePanel = .settings }
            )
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var microBlockIdlePanel: some View {
        VStack(spacing: 12) {
            ConcentricTimerView(
                microProgress: Double(settings.microRotationInterval) / Double(max(1, settings.focusDuration)),
                outerProgress: 1.0,
                microTimeFormatted: timer.formattedTime,
                outerTimeFormatted: "\(settings.microRotationInterval / 60) min each",
                size: 80
            )

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

    private var microBlockSetupPanel: some View {
        MicroBlockSetupView(
            rotationStore: rotationStore,
            focusNameStore: focusNameStore,
            workingItems: $workingItems,
            onStart: { onMicroBlockStart?(workingItems) }
        )
        .padding()
        .frame(width: 320)
    }

    @ViewBuilder
    private var microBlockActivePanel: some View {
        if let engine = microBlockEngine {
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
        if let engine = microBlockEngine {
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
