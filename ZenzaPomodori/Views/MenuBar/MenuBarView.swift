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
            #if DEBUG
                .onTapGesture {
                    let flags = NSEvent.modifierFlags
                    if flags.contains(.option), flags.contains(.shift) {
                        timer.debugAddTime(20)
                    } else if flags.contains(.option) {
                        timer.debugSkipToEnd()
                    }
                }
            #endif

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
                isOvertime: timer.isOvertime,
                autoAdvance: timer.autoAdvance,
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
            hiddenShortcut(.return, modifiers: [], action: timer.start)
            hiddenShortcut(.return, modifiers: .command, action: timer.start)
            hiddenShortcut(.space, modifiers: [], action: timer.start)
        } else {
            hiddenShortcut(.return, modifiers: [], action: togglePlayPause)
            hiddenShortcut(.space, modifiers: [], action: togglePlayPause)
        }
    }

    private func togglePlayPause() {
        if timer.isRunning {
            timer.pause()
        } else {
            timer.resume()
        }
    }
}
