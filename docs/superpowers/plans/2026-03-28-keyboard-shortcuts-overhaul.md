# Keyboard Shortcuts Overhaul Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace bare-key in-popover shortcuts with Cmd+ shortcuts, add Space for play/pause, and surface shortcuts in gear menu items and button tooltips.

**Architecture:** Shortcuts split into two categories: gear menu items get `.keyboardShortcut()` directly on their SwiftUI `Button` (auto-renders glyphs), while primary play/pause/skip use hidden zero-frame buttons in `MenuBarView`. Tooltips on visible buttons show shortcut hints.

**Tech Stack:** SwiftUI `.keyboardShortcut()`, Swift Testing

**Spec:** `docs/superpowers/specs/2026-03-28-keyboard-shortcuts-overhaul-design.md`

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `ZenzaPomodori/Views/PopoverContainerView.swift` | Modify | Add `.keyboardShortcut()` to gear menu buttons |
| `ZenzaPomodori/Views/MenuBar/MenuBarView.swift` | Modify | Replace bare R/N shortcuts, add Space |
| `ZenzaPomodori/Views/MenuBar/TimerControlsView.swift` | Modify | Update `.help()` tooltips |

No new files. No test files -- these are SwiftUI keyboard shortcut bindings that can't be unit tested meaningfully (they're declarative view modifiers). The existing `PomodoroTimer` actions (`restartPhase`, `abandonBlock`, `next`, etc.) are already well-tested.

---

### Task 1: Add Cmd+ shortcuts to gear menu items

**Files:**
- Modify: `ZenzaPomodori/Views/PopoverContainerView.swift:83-143`

- [ ] **Step 1: Add `.keyboardShortcut()` to Edit Rotation List button**

In `PopoverContainerView.swift`, the gear menu's "Edit Rotation List" button (line 88-95):

```swift
Button(action: {
    engine.pause()
    timer.pause()
    workingItems = engine.rotationItems
    router.activePanel = .sliceSetup
}) {
    Label("Edit Rotation List", systemImage: "list.bullet")
}
.keyboardShortcut("e", modifiers: .command)
```

- [ ] **Step 2: Add `.keyboardShortcut()` to Restart Timer button**

The "Restart Timer" button (line 98-102):

```swift
Button(action: {
    timer.restartPhase()
}) {
    Label("Restart Timer", systemImage: "arrow.counterclockwise")
}
.keyboardShortcut(.leftArrow, modifiers: .command)
```

- [ ] **Step 3: Add `.keyboardShortcut()` to Abandon Block button**

The "Abandon Block" button (line 107-116):

```swift
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
```

- [ ] **Step 4: Add `.keyboardShortcut()` to Settings button**

The "Settings..." button (line 122-125):

```swift
Button(action: {
    router.activePanel = .settings
}) {
    Label("Settings...", systemImage: "gearshape")
}
.keyboardShortcut(",", modifiers: .command)
```

- [ ] **Step 5: Build to verify gear menu renders shortcut glyphs**

Run: `xcodebuild build -scheme ZenzaPomodori -destination 'platform=macOS' 2>&1 | grep -E '(error:|warning:|BUILD)'`
Expected: BUILD SUCCEEDED

- [ ] **Step 6: Commit**

```bash
git add ZenzaPomodori/Views/PopoverContainerView.swift && git commit -m "$(cat <<'EOF'
feat: add Cmd+ keyboard shortcuts to gear menu items

Cmd+Left for Restart, Cmd+Delete for Abandon, Cmd+E for Edit Rotation,
Cmd+, for Settings. SwiftUI renders shortcut glyphs automatically.

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 2: Replace bare-key shortcuts in MenuBarView

**Files:**
- Modify: `ZenzaPomodori/Views/MenuBar/MenuBarView.swift:76-98`

- [ ] **Step 1: Rewrite the `keyboardShortcuts` computed property**

Replace the entire `keyboardShortcuts` view builder (lines 76-84) with:

```swift
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
```

- [ ] **Step 2: Update `shortcutButton` to accept modifiers**

Replace the existing helper (lines 94-98) with:

```swift
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
```

- [ ] **Step 3: Build to verify**

Run: `xcodebuild build -scheme ZenzaPomodori -destination 'platform=macOS' 2>&1 | grep -E '(error:|warning:|BUILD)'`
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Commit**

```bash
git add ZenzaPomodori/Views/MenuBar/MenuBarView.swift && git commit -m "$(cat <<'EOF'
feat: replace bare-key shortcuts with Space/Return + Cmd+Right

Remove bare R (restart, now on gear menu) and bare N (next).
Add Space alongside Return for play/pause. Next is now Cmd+Right.

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 3: Update button tooltips with shortcut hints

**Files:**
- Modify: `ZenzaPomodori/Views/MenuBar/TimerControlsView.swift:18-31`

- [ ] **Step 1: Update play/pause button tooltip**

Replace the `.help()` on the play/pause button (line 23):

```swift
.help(isRunning ? "Pause (Space / Return)" : (phase == .idle ? "Start (Return)" : "Resume (Space / Return)"))
```

- [ ] **Step 2: Update skip/complete button tooltip**

Replace the `.help()` on the next button (line 30):

```swift
.help(phase.isFocus ? "Complete Block (\u{2318}\u{2192})" : "Skip Break (\u{2318}\u{2192})")
```

Note: `\u{2318}` is the Cmd symbol, `\u{2192}` is the right arrow. This renders as "Complete Block (Cmd+Right Arrow)" using native macOS glyphs.

- [ ] **Step 3: Build and run to verify tooltips**

Run: `xcodebuild build -scheme ZenzaPomodori -destination 'platform=macOS' 2>&1 | grep -E '(error:|warning:|BUILD)'`
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Run `make rerun` for manual verification**

Run: `make rerun`

Verify:
- Hover over play button in idle: tooltip shows "Start (Return)"
- Start a timer, hover over pause button: tooltip shows "Pause (Space / Return)"
- Hover over skip button during focus: tooltip shows "Complete Block" with Cmd+Right glyph
- Open gear menu: shortcut glyphs visible next to Restart, Abandon, Settings
- Press Space: pauses/resumes
- Press Cmd+Right: skips to next phase
- Press Cmd+Left: restarts current phase
- Press Cmd+,: opens settings

- [ ] **Step 5: Commit**

```bash
git add ZenzaPomodori/Views/MenuBar/TimerControlsView.swift && git commit -m "$(cat <<'EOF'
feat: add keyboard shortcut hints to button tooltips

Play/pause shows Space/Return, skip shows Cmd+Right glyph.

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```
