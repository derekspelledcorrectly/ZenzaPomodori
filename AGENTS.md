# Agent Guidelines for Zenza Pomodori

Zenza Pomodori is a macOS menu bar focus timer built with SwiftUI and Swift 6.
It runs as a menu bar agent (LSUIElement) with no Dock presence. GPL-3.0 open
source.

## Helping a User Build From Source

If someone asks you to build this app for them, walk them through these steps.
Check each prerequisite before installing it.

### 1. Xcode Command Line Tools

Required for `xcodebuild`, `clang`, and the macOS SDK.

```bash
# Check if already installed
xcode-select -p          # success = installed, error = not installed

# Install if needed
xcode-select --install   # opens a system dialog, user must click "Install"
```

`xcode-select` ships with every Mac. No prerequisites. The Command Line Tools
are free and do not require an Apple Developer Program membership -- a free
Apple ID is enough.

After the dialog completes, verify with `xcode-select -p` again.

### 2. Homebrew

Required to install XcodeGen.

```bash
# Check if already installed
which brew

# Install if needed (see https://brew.sh)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 3. XcodeGen

Generates the `.xcodeproj` from `project.yml`. The Xcode project file is
gitignored and must be regenerated.

```bash
# Check if already installed
which xcodegen

# Install if needed
brew install xcodegen
```

### 4. Build and run

```bash
make run       # Builds Debug and launches the app
```

The app appears in the menu bar (not the Dock). Click the icon to open the
timer popover.

## Make Targets

| Target       | Config  | What it does                                        |
| ------------ | ------- | --------------------------------------------------- |
| `make build` | Debug   | Generate project, build .app                        |
| `make run`   | Debug   | Build and launch                                    |
| `make rerun` | Debug   | Kill running instance, rebuild, relaunch             |
| `make test`  | Debug   | Run unit tests                                      |
| `make release` | Release | Build optimized .app, print path                  |
| `make clean` |         | Remove `.build/` derived data                       |

All build output goes to `.build/` (gitignored local derived data).

### Debug vs Release

- `make run` and `make rerun` build Debug for fast iteration during development.
- `make release` builds an optimized Release `.app` suitable for daily use.

### Release build location

`make release` prints the path when it finishes:

```
Built: .build/Build/Products/Release/Zenza Pomodori.app
```

To install the release build (with user permission), copy it to Applications:

```bash
# System-wide (requires permission)
cp -R ".build/Build/Products/Release/Zenza Pomodori.app" /Applications/

# Per-user (no special permission)
mkdir -p ~/Applications
cp -R ".build/Build/Products/Release/Zenza Pomodori.app" ~/Applications/
```

Then launch:

```bash
open "/Applications/Zenza Pomodori.app"
# or
open "~/Applications/Zenza Pomodori.app"
```

## Architecture

**Raw NSApplication + AppDelegate (no SwiftUI App lifecycle)**

- `ZenzaPomodoriApp.swift` contains `AppDelegate` and `PopoverManager`
- `PomodoroTimer` is an `@Observable @MainActor` state machine, single source
  of truth for timer state
- `SettingsStore` wraps `UserDefaults` with `@Observable`
- `Constants.swift` has `Defaults` enum (values) and `SettingsKeys` enum (keys)

**Key patterns:**

- `@Observable` + `@Bindable` throughout (Observation framework, not
  `ObservableObject`)
- Swift structured concurrency (`Task.sleep`) for timer ticks, not Combine
- Zero external dependencies
- All timer tests are `@MainActor`
- Tests use isolated UserDefaults suites: `UserDefaults(suiteName: "test-\(UUID())")`

## Code Conventions

- Swift 6 strict concurrency
- macOS 15.0 minimum deployment target
- Ad-hoc code signing (`CODE_SIGN_IDENTITY: "-"`)
- Tests use Swift Testing framework (`import Testing`, `@Test`, `#expect`), not
  XCTest
- `project.yml` uses directory-based sources -- creating files in the right
  directory is sufficient, no need to edit project config

## Testing

214 tests across 17 suites. Run with `make test`.

Always run `make test` after changes to verify nothing is broken.

## File Layout

```
ZenzaPomodori/
  App/                  # AppDelegate, PopoverManager
  Models/               # TimerPhase, SliceEngine
  ViewModels/           # PomodoroTimer state machine
  Views/
    MenuBar/            # Timer popover UI
    Slices/             # Rotation list and Slices controls
    Settings/           # Settings window
    About/              # About window
  Services/             # HotkeyService, NotificationService, SoundService
  Utilities/            # Constants, SettingsStore, time formatting
  Resources/            # Info.plist, asset catalog, sounds
ZenzaPomodoriTests/     # Unit tests (Swift Testing framework)
project.yml             # XcodeGen spec (generates .xcodeproj, gitignored)
Makefile                # Build automation
docs/                   # Marketing site (zenzapomodori.com)
```
