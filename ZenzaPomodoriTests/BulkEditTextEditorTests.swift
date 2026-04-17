import Foundation
import Testing

@testable import ZenzaPomodori

@Suite("BulkEditTextEditor")
struct BulkEditTextEditorTests {

    // MARK: - Text to Items

    @Test func textToItemsCreatesNewItemsFromLines() {
        let existing: [RotationItem] = []
        let result = BulkEditTextEditor.syncTextToItems(
            text: "Code review\nAPI design\nDocs",
            existing: existing
        )
        #expect(result.count == 3)
        #expect(result[0].name == "Code review")
        #expect(result[1].name == "API design")
        #expect(result[2].name == "Docs")
    }

    @Test func textToItemsPreservesExistingUUIDs() {
        let existing = [
            RotationItem(name: "Code review"),
            RotationItem(name: "API design"),
        ]
        let result = BulkEditTextEditor.syncTextToItems(
            text: "Code review\nAPI design",
            existing: existing
        )
        #expect(result[0].id == existing[0].id)
        #expect(result[1].id == existing[1].id)
    }

    @Test func textToItemsUpdatesNamePreservingUUID() {
        let existing = [RotationItem(name: "Old name")]
        let result = BulkEditTextEditor.syncTextToItems(
            text: "New name",
            existing: existing
        )
        #expect(result[0].id == existing[0].id)
        #expect(result[0].name == "New name")
    }

    @Test func textToItemsDropsExtrasWhenFewerLines() {
        let existing = [
            RotationItem(name: "A"),
            RotationItem(name: "B"),
            RotationItem(name: "C"),
        ]
        let result = BulkEditTextEditor.syncTextToItems(
            text: "A\nB",
            existing: existing
        )
        #expect(result.count == 2)
        #expect(result[0].id == existing[0].id)
        #expect(result[1].id == existing[1].id)
    }

    @Test func textToItemsCreatesNewUUIDsForAddedLines() {
        let existing = [RotationItem(name: "A")]
        let result = BulkEditTextEditor.syncTextToItems(
            text: "A\nB\nC",
            existing: existing
        )
        #expect(result.count == 3)
        #expect(result[0].id == existing[0].id)
        #expect(result[1].id != existing[0].id)
        #expect(result[2].id != existing[0].id)
    }

    @Test func textToItemsFiltersEmptyLines() {
        let result = BulkEditTextEditor.syncTextToItems(
            text: "A\n\n\nB\n  \nC\n",
            existing: []
        )
        #expect(result.count == 3)
        #expect(result[0].name == "A")
        #expect(result[1].name == "B")
        #expect(result[2].name == "C")
    }

    @Test func textToItemsTrimsWhitespace() {
        let result = BulkEditTextEditor.syncTextToItems(
            text: "  Code review  \n  API design  ",
            existing: []
        )
        #expect(result[0].name == "Code review")
        #expect(result[1].name == "API design")
    }

    @Test func textToItemsEmptyTextReturnsEmpty() {
        let existing = [RotationItem(name: "A")]
        let result = BulkEditTextEditor.syncTextToItems(
            text: "",
            existing: existing
        )
        #expect(result.isEmpty)
    }

    @Test func textToItemsAllowsDuplicateNames() {
        let result = BulkEditTextEditor.syncTextToItems(
            text: "Focus\nFocus\nFocus",
            existing: []
        )
        #expect(result.count == 3)
        #expect(result[0].id != result[1].id)
        #expect(result[1].id != result[2].id)
    }

    // MARK: - Items to Text

    @Test func itemsToTextJoinsWithNewlines() {
        let items = [
            RotationItem(name: "Code review"),
            RotationItem(name: "API design"),
            RotationItem(name: "Docs"),
        ]
        let text = BulkEditTextEditor.syncItemsToText(items: items)
        #expect(text == "Code review\nAPI design\nDocs")
    }

    @Test func itemsToTextEmptyArrayReturnsEmptyString() {
        let text = BulkEditTextEditor.syncItemsToText(items: [])
        #expect(text == "")
    }
}
