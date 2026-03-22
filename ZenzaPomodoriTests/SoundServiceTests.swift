import Testing
@testable import ZenzaPomodori

@Suite("SoundService")
@MainActor
struct SoundServiceTests {
    @Test func availableSoundsIsNotEmpty() {
        #expect(!SoundService.availableSounds.isEmpty)
    }

    @Test func availableSoundsContainsDefaultSound() {
        #expect(SoundService.availableSounds.contains(Defaults.selectedSound))
    }

    @Test func availableSoundsAreSorted() {
        let sorted = SoundService.availableSounds.sorted()
        #expect(SoundService.availableSounds == sorted)
    }

    @Test func playWithInvalidNameDoesNotCrash() {
        let service = SoundService()
        service.play("nonexistent-sound-that-does-not-exist")
    }

    @Test func stopClearsWithoutCrash() {
        let service = SoundService()
        service.stop()
    }
}
