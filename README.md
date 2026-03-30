# Zenza Pomodori

A tomato-free focus timer for macOS, built for humans in the agentic era.

## What It Does

- **Focus timer** with configurable durations for focus blocks, short breaks, and long breaks
- **Slices mode** cycles your focus across multiple agents in timed rotations -- check in, unblock, advance
- **Global hotkeys** to toggle the popover and advance rotations from anywhere
- **Notification sounds** with per-phase customization (or silence)
- **Menu bar native**, no dock icon, no window clutter

## Getting Started

### Pre-release download

The Mac App Store listing is not live yet. In the meantime, you can grab an unsigned build from [Releases](https://github.com/derekspelledcorrectly/ZenzaPomodori/releases):

1. Download the latest `.zip` and unzip it
2. Move `Zenza Pomodori.app` to `/Applications`
3. Right-click the app > **Open** on first launch (required for unsigned builds)

### Build from source

Requires macOS 15+ and Xcode Command Line Tools (free, no Apple Developer Program fee). Point your favorite AI agent at [`AGENTS.md`](AGENTS.md) for detailed build instructions.

```bash
xcode-select --install      # Install Xcode Command Line Tools (if not already installed)
brew install xcodegen        # Install XcodeGen (requires Homebrew)
make run                     # Build (debug) and launch
make release                 # Build optimized .app bundle
```

Other make targets:

```bash
make test     # Run unit tests
make clean    # Remove build artifacts
```

The app appears as an icon in your menu bar (not the Dock). Click it to open the timer.

## Project Structure

```
ZenzaPomodori/
  App/              # AppDelegate, PopoverManager (raw NSApplication lifecycle)
  Models/           # TimerPhase, SliceEngine
  ViewModels/       # PomodoroTimer state machine
  Views/
    MenuBar/        # Timer popover UI
    Slices/         # Rotation list and Slices controls
    Settings/       # Settings window
    About/          # About window
  Services/         # HotkeyService, NotificationService, SoundService
  Utilities/        # Constants, SettingsStore, time formatting
  Resources/        # Info.plist, asset catalog, sounds
ZenzaPomodoriTests/ # Unit tests (Swift Testing framework)
project.yml         # XcodeGen spec (generates .xcodeproj, which is gitignored)
Makefile            # Build automation
docs/               # Marketing site (zenzapomodori.com)
```

## Acknowledgments

Notification sounds by [akx/Notifications](https://github.com/akx/Notifications), dual-licensed CC-BY 3.0 / CC0 Public Domain.

## License

GPL-3.0. See [LICENSE](LICENSE).
