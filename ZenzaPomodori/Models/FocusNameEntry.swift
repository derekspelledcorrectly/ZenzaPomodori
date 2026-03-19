import Foundation

struct FocusNameEntry: Codable, Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    var isFavorite: Bool

    init(id: UUID = UUID(), name: String, isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.isFavorite = isFavorite
    }
}
