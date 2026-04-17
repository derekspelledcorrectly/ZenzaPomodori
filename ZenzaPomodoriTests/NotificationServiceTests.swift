import Foundation
import Testing

@testable import ZenzaPomodori

@Suite("NotificationService")
@MainActor
struct NotificationServiceTests {
    private func makeStore() -> SettingsStore {
        makeTestSettingsStore()
    }

    @Test func notificationContentNeverIncludesSound() {
        let store = makeStore()
        let service = NotificationService(settings: store)
        let content = service.makeNotificationContent(for: .focus(block: 1))
        #expect(content.sound == nil)
    }

    @Test func notificationContentTitle() {
        let store = makeStore()
        let service = NotificationService(settings: store)
        let content = service.makeNotificationContent(for: .focus(block: 2))
        #expect(content.title == "Focus 2/4 Complete")
    }
}
