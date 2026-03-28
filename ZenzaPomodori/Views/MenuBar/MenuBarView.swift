import SwiftUI

struct MenuBarView<GearContent: View>: View {
    @Bindable var timer: PomodoroTimer
    var gearContent: GearContent

    init(timer: PomodoroTimer, @ViewBuilder gearContent: () -> GearContent) {
        self.timer = timer
        self.gearContent = gearContent()
    }

    var body: some View {
        VStack(spacing: 12) {
            TimerDisplayView(
                phase: timer.phase,
                totalBlocks: timer.blocksBeforeLongBreak,
                progress: timer.progress,
                formattedTime: timer.formattedTime,
                isOvertime: timer.isOvertime
            )

            if timer.phase == .idle && timer.settings.slicesEnabled {
                BlockTypePickerView(
                    blockType: Binding(
                        get: { timer.settings.lastBlockType },
                        set: { timer.settings.lastBlockType = $0 }
                    )
                )
            }

            if !timer.phase.isBreak {
                FocusNameInputView(
                    draftName: Binding(
                        get: { timer.focusNameStore.draftName },
                        set: { timer.focusNameStore.draftName = $0 }
                    ),
                    isLocked: timer.focusNameIsLocked,
                    activeFocusName: timer.activeFocusName,
                    entries: timer.focusNameStore.entries,
                    onSelect: { entry in
                        timer.focusNameStore.draftName = entry.name
                    },
                    onToggleFavorite: { id in
                        timer.focusNameStore.toggleFavorite(id)
                    },
                    onDelete: { id in
                        timer.focusNameStore.deleteEntry(id)
                    },
                    onSubmit: {
                        if timer.phase == .idle {
                            timer.start()
                        }
                    },
                    autoFocus: timer.pendingBlock != nil
                )
            }

            TimerControlsView(
                phase: timer.phase,
                isRunning: timer.isRunning,
                onStart: timer.start,
                onPause: timer.pause,
                onResume: timer.resume,
                onNext: timer.next
            )
        }
        .padding()
        .frame(width: 280)
        .overlay(alignment: .topTrailing) {
            gearContent
        }
        .background { keyboardShortcuts }
    }

    @ViewBuilder
    private var keyboardShortcuts: some View {
        if timer.phase == .idle {
            shortcutButton(.return, modifiers: [], action: timer.start)
            shortcutButton(.space, modifiers: [], action: timer.start)
        } else {
            shortcutButton(.return, modifiers: [], action: togglePlayPause)
            shortcutButton(.space, modifiers: [], action: togglePlayPause)
            shortcutButton(.rightArrow, modifiers: .command, action: timer.next)
        }
    }

    private func togglePlayPause() {
        if timer.isRunning {
            timer.pause()
        } else {
            timer.resume()
        }
    }

    private func shortcutButton(
        _ key: KeyEquivalent,
        modifiers: EventModifiers = [],
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) { EmptyView() }
            .keyboardShortcut(key, modifiers: modifiers)
            .frame(width: 0, height: 0)
            .opacity(0)
    }
}
