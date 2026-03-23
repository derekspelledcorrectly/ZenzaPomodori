import Foundation
import Testing
@testable import ZenzaPomodori

@Suite("RotationStore")
@MainActor
struct RotationStoreTests {
    private func makeStore(defaults: UserDefaults? = nil) -> RotationStore {
        let d = defaults ?? UserDefaults(suiteName: "test-rotation-\(UUID().uuidString)")!
        return RotationStore(defaults: d)
    }

    @Test func startsWithNoSavedRotations() {
        let store = makeStore()
        #expect(store.savedRotations.isEmpty)
    }

    @Test func saveRotationAddsToList() {
        let store = makeStore()
        let items = [RotationItem(name: "API"), RotationItem(name: "CI")]
        store.saveRotation(name: "Morning", items: items)
        #expect(store.savedRotations.count == 1)
        #expect(store.savedRotations[0].name == "Morning")
        #expect(store.savedRotations[0].items.count == 2)
    }

    @Test func saveMultipleRotations() {
        let store = makeStore()
        store.saveRotation(name: "Morning", items: [RotationItem(name: "A")])
        store.saveRotation(name: "Afternoon", items: [RotationItem(name: "B")])
        #expect(store.savedRotations.count == 2)
    }

    @Test func deleteRotation() {
        let store = makeStore()
        store.saveRotation(name: "Morning", items: [RotationItem(name: "A")])
        let id = store.savedRotations[0].id
        store.deleteRotation(id)
        #expect(store.savedRotations.isEmpty)
    }

    @Test func deleteNonexistentIdIsNoOp() {
        let store = makeStore()
        store.saveRotation(name: "Morning", items: [RotationItem(name: "A")])
        store.deleteRotation(UUID())
        #expect(store.savedRotations.count == 1)
    }

    @Test func renameRotation() {
        let store = makeStore()
        store.saveRotation(name: "Old", items: [RotationItem(name: "A")])
        let id = store.savedRotations[0].id
        store.renameRotation(id, to: "New")
        #expect(store.savedRotations[0].name == "New")
    }

    @Test func rotationsPersistAcrossInstances() {
        let suiteName = "test-rotation-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let store1 = RotationStore(defaults: defaults)
        store1.saveRotation(name: "Persisted", items: [
            RotationItem(name: "X"),
            RotationItem(name: "Y"),
        ])
        let store2 = RotationStore(defaults: defaults)
        #expect(store2.savedRotations.count == 1)
        #expect(store2.savedRotations[0].name == "Persisted")
        #expect(store2.savedRotations[0].items.count == 2)
    }
}
