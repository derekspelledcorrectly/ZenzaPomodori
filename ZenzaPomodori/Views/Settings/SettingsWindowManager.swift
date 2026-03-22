import AppKit
import SwiftUI

@MainActor
final class SettingsWindowManager {
    private let settings: SettingsStore
    private let soundService: SoundService
    private var window: NSWindow?

    init(settings: SettingsStore, soundService: SoundService) {
        self.settings = settings
        self.soundService = soundService
    }

    var isWindowVisible: Bool {
        window?.isVisible ?? false
    }

    func showSettings(anchorTo button: NSStatusBarButton? = nil) {
        if let window, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate()
            return
        }

        let hostingController = NSHostingController(
            rootView: SettingsView(settings: settings, soundService: soundService)
        )

        let window = NSWindow(contentViewController: hostingController)
        window.isReleasedWhenClosed = false
        window.title = "Settings"
        window.styleMask = [.titled, .closable]

        if let button, let buttonWindow = button.window {
            let buttonRect = button.convert(button.bounds, to: nil)
            let screenRect = buttonWindow.convertToScreen(buttonRect)
            let windowSize = window.frame.size
            let x = screenRect.midX - windowSize.width / 2
            let y = screenRect.minY - windowSize.height
            window.setFrameOrigin(NSPoint(x: x, y: y))
        } else {
            window.center()
        }

        window.makeKeyAndOrderFront(nil)
        NSApp.activate()
        self.window = window
    }
}
