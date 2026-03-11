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

    func sendOvertimeNotification(for phase: TimerPhase) {
        guard isAuthorized else { return }
        guard phase != .idle else { return }

        let content = UNMutableNotificationContent()
        content.title = "\(phase.label(totalBlocks: Defaults.blocksBeforeLongBreak)) Complete"
        content.body = overtimeBody(for: phase)
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "overtime-\(UUID().uuidString)",
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

    private func overtimeBody(for phase: TimerPhase) -> String {
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
