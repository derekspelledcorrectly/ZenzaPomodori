import Foundation
import Observation
import os

@Observable
@MainActor
final class RotationStore {
    private let defaults: UserDefaults

    private(set) var savedRotations: [SavedRotation] {
        didSet { persist() }
    }

    var lastUsedItems: [RotationItem] {
        didSet { persistLastUsed() }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.savedRotations = Self.load(from: defaults)
        self.lastUsedItems = Self.loadLastUsed(from: defaults)
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
        do {
            let data = try JSONEncoder().encode(savedRotations)
            defaults.set(data, forKey: SettingsKeys.savedRotations)
        } catch {
            Logger.storage.error("Failed to encode rotations: \(error.localizedDescription)")
        }
    }

    private func persistLastUsed() {
        do {
            let data = try JSONEncoder().encode(lastUsedItems)
            defaults.set(data, forKey: SettingsKeys.lastUsedRotationItems)
        } catch {
            Logger.storage.error("Failed to encode last used items: \(error.localizedDescription)")
        }
    }

    private static func load(from defaults: UserDefaults) -> [SavedRotation] {
        guard let data = defaults.data(forKey: SettingsKeys.savedRotations) else {
            return [] // No data yet, legitimate empty state
        }
        do {
            return try JSONDecoder().decode([SavedRotation].self, from: data)
        } catch {
            Logger.storage.error("Failed to decode saved rotations: \(error.localizedDescription)")
            return []
        }
    }

    private static func loadLastUsed(from defaults: UserDefaults) -> [RotationItem] {
        guard let data = defaults.data(forKey: SettingsKeys.lastUsedRotationItems) else {
            return []
        }
        do {
            return try JSONDecoder().decode([RotationItem].self, from: data)
        } catch {
            Logger.storage.error("Failed to decode last used items: \(error.localizedDescription)")
            return []
        }
    }
}
