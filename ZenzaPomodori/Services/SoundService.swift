import AppKit
import os

@MainActor
final class SoundService {
    nonisolated static let disabled = "None"

    static let availableSounds: [String] = [
        "Alarmed", "Beeper", "Belligerent", "Calm", "Chord",
        "Chord2", "Chord2_Rev", "Cloud", "Enharpment", "Glass",
        "Glisten", "Jinja", "Jinja2", "Polite", "Reverie",
        "Sharp", "Taptap", "Whistleronic", "Whistleronic-Down",
    ]

    private var currentSound: NSSound?

    func play(_ name: String) {
        guard name != Self.disabled else { return }
        currentSound?.stop()
        guard let url = Bundle.main.url(forResource: name, withExtension: "m4a") else {
            Logger.services.warning("Sound file not found: \(name)")
            return
        }
        guard let sound = NSSound(contentsOf: url, byReference: true) else {
            Logger.services.warning("Could not load sound: \(name)")
            return
        }
        currentSound = sound
        sound.play()
    }

    func stop() {
        currentSound?.stop()
        currentSound = nil
    }
}
