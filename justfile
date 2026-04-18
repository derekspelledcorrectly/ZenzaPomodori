set shell := ["bash", "-uc"]

# Default: show available recipes
default:
    @just --list

# Run all quality gates. THE "ready to commit?" command.
check: format-check lint test

# Format all Swift files in-place
format:
    xcrun swift-format format --in-place --recursive ZenzaPomodori ZenzaPomodoriTests

# Check formatting without modifying files (fails on any deviation)
format-check:
    xcrun swift-format lint --recursive --strict ZenzaPomodori ZenzaPomodoriTests

# Run SwiftLint
lint:
    swiftlint lint --quiet

# Auto-fix SwiftLint violations where possible
lint-fix:
    swiftlint --fix

# Run the test suite (delegates to make so there's one source of truth)
test:
    make test
