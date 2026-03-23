import Foundation

struct SavedRotation: Codable, Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    var items: [RotationItem]

    init(id: UUID = UUID(), name: String, items: [RotationItem]) {
        self.id = id
        self.name = name
        self.items = items
    }
}
