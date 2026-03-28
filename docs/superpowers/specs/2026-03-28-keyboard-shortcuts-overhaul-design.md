# Keyboard Shortcuts Overhaul

## Overview

Overhaul in-popover keyboard shortcuts. Primary actions (start/pause/resume) use bare keys (`Return`, `Space`). All other actions use `Cmd+` shortcuts, shown in gear menu items or button tooltips. Global hotkeys remain unchanged.

## Shortcut Map

### Global Hotkeys (unchanged)

These use Carbon `RegisterEventHotKey` and work whether or not the popover has focus. User-configurable in Settings.

| Action | Default | Managed by |
|--------|---------|------------|
| Toggle popover | User-configured | HotkeyService (id 1) |
| Rotation advance | User-configured | HotkeyService (id 2) |

### In-Popover Shortcuts (require popover focus)

| Action | Shortcut | Shown in | Context |
|--------|----------|----------|---------|
| Start / Pause / Resume | `Return` (bare) | Button tooltip | All states |
| Start / Pause / Resume | `Space` (bare) | Button tooltip | Text field captures when focused |
| Skip / Complete Block | `Cmd+Right` | Button tooltip | Active timer only |
| Restart Timer | `Cmd+Left` | Gear menu item | Active timer only |
| Abandon Block | `Cmd+Delete` | Gear menu item | Focus phases only |
| Edit Rotation List | `Cmd+E` | Gear menu item | Active slice rotation only |
| Settings | `Cmd+,` | Gear menu item | Always |

### Text Field Interaction

`Space` and `Cmd+Arrow` could conflict with the focus name text field, but in practice they don't:

- `focusNameIsLocked` is `true` during focus phases (`phase.isFocus`), so the text field is not editable when the timer is active.
- During idle, `Cmd+Left`/`Cmd+Right` (restart/skip) are not registered because those shortcuts only exist when the timer is active.
- `Space` in idle: the text field captures it when focused. When the text field is not focused, Space triggers Start.

## Discoverability

**Gear menu items**: `Cmd+Left`, `Cmd+Delete`, `Cmd+E`, `Cmd+,` render their shortcut glyphs natively in the SwiftUI `Menu` dropdown.

**Button tooltips**: Format is `"Action (Shortcut)"`. Specific tooltips:

| Button state | Tooltip |
|-------------|---------|
| Idle, play button | "Start (Return)" |
| Running, pause button | "Pause (Space / Return)" |
| Paused, play button | "Resume (Space / Return)" |
| Focus phase, skip button | "Complete Block (Cmd+Right)" |
| Break phase, skip button | "Skip Break (Cmd+Right)" |

**Future work**: A "Keyboard Shortcuts" reference panel in Settings (separate branch).

## Implementation

### Files to modify

**`PopoverContainerView.swift`** (gear menu):
- Add `.keyboardShortcut(.leftArrow, modifiers: .command)` to Restart Timer button
- Add `.keyboardShortcut(.delete, modifiers: .command)` to Abandon Block button
- Add `.keyboardShortcut("e", modifiers: .command)` to Edit Rotation List button
- Add `.keyboardShortcut(",", modifiers: .command)` to Settings button

**`MenuBarView.swift`** (hidden shortcut buttons):
- Remove bare `R` shortcut (restart moves to gear menu)
- Replace bare `N` with `Cmd+Right` hidden button
- Add `Space` alongside `Return` for play/pause
- Keep `Return` bare for start (idle) and play/pause (active)

**`TimerControlsView.swift`** (tooltips):
- Update `.help()` strings to include shortcut hints

### Files unchanged

- `HotkeyService.swift`: global hotkeys are untouched
- `ActiveRotationView.swift`: has its own Space/Return for slice-specific contexts (different panel)
- `RotationTransitionCard.swift`: has its own Space/Return/Escape for transition card (different panel)
- `ZenzaPomodoriApp.swift`: right-click NSMenu already has `Cmd+,` and `Cmd+Q`

### What gets removed

- Bare `R` shortcut in `MenuBarView.keyboardShortcuts` (replaced by `Cmd+Left` on gear menu item)
- Bare `N` shortcut in `MenuBarView.keyboardShortcuts` (replaced by `Cmd+Right` hidden button)
