import Foundation
import Testing
@testable import ZenzaPomodori

@Suite("RotationStore")
@MainActor
struct RotationStoreTests {
    private func makeStore(defaults: UserDefaults? = nil) -> RotationStore {
        RotationStore(defaults: defaults ?? makeTestDefaults())
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
        let defaults = makeTestDefaults()
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

    // MARK: - Last Used Items

    @Test func lastUsedItemsStartsEmpty() {
        let store = makeStore()
        #expect(store.lastUsedItems.isEmpty)
    }

    @Test func setLastUsedItemsStoresItems() {
        let store = makeStore()
        let items = [RotationItem(name: "API"), RotationItem(name: "Tests")]
        store.lastUsedItems = items
        #expect(store.lastUsedItems.count == 2)
        #expect(store.lastUsedItems[0].name == "API")
        #expect(store.lastUsedItems[1].name == "Tests")
    }

    @Test func lastUsedItemsPersistAcrossInstances() {
        let defaults = makeTestDefaults()
        let store1 = RotationStore(defaults: defaults)
        store1.lastUsedItems = [
            RotationItem(name: "Design"),
            RotationItem(name: "Code"),
            RotationItem(name: "Review"),
        ]
        let store2 = RotationStore(defaults: defaults)
        #expect(store2.lastUsedItems.count == 3)
        #expect(store2.lastUsedItems[0].name == "Design")
        #expect(store2.lastUsedItems[1].name == "Code")
        #expect(store2.lastUsedItems[2].name == "Review")
    }

    @Test func lastUsedItemsPreservesIdentity() {
        let defaults = makeTestDefaults()
        let items = [RotationItem(name: "A"), RotationItem(name: "B")]
        let store1 = RotationStore(defaults: defaults)
        store1.lastUsedItems = items
        let store2 = RotationStore(defaults: defaults)
        #expect(store2.lastUsedItems[0].id == items[0].id)
        #expect(store2.lastUsedItems[1].id == items[1].id)
    }

    @Test func clearLastUsedItems() {
        let store = makeStore()
        store.lastUsedItems = [RotationItem(name: "A")]
        store.lastUsedItems = []
        #expect(store.lastUsedItems.isEmpty)
    }

    @Test func clearLastUsedItemsPersists() {
        let defaults = makeTestDefaults()
        let store1 = RotationStore(defaults: defaults)
        store1.lastUsedItems = [RotationItem(name: "A")]
        store1.lastUsedItems = []
        let store2 = RotationStore(defaults: defaults)
        #expect(store2.lastUsedItems.isEmpty)
    }
}
