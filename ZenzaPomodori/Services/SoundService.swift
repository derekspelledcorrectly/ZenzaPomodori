import AppKit

@MainActor
final class SoundService {
    static let availableSounds: [String] = [
        "Alarmed", "Beeper", "Belligerent", "Calm", "Chord",
        "Chord2", "Chord2_Rev", "Cloud", "Enharpment", "Glass",
        "Glisten", "Jinja", "Jinja2", "Polite", "Reverie",
        "Sharp", "Taptap", "Whistleronic", "Whistleronic-Down"
    ]

    private var currentSound: NSSound?

    func play(_ name: String) {
        currentSound?.stop()
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav"),
              let sound = NSSound(contentsOf: url, byReference: true) else { return }
        currentSound = sound
        sound.play()
    }

    func stop() {
        currentSound?.stop()
        currentSound = nil
    }
}
