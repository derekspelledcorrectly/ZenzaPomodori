import Foundation
import Observation

@Observable
@MainActor
final class PomodoroTimer {
    private(set) var phase: TimerPhase = .idle
    private(set) var secondsRemaining: Int = 0
    private(set) var isRunning: Bool = false
    private(set) var completedBlocks: Int = 0

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - Double(secondsRemaining) / Double(totalSeconds)
    }

    var formattedTime: String {
        TimeFormatting.formatted(seconds: secondsRemaining)
    }

    var totalSeconds: Int {
        duration(for: phase)
    }

    private var timerTask: Task<Void, Never>?

    // MARK: - Configuration

    var focusDuration: Int = Defaults.focusDuration
    var shortBreakDuration: Int = Defaults.shortBreakDuration
    var longBreakDuration: Int = Defaults.longBreakDuration
    var blocksBeforeLongBreak: Int = Defaults.blocksBeforeLongBreak

    // MARK: - Callbacks

    var onPhaseChange: ((TimerPhase, TimerPhase) -> Void)?

    // MARK: - Actions

    func start() {
        guard phase == .idle else { return }
        completedBlocks = 0
        transitionTo(.focus(block: 1))
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

    func skip() {
        guard phase != .idle else { return }
        pause()
        advancePhase()
        resume()
    }

    func reset() {
        pause()
        let oldPhase = phase
        phase = .idle
        secondsRemaining = 0
        completedBlocks = 0
        onPhaseChange?(oldPhase, .idle)
    }

    // MARK: - Internal

    private func tick() {
        guard secondsRemaining > 0 else { return }
        secondsRemaining -= 1
        if secondsRemaining == 0 {
            pause()
            advancePhase()
            resume()
        }
    }

    private func advancePhase() {
        switch phase {
        case .focus(let block):
            completedBlocks = block
            if block >= blocksBeforeLongBreak {
                transitionTo(.longBreak)
            } else {
                transitionTo(.shortBreak(afterBlock: block))
            }
        case .shortBreak(let afterBlock):
            transitionTo(.focus(block: afterBlock + 1))
        case .longBreak:
            transitionTo(.idle)
        case .idle:
            break
        }
    }

    private func transitionTo(_ newPhase: TimerPhase) {
        let oldPhase = phase
        phase = newPhase
        secondsRemaining = duration(for: newPhase)
        onPhaseChange?(oldPhase, newPhase)
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
