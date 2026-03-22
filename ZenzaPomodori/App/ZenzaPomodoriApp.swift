import AppKit
import SwiftUI

@main
@MainActor
struct ZenzaPomodoriApp {
    static let settings = SettingsStore()
    static let focusNameStore = FocusNameStore()
    static let timer = PomodoroTimer(settings: settings, focusNameStore: focusNameStore)
    static let popoverManager = PopoverManager(timer: timer, settings: settings)

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate(popoverManager: popoverManager)
        app.delegate = delegate
        app.run()
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let popoverManager: PopoverManager

    init(popoverManager: PopoverManager) {
        self.popoverManager = popoverManager
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        popoverManager.setup()
    }
}

@MainActor
final class PopoverManager: NSObject, NSPopoverDelegate {
    let timer: PomodoroTimer
    private let settings: SettingsStore
    private var statusItem: NSStatusItem?
    private let popover = NSPopover()
    private let notificationService: NotificationService
    private let soundService = SoundService()
    private let settingsWindowManager: SettingsWindowManager
    private var autoDismissTask: Task<Void, Never>?
    private var clickMonitor: Any?

    init(timer: PomodoroTimer, settings: SettingsStore) {
        self.timer = timer
        self.settings = settings
        self.notificationService = NotificationService(settings: settings)
        self.settingsWindowManager = SettingsWindowManager(settings: settings, soundService: soundService)
        super.init()
        popover.delegate = self
    }

    func setup() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem = item

        popover.contentViewController = NSHostingController(
            rootView: MenuBarView(timer: timer)
        )
        popover.behavior = .transient

        if let button = item.button {
            button.target = self
            button.action = #selector(handleStatusItemClick)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            updateStatusItem()
        }

        item.menu = nil

        setupNotifications()
        startObservingTimer()
    }

    private func setupNotifications() {
        notificationService.onNotificationTapped = { [weak self] in
            self?.showPopover()
        }
        timer.onTimerComplete = { [weak self] phase in
            guard let self else { return }
            if self.settings.soundEnabled {
                self.soundService.play(self.settings.selectedSound)
            }
            if self.settings.popOnComplete {
                self.showPopover()
                self.startAutoDismissTimer()
            }
            self.notificationService.sendCompletionNotification(for: phase)
        }
    }

    func showPopover() {
        guard let button = statusItem?.button else { return }
        if !popover.isShown {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
        NSApp.activate()
    }

    @objc private func handleStatusItemClick() {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            popover.performClose(nil)
            showContextMenu()
        } else {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                showPopover()
            }
        }
    }

    private func showContextMenu() {
        let menu = NSMenu()
        menu.autoenablesItems = false

        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    @objc private func openSettings() {
        settingsWindowManager.showSettings(anchorTo: statusItem?.button)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    private func updateStatusItem() {
        guard let button = statusItem?.button else { return }

        let iconName: String
        switch timer.phase {
        case .idle: iconName = "timer"
        case .focus: iconName = "circle.fill"
        case .shortBreak, .longBreak: iconName = "leaf.fill"
        }

        button.image = NSImage(systemSymbolName: iconName, accessibilityDescription: nil)

        let title = NSMutableAttributedString()

        if timer.settings.showTimerInMenuBar {
            let monoFont = NSFont.monospacedDigitSystemFont(
                ofSize: NSFont.systemFontSize, weight: .regular
            )
            title.append(NSAttributedString(
                string: " \(timer.formattedTime)",
                attributes: [.font: monoFont]
            ))
        }

        if timer.settings.showFocusInMenuBar,
           let name = timer.activeFocusName,
           !name.isEmpty {
            let truncated = MenuBarFormatting.truncatedFocusName(name)
            let sysFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
            title.append(NSAttributedString(
                string: " \(truncated)",
                attributes: [.font: sysFont]
            ))
        }

        button.attributedTitle = title
    }

    // MARK: - Auto-Dismiss

    private func startAutoDismissTimer() {
        cancelAutoDismissTimer()
        let seconds = settings.autoDismissSeconds
        guard seconds > 0 else { return }
        installClickMonitor()
        autoDismissTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(seconds))
            guard !Task.isCancelled else { return }
            self?.handleAutoDismiss()
        }
    }

    private func cancelAutoDismissTimer() {
        autoDismissTask?.cancel()
        autoDismissTask = nil
        removeClickMonitor()
    }

    private func handleAutoDismiss() {
        removeClickMonitor()
        popover.performClose(nil)
        if settings.autoAdvance, timer.isOvertime {
            timer.next()
        }
    }

    nonisolated func popoverDidClose(_ notification: Notification) {
        MainActor.assumeIsolated {
            cancelAutoDismissTimer()
        }
    }

    private func installClickMonitor() {
        guard clickMonitor == nil else { return }
        clickMonitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            if let self, let window = self.popover.contentViewController?.view.window,
               event.window == window {
                self.cancelAutoDismissTimer()
            }
            return event
        }
    }

    private func removeClickMonitor() {
        if let monitor = clickMonitor {
            NSEvent.removeMonitor(monitor)
            clickMonitor = nil
        }
    }

    // MARK: - Timer Observation

    private func startObservingTimer() {
        Task { @MainActor [weak self] in
            while let self {
                withObservationTracking {
                    self.updateStatusItem()
                } onChange: {
                    Task { @MainActor [weak self] in
                        self?.updateStatusItem()
                    }
                }
                try? await Task.sleep(for: .milliseconds(100))
            }
        }
    }
}
