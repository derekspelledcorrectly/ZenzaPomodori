import Foundation
import Observation

@Observable
@MainActor
final class PomodoroTimer {
    private(set) var phase: TimerPhase = .idle
    private(set) var secondsRemaining: Int = 0
    private(set) var isRunning: Bool = false
    private(set) var completedBlocks: Int = 0
    private(set) var pendingBlock: Int?
    private(set) var isOvertime: Bool = false
    private(set) var overtimeSeconds: Int = 0

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        if isOvertime { return 1.0 }
        return 1.0 - Double(secondsRemaining) / Double(totalSeconds)
    }

    var formattedTime: String {
        if isOvertime {
            return "+\(TimeFormatting.formatted(seconds: overtimeSeconds))"
        }
        if phase == .idle {
            return TimeFormatting.formatted(seconds: settings.focusDuration)
        }
        return TimeFormatting.formatted(seconds: secondsRemaining)
    }

    var totalSeconds: Int {
        duration(for: phase)
    }

    private var timerTask: Task<Void, Never>?

    // MARK: - Configuration

    let settings: SettingsStore
    let focusNameStore: FocusNameStore
    private(set) var activeFocusName: String?

    var focusNameIsLocked: Bool {
        phase.isFocus
    }

    private(set) var focusDuration: Int = Defaults.focusDuration
    private(set) var shortBreakDuration: Int = Defaults.shortBreakDuration
    private(set) var longBreakDuration: Int = Defaults.longBreakDuration
    private(set) var blocksBeforeLongBreak: Int = Defaults.blocksBeforeLongBreak
    private(set) var autoAdvance: Bool = Defaults.autoAdvance

    init(settings: SettingsStore = SettingsStore(), focusNameStore: FocusNameStore = FocusNameStore()) {
        self.settings = settings
        self.focusNameStore = focusNameStore
    }

    // MARK: - Callbacks

    var onPhaseChange: ((TimerPhase, TimerPhase) -> Void)?
    var onOvertimeStart: ((TimerPhase) -> Void)?

    // MARK: - Actions

    func start() {
        guard phase == .idle else { return }
        commitFocusName()
        if let block = pendingBlock {
            pendingBlock = nil
            transitionTo(.focus(block: block))
        } else {
            focusDuration = settings.focusDuration
            shortBreakDuration = settings.shortBreakDuration
            longBreakDuration = settings.longBreakDuration
            blocksBeforeLongBreak = settings.blocksBeforeLongBreak
            autoAdvance = settings.autoAdvance
            completedBlocks = 0
            transitionTo(.focus(block: 1))
        }
        resume()
    }

    func pause() {
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
    }

    func resume() {
        guard !isRunning, phase != .idle else { return }
        isRunning = true
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { break }
                self?.tick()
            }
        }
    }

    func next() {
        guard phase != .idle else { return }
        pause()
        advancePhase(fromAutoAdvance: false)
        if phase != .idle {
            resume()
        }
    }

    func restartPhase() {
        guard phase != .idle else { return }
        secondsRemaining = duration(for: phase)
        isOvertime = false
        overtimeSeconds = 0
    }

    func reset() {
        pause()
        let oldPhase = phase
        phase = .idle
        secondsRemaining = 0
        completedBlocks = 0
        pendingBlock = nil
        isOvertime = false
        overtimeSeconds = 0
        activeFocusName = nil
        onPhaseChange?(oldPhase, .idle)
    }

    // MARK: - Internal

    func tick() {
        if isOvertime {
            overtimeSeconds += 1
            return
        }
        guard secondsRemaining > 0 else { return }
        secondsRemaining -= 1
        if secondsRemaining == 0 {
            if autoAdvance {
                advancePhase(fromAutoAdvance: true)
                if phase == .idle {
                    pause()
                }
            } else {
                isOvertime = true
                overtimeSeconds = 0
                onOvertimeStart?(phase)
            }
        }
    }

    private func advancePhase(fromAutoAdvance: Bool = false) {
        switch phase {
        case .focus(let block):
            completedBlocks = block
            if block >= blocksBeforeLongBreak {
                transitionTo(.longBreak)
            } else {
                transitionTo(.shortBreak(afterBlock: block))
            }
        case .shortBreak(let afterBlock):
            if fromAutoAdvance {
                commitFocusName()
                transitionTo(.focus(block: afterBlock + 1))
            } else {
                pendingBlock = afterBlock + 1
                transitionTo(.idle)
            }
        case .longBreak:
            transitionTo(.idle)
        case .idle:
            break
        }
    }

    private func transitionTo(_ newPhase: TimerPhase) {
        let oldPhase = phase
        focusDuration = settings.focusDuration
        shortBreakDuration = settings.shortBreakDuration
        longBreakDuration = settings.longBreakDuration
        phase = newPhase
        secondsRemaining = duration(for: newPhase)
        isOvertime = false
        overtimeSeconds = 0
        onPhaseChange?(oldPhase, newPhase)
    }

    private func commitFocusName() {
        let trimmed = focusNameStore.draftName.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            focusNameStore.commitCurrentName()
            activeFocusName = trimmed
        } else {
            activeFocusName = nil
        }
    }

    private func duration(for phase: TimerPhase) -> Int {
        switch phase {
        case .idle: 0
        case .focus: focusDuration
        case .shortBreak: shortBreakDuration
        case .longBreak: longBreakDuration
        }
    }
}
