import AppKit
import SwiftUI

@main
@MainActor
struct ZenzaPomodoriApp {
    static let timer = PomodoroTimer()
    static let popoverManager = PopoverManager(timer: timer)

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
final class PopoverManager {
    let timer: PomodoroTimer
    private var statusItem: NSStatusItem?
    private let popover = NSPopover()

    init(timer: PomodoroTimer) {
        self.timer = timer
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
            button.action = #selector(togglePopover)
            updateStatusItem()
        }

        startObservingTimer()
    }

    func showPopover() {
        guard let button = statusItem?.button else { return }
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        NSApp.activate()
    }

    @objc private func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            showPopover()
        }
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

        if timer.phase == .idle {
            button.attributedTitle = NSAttributedString()
        } else {
            let font = NSFont.monospacedDigitSystemFont(
                ofSize: NSFont.systemFontSize, weight: .regular
            )
            button.attributedTitle = NSAttributedString(
                string: " \(timer.formattedTime)",
                attributes: [.font: font]
            )
        }
    }

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
