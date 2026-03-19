import Foundation
import Testing
@testable import ZenzaPomodori

@Suite("FocusNameStore")
@MainActor
struct FocusNameStoreTests {
    private func makeStore(
        defaults: UserDefaults? = nil
    ) -> FocusNameStore {
        let d = defaults ?? UserDefaults(suiteName: "test-focus-\(UUID().uuidString)")!
        return FocusNameStore(defaults: d)
    }

    // MARK: - Defaults

    @Test func startsWithEmptyDraftAndHistory() {
        let store = makeStore()
        #expect(store.draftName == "")
        #expect(store.entries.isEmpty)
    }

    // MARK: - Commit

    @Test func commitAddsEntryToHistory() {
        let store = makeStore()
        store.draftName = "Deep Work"
        store.commitCurrentName()
        #expect(store.entries.count == 1)
        #expect(store.entries[0].name == "Deep Work")
        #expect(store.entries[0].isFavorite == false)
    }

    @Test func commitEmptyNameIsNoOp() {
        let store = makeStore()
        store.draftName = ""
        store.commitCurrentName()
        #expect(store.entries.isEmpty)
    }

    @Test func commitWhitespaceOnlyIsNoOp() {
        let store = makeStore()
        store.draftName = "   "
        store.commitCurrentName()
        #expect(store.entries.isEmpty)
    }

    @Test func commitDuplicateBumpsToFront() {
        let store = makeStore()
        store.draftName = "Code Review"
        store.commitCurrentName()
        store.draftName = "Deep Work"
        store.commitCurrentName()
        store.draftName = "Code Review"
        store.commitCurrentName()

        let nonFavorites = store.entries.filter { !$0.isFavorite }
        #expect(nonFavorites.count == 2)
        #expect(nonFavorites[0].name == "Code Review")
        #expect(nonFavorites[1].name == "Deep Work")
    }

    @Test func commitFavoriteDuplicateDoesNotDuplicate() {
        let store = makeStore()
        store.draftName = "Deep Work"
        store.commitCurrentName()
        store.toggleFavorite(store.entries[0].id)

        store.draftName = "Deep Work"
        store.commitCurrentName()

        #expect(store.entries.count == 1)
        #expect(store.entries[0].isFavorite == true)
    }

    @Test func commitCapsRecentsAt25() {
        let store = makeStore()
        for i in 1...26 {
            store.draftName = "Task \(i)"
            store.commitCurrentName()
        }

        let recents = store.entries.filter { !$0.isFavorite }
        #expect(recents.count == Defaults.focusNameMaxRecents)
        #expect(recents[0].name == "Task 26")
        // Task 1 should have been dropped (oldest)
        #expect(!recents.contains { $0.name == "Task 1" })
    }

    @Test func commitDoesNotCapFavorites() {
        let store = makeStore()
        // Add 3 favorites
        for i in 1...3 {
            store.draftName = "Fav \(i)"
            store.commitCurrentName()
            store.toggleFavorite(store.entries.first { $0.name == "Fav \(i)" }!.id)
        }
        // Add 25 recents
        for i in 1...25 {
            store.draftName = "Recent \(i)"
            store.commitCurrentName()
        }

        let favorites = store.entries.filter { $0.isFavorite }
        let recents = store.entries.filter { !$0.isFavorite }
        #expect(favorites.count == 3)
        #expect(recents.count == 25)
        #expect(store.entries.count == 28)
    }

    // MARK: - Favorites

    @Test func toggleFavorite() {
        let store = makeStore()
        store.draftName = "Deep Work"
        store.commitCurrentName()
        let id = store.entries[0].id

        store.toggleFavorite(id)
        #expect(store.entries[0].isFavorite == true)

        store.toggleFavorite(id)
        #expect(store.entries[0].isFavorite == false)
    }

    @Test func favoritesAppearBeforeRecents() {
        let store = makeStore()
        store.draftName = "First"
        store.commitCurrentName()
        store.draftName = "Second"
        store.commitCurrentName()
        store.draftName = "Third"
        store.commitCurrentName()

        // "First" is last in recents. Favorite it.
        let firstId = store.entries.first { $0.name == "First" }!.id
        store.toggleFavorite(firstId)

        #expect(store.entries[0].name == "First")
        #expect(store.entries[0].isFavorite == true)
    }

    // MARK: - Delete

    @Test func deleteEntry() {
        let store = makeStore()
        store.draftName = "Deep Work"
        store.commitCurrentName()
        let id = store.entries[0].id

        store.deleteEntry(id)
        #expect(store.entries.isEmpty)
    }

    @Test func deleteNonexistentIdIsNoOp() {
        let store = makeStore()
        store.draftName = "Deep Work"
        store.commitCurrentName()

        store.deleteEntry(UUID())
        #expect(store.entries.count == 1)
    }

    // MARK: - Persistence

    @Test func entriesPersistAcrossInstances() {
        let suiteName = "test-focus-persist-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!

        let store1 = FocusNameStore(defaults: defaults)
        store1.draftName = "Deep Work"
        store1.commitCurrentName()
        store1.toggleFavorite(store1.entries[0].id)

        let store2 = FocusNameStore(defaults: defaults)
        #expect(store2.entries.count == 1)
        #expect(store2.entries[0].name == "Deep Work")
        #expect(store2.entries[0].isFavorite == true)
    }

    @Test func draftNamePersistsAcrossInstances() {
        let suiteName = "test-focus-draft-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!

        let store1 = FocusNameStore(defaults: defaults)
        store1.draftName = "In Progress"

        let store2 = FocusNameStore(defaults: defaults)
        #expect(store2.draftName == "In Progress")
    }
}
