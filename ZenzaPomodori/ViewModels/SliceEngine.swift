import Foundation
import Observation

@Observable
@MainActor
final class SliceEngine {
    private(set) var rotationItems: [RotationItem]
    let interval: Int

    private(set) var currentIndex: Int = 0
    private(set) var sliceSecondsRemaining: Int = 0
    private(set) var isActive: Bool = false
    private(set) var isPaused: Bool = false

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
        return 1.0 - Double(sliceSecondsRemaining) / Double(interval)
    }

    var onRotationChange: ((Int, String) -> Void)?
    var onRotationComplete: (() -> Void)?

    init(items: [RotationItem], interval: Int) {
        self.rotationItems = items
        self.interval = interval
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
    }

    func tick() {
        guard isActive, !isPaused, sliceSecondsRemaining > 0 else { return }
        sliceSecondsRemaining -= 1
        if sliceSecondsRemaining == 0 {
            onRotationComplete?()
            advanceToNext()
        }
    }

    func skip() {
        guard isActive else { return }
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

    func pause() {
        guard isActive else { return }
        isPaused = true
    }

    func resume() {
        guard isActive, isPaused else { return }
        isPaused = false
    }

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
