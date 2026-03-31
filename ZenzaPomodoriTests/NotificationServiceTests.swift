import Foundation
import Testing
@testable import ZenzaPomodori

@Suite("NotificationService")
@MainActor
struct NotificationServiceTests {
    private func makeStore(soundEnabled: Bool = true) -> SettingsStore {
        makeTestSettingsStore { $0.soundEnabled = soundEnabled }
    }

    @Test func notificationContentNeverIncludesSound() {
        let store = makeStore(soundEnabled: true)
        let service = NotificationService(settings: store)
        let content = service.makeNotificationContent(for: .focus(block: 1))
        #expect(content.sound == nil)
    }

    @Test func notificationContentSoundNilWhenDisabled() {
        let store = makeStore(soundEnabled: false)
        let service = NotificationService(settings: store)
        let content = service.makeNotificationContent(for: .focus(block: 1))
        #expect(content.sound == nil)
    }

    @Test func notificationContentTitle() {
        let store = makeStore(soundEnabled: true)
        let service = NotificationService(settings: store)
        let content = service.makeNotificationContent(for: .focus(block: 2))
        #expect(content.title == "Focus 2/4 Complete")
    }
}
