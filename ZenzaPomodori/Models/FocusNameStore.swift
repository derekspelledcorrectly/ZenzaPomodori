import Foundation
import Observation

@Observable
@MainActor
final class FocusNameStore {
    private let defaults: UserDefaults

    var draftName: String {
        didSet { defaults.set(draftName, forKey: SettingsKeys.focusNameDraft) }
    }

    private(set) var entries: [FocusNameEntry] {
        didSet { persistEntries() }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.draftName = defaults.string(forKey: SettingsKeys.focusNameDraft) ?? ""
        self.entries = Self.loadEntries(from: defaults)
    }

    func commitCurrentName() {
        let trimmed = draftName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        if let index = entries.firstIndex(where: { $0.name == trimmed }) {
            guard !entries[index].isFavorite else { return }
            let existing = entries.remove(at: index)
            entries.insert(existing, at: firstRecentIndex)
        } else {
            entries.insert(FocusNameEntry(name: trimmed), at: firstRecentIndex)
        }
        trimRecents()
    }

    func toggleFavorite(_ id: UUID) {
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }
        entries[index].isFavorite.toggle()
        sortEntries()
    }

    func deleteEntry(_ id: UUID) {
        entries.removeAll { $0.id == id }
    }

    // MARK: - Private

    private var firstRecentIndex: Int {
        entries.firstIndex(where: { !$0.isFavorite }) ?? entries.count
    }

    private func trimRecents() {
        var recentCount = 0
        entries = entries.filter { entry in
            if entry.isFavorite { return true }
            recentCount += 1
            return recentCount <= Defaults.focusNameMaxRecents
        }
    }

    private func sortEntries() {
        let favorites = entries.filter { $0.isFavorite }
        let recents = entries.filter { !$0.isFavorite }
        entries = favorites + recents
    }

    private func persistEntries() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        defaults.set(data, forKey: SettingsKeys.focusNameEntries)
    }

    private static func loadEntries(from defaults: UserDefaults) -> [FocusNameEntry] {
        guard let data = defaults.data(forKey: SettingsKeys.focusNameEntries),
              let entries = try? JSONDecoder().decode([FocusNameEntry].self, from: data) else {
            return []
        }
        return entries
    }
}
