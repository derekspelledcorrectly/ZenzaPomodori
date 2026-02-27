# Zenza Pomodori

A tomato-free focus timer for your macOS menu bar.

## What It Does

- 25-minute focus blocks with short breaks (5 min) and long breaks (25 min) after every 4 blocks
- Lives in the menu bar with a popover for timer display and controls
- Circular progress ring, countdown, play/pause/skip/reset
- No dock icon, no distractions

## Getting Started

### To run a release build

Download the latest `.zip` from [Releases](https://github.com/derekspelledcorrectly/ZenzaPomodori/releases), unzip, and move `Zenza Pomodori.app` to `/Applications`. No dependencies required.

### To build from source

Requires macOS 15+, [Xcode](https://apps.apple.com/us/app/xcode/id497799835), and [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`).

```bash
make run      # Build and launch
make test     # Run unit tests
make release  # Build optimized .app and package as .zip
make clean    # Remove build artifacts
```

The app appears as an icon in your menu bar (not the Dock). Click it to open the timer.

## Project Structure

```
ZenzaPomodori/
  App/              # @main entry point, MenuBarExtra scene
  Models/           # TimerPhase enum
  ViewModels/       # PomodoroTimer engine
  Views/MenuBar/    # Popover UI: timer display, controls
  Utilities/        # Constants, time formatting helpers
  Resources/        # Info.plist, asset catalog
ZenzaPomodoriTests/ # Unit tests (Swift Testing framework)
project.yml         # XcodeGen spec (generates .xcodeproj, which is gitignored)
Makefile            # Build automation
```

## Roadmap

- [ ] Floating always-on-top mini timer
- [ ] Settings window with configurable durations
- [ ] System notifications on phase transitions
- [ ] Sound effects
- [ ] DND/Focus mode integration via Shortcuts.app
- [ ] App icon

## License

GPL-3.0. See [LICENSE](LICENSE).
