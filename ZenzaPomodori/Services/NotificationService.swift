import UserNotifications

@MainActor
final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    private let center = UNUserNotificationCenter.current()
    private var isAuthorized = false
    var onNotificationTapped: (() -> Void)?

    func requestPermission() {
        center.delegate = self
        Task {
            do {
                isAuthorized = try await center.requestAuthorization(
                    options: [.alert, .sound]
                )
            } catch {
                isAuthorized = false
            }
        }
    }

    func sendPhaseNotification(to newPhase: TimerPhase) {
        guard isAuthorized else { return }
        guard newPhase != .idle else { return }

        let content = UNMutableNotificationContent()
        content.title = newPhase.label
        content.body = notificationBody(for: newPhase)
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "phaseChange-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        center.add(request)
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        await MainActor.run {
            onNotificationTapped?()
        }
    }

    private func notificationBody(for phase: TimerPhase) -> String {
        switch phase {
        case .focus:
            "Time to focus!"
        case .shortBreak:
            "Take a short break."
        case .longBreak:
            "Great work! Enjoy a long break."
        case .idle:
            ""
        }
    }
}
