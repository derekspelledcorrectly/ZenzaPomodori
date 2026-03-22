import UserNotifications

@MainActor
final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    private let center = UNUserNotificationCenter.current()
    private let settings: SettingsStore
    private var isAuthorized = false
    var onNotificationTapped: (() -> Void)?

    init(settings: SettingsStore) {
        self.settings = settings
    }

    func requestPermission() {
        guard !isAuthorized else { return }
        center.delegate = self
        Task {
            do {
                isAuthorized = try await center.requestAuthorization(
                    options: [.alert]
                )
            } catch {
                isAuthorized = false
            }
        }
    }

    func sendCompletionNotification(for phase: TimerPhase) {
        guard settings.notificationsEnabled else { return }
        guard phase != .idle else { return }
        guard isAuthorized else {
            requestPermission()
            return
        }

        let content = makeNotificationContent(for: phase)
        let request = UNNotificationRequest(
            identifier: "completion-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        center.add(request)
    }

    func makeNotificationContent(for phase: TimerPhase) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "\(phase.label(totalBlocks: Defaults.blocksBeforeLongBreak)) Complete"
        content.body = completionBody(for: phase)
        return content
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        await MainActor.run {
            onNotificationTapped?()
        }
    }

    private func completionBody(for phase: TimerPhase) -> String {
        switch phase {
        case .focus:
            "Time for a break!"
        case .shortBreak, .longBreak:
            "Break's over. Ready to focus?"
        case .idle:
            ""
        }
    }
}
