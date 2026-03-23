import SwiftUI

struct MenuBarView: View {
    @Bindable var timer: PomodoroTimer
    var onOpenSettings: () -> Void = {}

    var body: some View {
        VStack(spacing: 16) {
            TimerDisplayView(
                phase: timer.phase,
                totalBlocks: timer.blocksBeforeLongBreak,
                progress: timer.progress,
                formattedTime: timer.formattedTime,
                isOvertime: timer.isOvertime
            )

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
                onNext: timer.next,
                onReset: timer.restartPhase
            )
        }
        .padding()
        .frame(width: 320)
        .overlay(alignment: .topTrailing) {
            Button(action: onOpenSettings) {
                Image(systemName: "gearshape")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
            .padding(8)
        }
        .background { keyboardShortcuts }
    }

    @ViewBuilder
    private var keyboardShortcuts: some View {
        if timer.phase != .idle {
            shortcutButton(.space, action: togglePlayPause)
            shortcutButton(KeyEquivalent("n"), action: timer.next)
            shortcutButton(KeyEquivalent("r"), action: timer.restartPhase)
        }
    }

    private func shortcutButton(_ key: KeyEquivalent, action: @escaping () -> Void) -> some View {
        Button(action: action) { EmptyView() }
            .keyboardShortcut(key, modifiers: [])
            .frame(width: 0, height: 0)
            .opacity(0)
    }

    private func togglePlayPause() {
        if timer.isRunning {
            timer.pause()
        } else {
            timer.resume()
        }
    }
}
