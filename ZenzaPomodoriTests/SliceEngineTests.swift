import Foundation
import Testing
@testable import ZenzaPomodori

@Suite("SliceEngine")
@MainActor
struct SliceEngineTests {
    private func makeEngine(
        items: [RotationItem]? = nil,
        interval: Int = 180
    ) -> SliceEngine {
        let defaultItems = items ?? [
            RotationItem(name: "API"),
            RotationItem(name: "CI"),
            RotationItem(name: "Frontend"),
        ]
        return SliceEngine(items: defaultItems, interval: interval)
    }

    // MARK: - Initial State
    @Test func startsInactive() {
        let engine = makeEngine()
        #expect(engine.isActive == false)
        #expect(engine.isPaused == false)
        #expect(engine.currentIndex == 0)
    }

    @Test func storesItemsAndInterval() {
        let engine = makeEngine(interval: 120)
        #expect(engine.rotationItems.count == 3)
        #expect(engine.interval == 120)
    }

    // MARK: - Activation
    @Test func activateSetsFirstItemAndCountdown() {
        let engine = makeEngine(interval: 180)
        engine.activate()
        #expect(engine.isActive == true)
        #expect(engine.currentIndex == 0)
        #expect(engine.sliceSecondsRemaining == 180)
        #expect(engine.currentItemName == "API")
        engine.deactivate()
    }

    @Test func activateWhileActiveIsNoOp() {
        let engine = makeEngine()
        engine.activate()
        engine.tick()
        engine.activate()
        #expect(engine.sliceSecondsRemaining == 179)
        engine.deactivate()
    }

    @Test func deactivateResetsState() {
        let engine = makeEngine()
        engine.activate()
        engine.tick()
        engine.deactivate()
        #expect(engine.isActive == false)
        #expect(engine.currentIndex == 0)
        #expect(engine.sliceSecondsRemaining == 0)
    }

    // MARK: - Tick
    @Test func tickDecrementsCountdown() {
        let engine = makeEngine(interval: 180)
        engine.activate()
        engine.tick()
        #expect(engine.sliceSecondsRemaining == 179)
        engine.deactivate()
    }

    @Test func tickWhileInactiveIsNoOp() {
        let engine = makeEngine()
        engine.tick()
        #expect(engine.sliceSecondsRemaining == 0)
    }

    @Test func tickWhilePausedIsNoOp() {
        let engine = makeEngine(interval: 180)
        engine.activate()
        engine.pause()
        engine.tick()
        #expect(engine.sliceSecondsRemaining == 180)
        engine.deactivate()
    }

    // MARK: - Rotation
    @Test func tickToZeroAdvancesToNextItem() {
        let engine = makeEngine(interval: 3)
        engine.activate()
        for _ in 0..<3 { engine.tick() }
        #expect(engine.currentIndex == 1)
        #expect(engine.currentItemName == "CI")
        #expect(engine.sliceSecondsRemaining == 3)
        engine.deactivate()
    }

    @Test func rotationLoopsBackToFirst() {
        let engine = makeEngine(interval: 1)
        engine.activate()
        for _ in 0..<3 { engine.tick() }
        #expect(engine.currentIndex == 0)
        #expect(engine.currentItemName == "API")
        engine.deactivate()
    }

    @Test func rotationChangeCallbackFires() {
        let engine = makeEngine(interval: 1)
        var changes: [(Int, String)] = []
        engine.onRotationChange = { index, name in changes.append((index, name)) }
        engine.activate()
        engine.tick()
        #expect(changes.count == 1)
        #expect(changes[0].0 == 1)
        #expect(changes[0].1 == "CI")
        engine.deactivate()
    }

    @Test func rotationCompleteCallbackFires() {
        let engine = makeEngine(interval: 1)
        var completeCount = 0
        engine.onRotationComplete = { completeCount += 1 }
        engine.activate()
        engine.tick()
        #expect(completeCount == 1)
        engine.deactivate()
    }

    // MARK: - Skip
    @Test func skipAdvancesImmediately() {
        let engine = makeEngine(interval: 180)
        engine.activate()
        engine.tick()
        engine.skip()
        #expect(engine.currentIndex == 1)
        #expect(engine.currentItemName == "CI")
        #expect(engine.sliceSecondsRemaining == 180)
        engine.deactivate()
    }

    @Test func skipWhileInactiveIsNoOp() {
        let engine = makeEngine()
        engine.skip()
        #expect(engine.currentIndex == 0)
    }

    // MARK: - Pause / Resume
    @Test func pauseAndResume() {
        let engine = makeEngine(interval: 180)
        engine.activate()
        engine.tick()
        engine.pause()
        #expect(engine.isPaused == true)
        engine.tick()
        #expect(engine.sliceSecondsRemaining == 179)
        engine.resume()
        #expect(engine.isPaused == false)
        engine.tick()
        #expect(engine.sliceSecondsRemaining == 178)
        engine.deactivate()
    }

    // MARK: - Edge Cases
    @Test func singleItemRotation() {
        let engine = makeEngine(items: [RotationItem(name: "Solo")], interval: 1)
        engine.activate()
        engine.tick()
        #expect(engine.currentIndex == 0)
        #expect(engine.currentItemName == "Solo")
        engine.deactivate()
    }

    @Test func emptyItemsActivateIsNoOp() {
        let engine = SliceEngine(items: [], interval: 180)
        engine.activate()
        #expect(engine.isActive == false)
        #expect(engine.currentItemName == nil)
    }

    @Test func skipFiresRotationChangeCallback() {
        let engine = makeEngine(interval: 180)
        var changes: [(Int, String)] = []
        engine.onRotationChange = { index, name in changes.append((index, name)) }
        engine.activate()
        engine.skip()
        #expect(changes.count == 1)
        #expect(changes[0].1 == "CI")
        engine.deactivate()
    }

    // MARK: - Progress
    @Test func progressCalculation() {
        let engine = makeEngine(interval: 100)
        engine.activate()
        #expect(engine.progress == 0.0)
        for _ in 0..<50 { engine.tick() }
        #expect(engine.progress == 0.5)
        engine.deactivate()
    }

    @Test func nextItemName() {
        let engine = makeEngine()
        engine.activate()
        #expect(engine.nextItemName == "CI")
        engine.deactivate()
    }

    // MARK: - Update Items

    @Test func updateItemsPreservesCurrentPosition() {
        let items = [
            RotationItem(name: "API"),
            RotationItem(name: "CI"),
            RotationItem(name: "Frontend"),
        ]
        let engine = SliceEngine(items: items, interval: 180)
        engine.activate()
        engine.skip() // now on CI (index 1)
        #expect(engine.currentItemName == "CI")

        var newItems = items
        newItems.append(RotationItem(name: "Docs"))
        engine.updateItems(newItems)

        #expect(engine.currentItemName == "CI")
        #expect(engine.rotationItems.count == 4)
    }

    @Test func updateItemsWhenCurrentRemovedClamps() {
        let items = [
            RotationItem(name: "API"),
            RotationItem(name: "CI"),
            RotationItem(name: "Frontend"),
        ]
        let engine = SliceEngine(items: items, interval: 180)
        engine.activate()
        engine.skip() // now on CI (index 1)
        engine.skip() // now on Frontend (index 2)
        #expect(engine.currentItemName == "Frontend")

        let newItems = [items[0]] // only API remains
        engine.updateItems(newItems)

        #expect(engine.currentIndex == 0)
        #expect(engine.currentItemName == "API")
    }

    @Test func updateItemsWhileInactiveIsNoOp() {
        let engine = makeEngine()
        engine.updateItems([RotationItem(name: "New")])
        #expect(engine.rotationItems.count == 3) // unchanged
    }

    @Test func updateItemsEmptyListIsNoOp() {
        let engine = makeEngine()
        engine.activate()
        engine.updateItems([])
        #expect(engine.rotationItems.count == 3)
        engine.deactivate()
    }
}
