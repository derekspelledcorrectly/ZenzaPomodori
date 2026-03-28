# Timer Controls Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reduce the timer button row from 4-5 equal-weight buttons to 2 primary buttons (Pause + Skip), moving all secondary/destructive actions into the gear icon dropdown menu.

**Architecture:** The gear icon in the top-right of every panel becomes a SwiftUI `Menu` (always a dropdown, never a direct button). When idle, the menu contains only "Settings...". When a timer is active, it gains session actions (Restart, Finish Early, Abandon, and Edit List for Slices mode). A subtle dot badge on the gear signals when session actions are available.

**Tech Stack:** SwiftUI, Swift Testing, macOS 15+, @Observable pattern

**Test command:**
```bash
xcodebuild test -scheme ZenzaPomodori -configuration Debug -derivedDataPath .build -destination 'platform=macOS' 2>&1 | grep -E '(error:|Test Suite|Test Case|passed|failed|\*\* TEST|Executed)'
```

**Build command (to check compilation):**
```bash
xcodebuild -scheme ZenzaPomodori -configuration Debug -derivedDataPath .build build 2>&1 | tail -5
```

**Project generation (run before build/test if files are added/removed):**
```bash
xcodegen generate
```

The project uses XcodeGen (`project.yml`) with directory-based sources. Creating or removing `.swift` files in the right directory is enough; just run `xcodegen generate` before building.

---

### Task 1: Slim Down TimerControlsView

Remove the Restart and Abandon buttons from `TimerControlsView`. This view should only render Pause/Resume and Skip/Complete. The `onReset` and `onAbandon` callbacks stay in the interface for now (MenuBarView still passes them), but the buttons are gone. We'll clean up the unused callbacks in Task 3 when MenuBarView takes ownership.

**Files:**
- Modify: `ZenzaPomodori/Views/MenuBar/TimerControlsView.swift`

- [ ] **Step 1: Remove the Restart and Abandon buttons from the body**

Replace the button row in `TimerControlsView.swift` body. The `if phase != .idle` block currently has three buttons (skip, restart, abandon). Remove the restart and abandon buttons, keeping only skip:

```swift
var body: some View {
    HStack(spacing: 16) {
        Button(action: playPauseAction) {
            Image(systemName: isRunning ? "pause.fill" : "play.fill")
                .frame(width: 20)
        }
        .controlSize(phase == .idle ? .large : .regular)
        .help(isRunning ? "Pause" : (phase == .idle ? "Start" : "Resume"))

        if phase != .idle {
            Button(action: onNext) {
                Image(systemName: phase.isFocus ? "checkmark.circle" : "forward.end.fill")
                    .frame(width: 20)
            }
            .help(phase.isFocus ? "Complete Block" : "Skip Break")
        }
    }
    .buttonStyle(.bordered)
}
```

- [ ] **Step 2: Build to verify compilation**

Run: `xcodegen generate && xcodebuild -scheme ZenzaPomodori -configuration Debug -derivedDataPath .build build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Run all tests to verify nothing broke**

Run: `xcodebuild test -scheme ZenzaPomodori -configuration Debug -derivedDataPath .build -destination 'platform=macOS' 2>&1 | grep -E '(error:|Test Suite|Test Case|passed|failed|\*\* TEST|Executed)'`
Expected: All tests pass. No existing tests depend on the Restart/Abandon button presence.

- [ ] **Step 4: Commit**

```bash
git add ZenzaPomodori/Views/MenuBar/TimerControlsView.swift && git commit -m "$(cat <<'EOF'
refactor: remove restart and abandon buttons from TimerControlsView

Keep only Pause/Resume and Skip/Complete in the button row.
Secondary actions will move to the gear menu.

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 2: Slim Down ActiveRotationView

Remove Edit List, Complete Block, and Abandon Block buttons from `ActiveRotationView`. Also remove its gear overlay (the parent will provide the gear menu). Remove the now-unused callback properties.

**Files:**
- Modify: `ZenzaPomodori/Views/Slices/ActiveRotationView.swift`
- Modify: `ZenzaPomodori/Views/PopoverContainerView.swift` (update call site)

- [ ] **Step 1: Remove extra buttons and callbacks from ActiveRotationView**

Update `ActiveRotationView` to remove the `onEditList`, `onCompleteBlock`, and `onAbandonBlock` properties and their buttons. The controls HStack keeps only Pause and Next:

```swift
struct ActiveRotationView: View {
    let engine: SliceEngine
    let timer: PomodoroTimer
    var onNext: () -> Void
    var onPause: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Concentric rings: outer = slice (hero), inner = block (context)
            ConcentricTimerView(
                sliceProgress: timer.progress,
                outerProgress: engine.progress,
                sliceTimeFormatted: TimeFormatting.formatted(seconds: engine.sliceSecondsRemaining),
                outerTimeFormatted: engine.currentItemName ?? "",
                outerColor: .orange,
                innerColor: phaseColor
            )

            // Rotation + block info
            HStack(spacing: 6) {
                if engine.rotationItems.count > 1 {
                    Text("Focus \(engine.currentIndex + 1)/\(engine.rotationItems.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let next = engine.nextItemName {
                    Text("\u{00B7}")
                        .foregroundStyle(.tertiary)
                    Text("Next: \(next)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text("\u{00B7}")
                    .foregroundStyle(.tertiary)

                Text("\(blockLabel) \u{00B7} \(timer.formattedTime) left")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            // Controls
            HStack(spacing: 16) {
                Button(action: { onPause() }) {
                    Image(systemName: engine.isPaused ? "play.fill" : "pause.fill")
                        .frame(width: 20)
                }
                .help(engine.isPaused ? "Resume" : "Pause")

                Button(action: { onNext() }) {
                    Image(systemName: "forward.end.fill")
                        .frame(width: 20)
                }
                .help("Next Focus")
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(width: 280)
        .background { keyboardShortcuts }
    }

    // keyboardShortcuts, blockLabel, phaseColor stay unchanged
```

- [ ] **Step 2: Update the call site in PopoverContainerView**

In `PopoverContainerView.swift`, update the `sliceActivePanel` to remove the deleted callback arguments. Also remove the `.overlay` gear button from this panel (the gear menu will be added in Task 3):

```swift
@ViewBuilder
private var sliceActivePanel: some View {
    if let engine = router.sliceEngine {
        ActiveRotationView(
            engine: engine,
            timer: timer,
            onNext: { engine.skip() },
            onPause: {
                if engine.isPaused { engine.resume() } else { engine.pause() }
            }
        )
    } else {
        Color.clear.onAppear { router.activePanel = .timer }
    }
}
```

Note: The edit list, complete block, and abandon block actions still exist in PopoverContainerView -- they'll be wired to the gear menu in Task 3. For now, the gear overlay is removed and those actions are temporarily unreachable via UI (keyboard shortcuts still work for some).

- [ ] **Step 3: Build to verify compilation**

Run: `xcodegen generate && xcodebuild -scheme ZenzaPomodori -configuration Debug -derivedDataPath .build build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Run all tests**

Run: `xcodebuild test -scheme ZenzaPomodori -configuration Debug -derivedDataPath .build -destination 'platform=macOS' 2>&1 | grep -E '(error:|Test Suite|Test Case|passed|failed|\*\* TEST|Executed)'`
Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add ZenzaPomodori/Views/Slices/ActiveRotationView.swift ZenzaPomodori/Views/PopoverContainerView.swift && git commit -m "$(cat <<'EOF'
refactor: remove secondary buttons from ActiveRotationView

Keep only Pause and Next in the Slices button row. Remove Edit List,
Complete Block, and Abandon Block buttons and their callback props.
Remove gear overlay (moves to shared menu in next commit).

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 3: Build the Gear Menu in PopoverContainerView

Replace all gear `Button` overlays with a shared SwiftUI `Menu` that shows contextual items based on timer state and active panel. Add the dot badge.

**Files:**
- Modify: `ZenzaPomodori/Views/PopoverContainerView.swift`
- Modify: `ZenzaPomodori/Views/MenuBar/MenuBarView.swift`

- [ ] **Step 1: Add a gearMenu ViewBuilder to PopoverContainerView**

Add this computed property to `PopoverContainerView`, after the existing panel properties:

```swift
// MARK: - Gear Menu

@ViewBuilder
private var gearMenu: some View {
    Menu {
        if timer.phase != .idle {
            if router.activePanel == .sliceActive, let engine = router.sliceEngine {
                Button("Edit Rotation List", systemImage: "list.bullet") {
                    engine.pause()
                    timer.pause()
                    workingItems = engine.rotationItems
                    router.activePanel = .sliceSetup
                }
            }

            Button("Restart Timer", systemImage: "arrow.counterclockwise") {
                timer.restartPhase()
            }

            Divider()

            Button(action: {
                if let engine = router.sliceEngine, engine.isActive {
                    engine.deactivate()
                }
                timer.next()
            }) {
                Label("Finish Block Early", systemImage: "checkmark.circle")
                    .foregroundStyle(.orange)
            }

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

            Divider()
        }

        Button("Settings...", systemImage: "gearshape") {
            router.activePanel = .settings
        }
    } label: {
        Image(systemName: "gearshape")
            .foregroundStyle(.secondary)
            .overlay(alignment: .topTrailing) {
                if timer.phase != .idle {
                    Circle()
                        .fill(.accent)
                        .frame(width: 6, height: 6)
                        .offset(x: 2, y: -2)
                }
            }
    }
    .menuStyle(.borderlessButton)
    .menuIndicator(.hidden)
    .padding(8)
}
```

- [ ] **Step 2: Apply gearMenu overlay to the timer panel and sliceActivePanel**

Update the `body` switch cases. For the `.timer` case, pass the gear menu via a new callback. For `.sliceActive`, add the overlay directly:

In `sliceActivePanel`, add the overlay back:

```swift
@ViewBuilder
private var sliceActivePanel: some View {
    if let engine = router.sliceEngine {
        ActiveRotationView(
            engine: engine,
            timer: timer,
            onNext: { engine.skip() },
            onPause: {
                if engine.isPaused { engine.resume() } else { engine.pause() }
            }
        )
        .overlay(alignment: .topTrailing) {
            gearMenu
        }
    } else {
        Color.clear.onAppear { router.activePanel = .timer }
    }
}
```

For `sliceIdlePanel`, replace the existing gear `Button` overlay with `gearMenu`:

Replace:
```swift
.overlay(alignment: .topTrailing) {
    Button(action: { router.activePanel = .settings }) {
        Image(systemName: "gearshape")
            .foregroundStyle(.secondary)
    }
    .buttonStyle(.borderless)
    .padding(8)
}
```

With:
```swift
.overlay(alignment: .topTrailing) {
    gearMenu
}
```

- [ ] **Step 3: Update MenuBarView to accept a gear menu view**

Change `MenuBarView` to accept an optional gear menu view instead of `onOpenSettings`. Replace the `onOpenSettings` closure with a generic gear menu slot:

```swift
struct MenuBarView<GearContent: View>: View {
    @Bindable var timer: PomodoroTimer
    var gearContent: GearContent

    init(timer: PomodoroTimer, @ViewBuilder gearContent: () -> GearContent) {
        self.timer = timer
        self.gearContent = gearContent()
    }

    var body: some View {
        VStack(spacing: 12) {
            // ... existing content unchanged ...

            TimerControlsView(
                phase: timer.phase,
                isRunning: timer.isRunning,
                onStart: timer.start,
                onPause: timer.pause,
                onResume: timer.resume,
                onNext: timer.next,
                onReset: timer.restartPhase,
                onAbandon: timer.abandonBlock
            )
        }
        .padding()
        .frame(width: 280)
        .overlay(alignment: .topTrailing) {
            gearContent
        }
        .background { keyboardShortcuts }
    }

    // keyboardShortcuts, togglePlayPause, shortcutButton stay unchanged
}
```

- [ ] **Step 4: Update the MenuBarView call site in PopoverContainerView**

In the `.timer` case of the body switch:

```swift
case .timer:
    MenuBarView(timer: timer) {
        gearMenu
    }
```

- [ ] **Step 5: Build to verify compilation**

Run: `xcodegen generate && xcodebuild -scheme ZenzaPomodori -configuration Debug -derivedDataPath .build build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

- [ ] **Step 6: Run all tests**

Run: `xcodebuild test -scheme ZenzaPomodori -configuration Debug -derivedDataPath .build -destination 'platform=macOS' 2>&1 | grep -E '(error:|Test Suite|Test Case|passed|failed|\*\* TEST|Executed)'`
Expected: All tests pass.

- [ ] **Step 7: Commit**

```bash
git add ZenzaPomodori/Views/PopoverContainerView.swift ZenzaPomodori/Views/MenuBar/MenuBarView.swift && git commit -m "$(cat <<'EOF'
feat: replace gear button with contextual dropdown menu

The gear icon is now always a Menu dropdown. When idle, it shows
only Settings. When active, it shows session actions (Restart,
Finish Early, Abandon, and Edit List for Slices) above Settings.
A subtle accent dot badge appears when session actions are available.

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 4: Clean Up Unused Callbacks

Remove the `onReset` and `onAbandon` callbacks from `TimerControlsView` since those actions now live in the gear menu. Clean up the call site in `MenuBarView`.

**Files:**
- Modify: `ZenzaPomodori/Views/MenuBar/TimerControlsView.swift`
- Modify: `ZenzaPomodori/Views/MenuBar/MenuBarView.swift`

- [ ] **Step 1: Remove onReset and onAbandon from TimerControlsView**

Remove the two properties from the struct:

```swift
struct TimerControlsView: View {
    let phase: TimerPhase
    let isRunning: Bool
    let onStart: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onNext: () -> Void

    // ... rest unchanged
}
```

Update the previews at the bottom of the file to remove the deleted parameters:

```swift
#Preview("Idle") {
    TimerControlsView(
        phase: .idle,
        isRunning: false,
        onStart: {}, onPause: {}, onResume: {},
        onNext: {}
    )
    .padding()
}

#Preview("Running") {
    TimerControlsView(
        phase: .focus(block: 1),
        isRunning: true,
        onStart: {}, onPause: {}, onResume: {},
        onNext: {}
    )
    .padding()
}
```

- [ ] **Step 2: Update the call site in MenuBarView**

In `MenuBarView`, update the `TimerControlsView` initializer to remove the deleted parameters:

```swift
TimerControlsView(
    phase: timer.phase,
    isRunning: timer.isRunning,
    onStart: timer.start,
    onPause: timer.pause,
    onResume: timer.resume,
    onNext: timer.next
)
```

- [ ] **Step 3: Build to verify compilation**

Run: `xcodegen generate && xcodebuild -scheme ZenzaPomodori -configuration Debug -derivedDataPath .build build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Run all tests**

Run: `xcodebuild test -scheme ZenzaPomodori -configuration Debug -derivedDataPath .build -destination 'platform=macOS' 2>&1 | grep -E '(error:|Test Suite|Test Case|passed|failed|\*\* TEST|Executed)'`
Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add ZenzaPomodori/Views/MenuBar/TimerControlsView.swift ZenzaPomodori/Views/MenuBar/MenuBarView.swift && git commit -m "$(cat <<'EOF'
refactor: remove unused onReset and onAbandon from TimerControlsView

These actions now live in the gear menu, so the callbacks are no
longer needed on the button row component.

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 5: Manual Smoke Test and Final Run

Run the app and verify all interactions work end-to-end.

- [ ] **Step 1: Run the full test suite one final time**

Run: `xcodebuild test -scheme ZenzaPomodori -configuration Debug -derivedDataPath .build -destination 'platform=macOS' 2>&1 | grep -E '(error:|Test Suite|Test Case|passed|failed|\*\* TEST|Executed)'`
Expected: All tests pass.

- [ ] **Step 2: Build and launch the app**

Run: `make rerun`

- [ ] **Step 3: Manual verification checklist (user performs)**

Have the user verify:
1. **Idle state**: Gear icon shows dropdown with only "Settings..." (no dot badge)
2. **Start a regular focus timer**: Gear gets dot badge. Menu shows Restart Timer, Finish Block Early (orange-ish), Abandon Block (red-ish), Settings...
3. **Button row**: Only Pause and Skip/Complete visible
4. **Pause/Resume**: Works from button row
5. **Skip**: Works from button row
6. **Restart Timer**: Works from gear menu
7. **Finish Block Early**: Works from gear menu, returns to idle
8. **Abandon Block**: Works from gear menu, returns to idle
9. **Start a Slices session**: Gear menu additionally shows "Edit Rotation List"
10. **Edit Rotation List**: Works from gear menu, pauses and navigates to setup
11. **Keyboard shortcuts**: All still functional (Return, N, R, Space)
