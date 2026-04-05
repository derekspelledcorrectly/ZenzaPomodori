import Foundation
import Observation

@Observable
@MainActor
final class SliceEngine {
    private(set) var rotationItems: [RotationItem]
    let interval: Int
    let autoAdvance: Bool
    let settings: SettingsStore

    private(set) var currentIndex: Int = 0
    private(set) var sliceSecondsRemaining: Int = 0
    private(set) var isActive: Bool = false
    private(set) var isPaused: Bool = false
    private(set) var isOvertime: Bool = false
    private(set) var overtimeSeconds: Int = 0

    private var timerTask: Task<Void, Never>?

    var currentItemName: String? {
        guard !rotationItems.isEmpty, currentIndex < rotationItems.count else { return nil }
        return rotationItems[currentIndex].name
    }

    var nextItemName: String? {
        guard rotationItems.count > 1 else { return nil }
        let nextIndex = (currentIndex + 1) % rotationItems.count
        return rotationItems[nextIndex].name
    }

    var progress: Double {
        guard interval > 0 else { return 0 }
        if isOvertime { return 1.0 }
        return 1.0 - Double(sliceSecondsRemaining) / Double(interval)
    }

    var formattedTime: String {
        if isOvertime {
            return "+\(TimeFormatting.formatted(seconds: overtimeSeconds))"
        }
        return TimeFormatting.formatted(seconds: sliceSecondsRemaining)
    }

    var onRotationChange: ((Int, String) -> Void)?
    var onRotationComplete: (() -> Void)?
    var onOvertimeStart: (() -> Void)?
    var onOvertimeReminder: (() -> Void)?

    init(items: [RotationItem], interval: Int, autoAdvance: Bool = true, settings: SettingsStore) {
        self.rotationItems = items
        self.interval = interval
        self.autoAdvance = autoAdvance
        self.settings = settings
    }

    func activate() {
        guard !isActive, !rotationItems.isEmpty else { return }
        isActive = true
        currentIndex = 0
        sliceSecondsRemaining = interval
        startTickLoop()
    }

    func deactivate() {
        timerTask?.cancel()
        timerTask = nil
        isActive = false
        isPaused = false
        currentIndex = 0
        sliceSecondsRemaining = 0
        isOvertime = false
        overtimeSeconds = 0
    }

    func tick() {
        guard isActive, !isPaused else { return }
        if isOvertime {
            overtimeSeconds += 1
            let reminderInterval = settings.sliceOvertimeReminderEnabled
                ? settings.sliceOvertimeReminderInterval : 0
            if reminderInterval > 0 && overtimeSeconds > 0 && overtimeSeconds % reminderInterval == 0 {
                onOvertimeReminder?()
            }
            return
        }
        guard sliceSecondsRemaining > 0 else { return }
        sliceSecondsRemaining -= 1
        if sliceSecondsRemaining == 0 {
            onRotationComplete?()
            if autoAdvance {
                advanceToNext()
            } else {
                isOvertime = true
                onOvertimeStart?()
            }
        }
    }

    func skip() {
        guard isActive else { return }
        isOvertime = false
        overtimeSeconds = 0
        advanceToNext()
    }

    func updateItems(_ newItems: [RotationItem]) {
        guard isActive, !newItems.isEmpty else { return }
        let currentId = rotationItems.indices.contains(currentIndex)
            ? rotationItems[currentIndex].id : nil
        rotationItems = newItems
        if let currentId, let idx = newItems.firstIndex(where: { $0.id == currentId }) {
            currentIndex = idx
        } else {
            currentIndex = min(currentIndex, newItems.count - 1)
        }
    }

    func restartSlice() {
        guard isActive else { return }
        isOvertime = false
        overtimeSeconds = 0
        sliceSecondsRemaining = interval
    }

    func pause() {
        guard isActive else { return }
        isPaused = true
    }

    func resume() {
        guard isActive, isPaused else { return }
        isPaused = false
    }

    // MARK: - Debug

    #if DEBUG
    func debugSkipToEnd() {
        guard isActive else { return }
        sliceSecondsRemaining = 10
    }

    func debugAddTime(_ seconds: Int) {
        guard isActive else { return }
        if isOvertime {
            overtimeSeconds += seconds
        } else {
            sliceSecondsRemaining += seconds
        }
    }
    #endif

    private func advanceToNext() {
        guard !rotationItems.isEmpty else { return }
        currentIndex = (currentIndex + 1) % rotationItems.count
        sliceSecondsRemaining = interval
        if let name = currentItemName {
            onRotationChange?(currentIndex, name)
        }
    }

    private func startTickLoop() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { break }
                self?.tick()
            }
        }
    }
}
