# Agent Guidelines for Zenza Pomodori

## Project Overview

Zenza Pomodori is a macOS menu bar pomodoro timer built with SwiftUI and Swift 6. The app runs as a menu bar agent (LSUIElement) with no Dock presence.

## Build System

This project uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) to generate the Xcode project from `project.yml`. The `.xcodeproj` is gitignored. All build commands go through the `Makefile`:

- `make build` -- generate project and build Debug
- `make test` -- generate project and run unit tests
- `make run` -- build and launch the app
- `make clean` -- remove build artifacts
- `make release` -- build Release and package as .zip

Build output goes to `.build/` (local derived data, gitignored).

Always run `make test` after changes to verify nothing is broken.

## Architecture

**MVVM with SwiftUI Scenes**

- `ZenzaPomodoriApp.swift` -- `@main` App with `MenuBarExtra` scene
- `PomodoroTimer` -- `@Observable @MainActor` view model, single source of truth for timer state
- `TimerPhase` -- enum with associated values: `.idle`, `.focus(block:)`, `.shortBreak(afterBlock:)`, `.longBreak`
- Views are composed in `MenuBarView` from `TimerDisplayView` and `TimerControlsView`

**Key patterns:**
- Swift structured concurrency (`Task.sleep`) for the timer tick loop, not Combine
- `@Observable` (Observation framework), not `ObservableObject`
- Zero external dependencies

## Code Conventions

- Swift 6 strict concurrency
- macOS 15.0 minimum deployment target
- Ad-hoc code signing (`CODE_SIGN_IDENTITY: "-"`)
- Tests use Swift Testing framework (`import Testing`, `@Test`, `#expect`), not XCTest

## Testing

25 tests across 4 suites:
- `PomodoroTimerTests` -- timer engine logic (start, pause, resume, skip, reset, phase transitions)
- `TimerPhaseTests` -- phase labels, boolean helpers, equality
- `TimeFormattingTests` -- MM:SS and short format helpers
- `DefaultsTests` -- constant values

All timer tests are `@MainActor` since `PomodoroTimer` requires main actor isolation.

## File Layout

```
ZenzaPomodori/
  App/ZenzaPomodoriApp.swift
  Models/TimerPhase.swift
  ViewModels/PomodoroTimer.swift
  Views/MenuBar/
    MenuBarView.swift
    TimerDisplayView.swift
    TimerControlsView.swift
  Utilities/
    Constants.swift
    TimeFormatting.swift
  Resources/
    Info.plist
    Assets.xcassets/
ZenzaPomodoriTests/
  PomodoroTimerTests.swift
  ZenzaPomodoriTests.swift
```
