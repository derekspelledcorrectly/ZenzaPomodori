# Show Focus Name in Menu Bar

## Summary

Add a setting that displays the user's current focus name in the macOS menu bar
next to the timer countdown during focus phases.

## Motivation

Users set a focus name for each pomodoro block. Showing it in the menu bar
provides a persistent, glanceable reminder of what they're working on without
needing to open the popover.

## Design

### New Setting

- **Key:** `showFocusInMenuBar` (Bool, default `true`)
- Follows the existing `showTimerInMenuBar` pattern in `SettingsStore`
- Persisted via `UserDefaults`

### Menu Bar Display

Updated in `PopoverManager.updateStatusItem()`:

- **When to show:** `showFocusInMenuBar` is on AND `timer.activeFocusName` is
  non-nil/non-empty. This means the focus name is visible during focus phases
  AND during the "Ready" idle state (when `pendingBlock != nil` and the user
  hasn't reset), so they remember what they're coming back to.
- **Truncation:** Cap at 20 characters, append "..." if truncated
- **Separator:** A single space between the timer text and the focus name
- **Format examples:**
  - Timer on + focus on: `[icon] 23:41 API work`
  - Timer off + focus on: `[icon] API work`
  - Timer on + focus off: `[icon] 23:41`
  - Both off: `[icon]`
- **Font:** Two attributed string runs: monospaced digit font for the timer
  portion, regular system font for the focus name (monospaced digits look
  wrong on prose text)
- No new observation wiring needed. The existing `startObservingTimer()` loop
  already picks up changes to `timer.phase`, `timer.activeFocusName`, and
  `timer.settings.*`.

### Truncation Helper

Extract a static/free function for truncating the focus name so it can be
unit tested independently of AppKit:

```swift
func truncatedFocusName(_ name: String, maxLength: Int = 20) -> String
```

- Returns `name` unchanged if within limit
- Returns `name.prefix(maxLength) + "..."` if over limit
- Trims whitespace before measuring

### Settings UI

New toggle in `SettingsView` Behavior section, placed directly after "Show timer
in menu bar":

```
Toggle("Show focus in menu bar", isOn: ...)
```

### Files Changed

1. `Constants.swift` -- add `Defaults.showFocusInMenuBar` and
   `SettingsKeys.showFocusInMenuBar`
2. `SettingsStore.swift` -- add `showFocusInMenuBar` property
3. `ZenzaPomodoriApp.swift` -- update `updateStatusItem()` to append focus name
4. `SettingsView.swift` -- add toggle
5. New or existing test files for SettingsStore + truncation helper

### Testing Strategy

- **SettingsStore tests:** default value, persistence round-trip
- **Truncation helper tests:** short name (no-op), exact boundary, over limit,
  whitespace handling, all-whitespace input (returns empty string)
- Integration behavior (menu bar rendering) is covered by manual verification
  since `NSStatusItem` is AppKit glue.

## Alternatives Considered

- **Separate NSStatusItem:** Overengineered, ordering not guaranteed.
- **Replace timer with focus name:** Loses time information.

## Decision

Append focus name to existing `attributedTitle` in `updateStatusItem()`.
