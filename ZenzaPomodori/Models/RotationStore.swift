import Foundation
import Observation

@Observable
@MainActor
final class RotationStore {
    private let defaults: UserDefaults

    private(set) var savedRotations: [SavedRotation] {
        didSet { persist() }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.savedRotations = Self.load(from: defaults)
    }

    func saveRotation(name: String, items: [RotationItem]) {
        let rotation = SavedRotation(name: name, items: items)
        savedRotations.append(rotation)
    }

    func deleteRotation(_ id: UUID) {
        savedRotations.removeAll { $0.id == id }
    }

    func renameRotation(_ id: UUID, to newName: String) {
        guard let index = savedRotations.firstIndex(where: { $0.id == id }) else { return }
        savedRotations[index].name = newName
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(savedRotations) else { return }
        defaults.set(data, forKey: SettingsKeys.savedRotations)
    }

    private static func load(from defaults: UserDefaults) -> [SavedRotation] {
        guard let data = defaults.data(forKey: SettingsKeys.savedRotations),
              let rotations = try? JSONDecoder().decode([SavedRotation].self, from: data) else {
            return []
        }
        return rotations
    }
}
