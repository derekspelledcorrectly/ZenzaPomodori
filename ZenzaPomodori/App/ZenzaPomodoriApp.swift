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
    private let router = PopoverRouter()
    private var autoDismissTask: Task<Void, Never>?
    private var clickMonitor: Any?
    private let rotationStore = RotationStore()
    private let hotkeyService: HotkeyService

    init(timer: PomodoroTimer, settings: SettingsStore) {
        self.timer = timer
        self.settings = settings
        self.notificationService = NotificationService(settings: settings)
        self.hotkeyService = HotkeyService(settings: settings)
        super.init()
        popover.delegate = self
    }

    func setup() {
        settings.lastBlockType = .regular
        installEditMenu()

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem = item

        popover.contentViewController = NSHostingController(
            rootView: PopoverContainerView(
                router: router,
                timer: timer,
                settings: settings,
                soundService: soundService,
                onPanelChange: { [weak self] panel in
                    self?.handlePanelChange(panel)
                },
                rotationStore: rotationStore,
                focusNameStore: timer.focusNameStore,
                onMicroBlockStart: { [weak self] items in
                    self?.startMicroBlocks(with: items)
                }
            )
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
        setupHotkey()
        startObservingTimer()
    }

    private func setupNotifications() {
        if settings.notificationsEnabled {
            notificationService.requestPermission()
        }
        settings.onNotificationsEnabled = { [weak self] in
            self?.notificationService.requestPermission()
        }
        notificationService.onNotificationTapped = { [weak self] in
            self?.showPopover(activate: true)
        }
        timer.onPhaseChange = { [weak self] _, newPhase in
            guard let self else { return }
            if !newPhase.isFocus {
                self.router.microBlockEngine?.deactivate()
                self.router.microBlockEngine = nil
            }
        }
        timer.onTimerComplete = { [weak self] phase in
            guard let self else { return }
            if self.settings.soundEnabled {
                let sound = phase.isFocus
                    ? self.settings.focusEndSound
                    : self.settings.breakEndSound
                self.soundService.play(sound)
            }
            if self.settings.popOnComplete {
                self.showPopover()
                self.startAutoDismissTimer()
            }
            self.notificationService.sendCompletionNotification(for: phase)
        }
    }

    func showPopover(activate: Bool = false) {
        guard let button = statusItem?.button else { return }
        if !popover.isShown {
            // Sync contentSize to actual view size before showing,
            // otherwise NSPopover uses a stale cached size for positioning.
            if let fittingSize = popover.contentViewController?.view.fittingSize,
               fittingSize.width > 0, fittingSize.height > 0 {
                popover.contentSize = fittingSize
            }
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            DispatchQueue.main.async { [weak self] in
                self?.focusDefaultButton()
            }
        }
        if activate {
            NSApp.activate()
        }
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
                showPopover(activate: true)
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
        router.activePanel = .settings
        showPopover(activate: true)
    }

    private func handlePanelChange(_ panel: PopoverPanel) {
        popover.behavior = panel == .settings ? .applicationDefined : .transient

        DispatchQueue.main.async { [weak self] in
            guard let self,
                  let contentView = self.popover.contentViewController?.view,
                  let window = contentView.window else { return }
            window.recalculateKeyViewLoop()
            switch panel {
            case .timer:
                if self.timer.phase == .idle,
                   let textField = self.firstTextField(in: contentView) {
                    window.makeFirstResponder(textField)
                    textField.selectText(nil)
                } else if let button = self.firstBorderedButton(in: contentView) {
                    window.makeFirstResponder(button)
                }
            case .settings:
                if let picker = self.firstPopUpButton(in: contentView) {
                    window.makeFirstResponder(picker)
                }
            case .microBlockSetup, .microBlockActive, .microBlockTransition:
                if let button = self.firstBorderedButton(in: contentView) {
                    window.makeFirstResponder(button)
                }
            }
        }
    }

    private func focusDefaultButton() {
        guard let contentView = popover.contentViewController?.view,
              let window = contentView.window else { return }
        window.autorecalculatesKeyViewLoop = true
        window.recalculateKeyViewLoop()
        if timer.phase == .idle, let textField = firstTextField(in: contentView) {
            window.makeFirstResponder(textField)
            textField.selectText(nil)
        } else if let button = firstBorderedButton(in: contentView) {
            window.makeFirstResponder(button)
        }
    }

    private func firstBorderedButton(in view: NSView) -> NSButton? {
        if let button = view as? NSButton, button.isBordered {
            return button
        }
        for subview in view.subviews {
            if let found = firstBorderedButton(in: subview) {
                return found
            }
        }
        return nil
    }

    private func firstTextField(in view: NSView) -> NSTextField? {
        if let field = view as? NSTextField, field.isEditable {
            return field
        }
        for subview in view.subviews {
            if let found = firstTextField(in: subview) {
                return found
            }
        }
        return nil
    }

    private func firstPopUpButton(in view: NSView) -> NSPopUpButton? {
        if let popup = view as? NSPopUpButton {
            return popup
        }
        for subview in view.subviews {
            if let found = firstPopUpButton(in: subview) {
                return found
            }
        }
        return nil
    }

    private func installEditMenu() {
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editMenu.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")

        let editMenuItem = NSMenuItem(title: "Edit", action: nil, keyEquivalent: "")
        editMenuItem.submenu = editMenu

        let mainMenu = NSApp.mainMenu ?? NSMenu()
        mainMenu.addItem(editMenuItem)
        NSApp.mainMenu = mainMenu
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

        if let engine = router.microBlockEngine, engine.isActive {
            let formatted = MenuBarFormatting.microBlockFormatted(
                microSeconds: engine.microSecondsRemaining,
                outerFormattedTime: timer.formattedTime,
                focusName: engine.currentItemName,
                position: engine.currentIndex + 1,
                total: engine.rotationItems.count,
                format: settings.microBlockMenuBarFormat,
                showTimer: settings.showTimerInMenuBar,
                showFocus: settings.showFocusInMenuBar
            )
            if !formatted.isEmpty {
                let monoFont = NSFont.monospacedDigitSystemFont(
                    ofSize: NSFont.systemFontSize, weight: .regular
                )
                title.append(NSAttributedString(
                    string: " \(formatted)",
                    attributes: [.font: monoFont]
                ))
            }
        } else {
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
               timer.phase.isFocus,
               let name = timer.activeFocusName,
               !name.isEmpty {
                let truncated = MenuBarFormatting.truncatedFocusName(name)
                let sysFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
                title.append(NSAttributedString(
                    string: " \(truncated)",
                    attributes: [.font: sysFont]
                ))
            }
        }

        button.attributedTitle = title
    }

    // MARK: - MicroBlocks

    private func startMicroBlocks(with items: [RotationItem]) {
        let engine = MicroBlockEngine(
            items: items,
            interval: settings.microRotationInterval
        )
        engine.onRotationComplete = { [weak self] in
            self?.handleMicroRotation()
        }
        router.microBlockEngine = engine
        settings.lastBlockType = .microBlocks
        timer.start()
        engine.activate()
        router.activePanel = .microBlockActive
    }

    private func handleMicroRotation() {
        guard router.microBlockEngine != nil else { return }

        if settings.microBlockSoundEnabled {
            soundService.play(settings.microBlockEndSound)
        }

        router.activePanel = .microBlockTransition
        showPopover()

        if settings.stealFocusOnRotation {
            NSApp.activate()
        }

        startAutoDismissTimer()
    }

    // MARK: - Global Hotkey

    private func setupHotkey() {
        hotkeyService.onHotkeyPressed = { [weak self] in
            self?.handleHotkey()
        }
        hotkeyService.startListening()
        hotkeyService.register()
        settings.onHotkeySettingsChanged = { [weak self] in
            self?.hotkeyService.register()
        }
    }

    private func handleHotkey() {
        if let engine = router.microBlockEngine, engine.isActive {
            if router.activePanel == .microBlockTransition {
                engine.skip()
                router.activePanel = .microBlockActive
            } else {
                router.activePanel = .microBlockTransition
                showPopover(activate: true)
            }
        } else {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                showPopover(activate: true)
            }
        }
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
        if router.activePanel == .microBlockTransition {
            router.activePanel = .microBlockActive
            popover.performClose(nil)
            return
        }
        guard router.activePanel == .timer else { return }
        popover.performClose(nil)
        if settings.autoAdvance, timer.isOvertime {
            timer.next()
        }
    }

    nonisolated func popoverDidClose(_ notification: Notification) {
        MainActor.assumeIsolated {
            cancelAutoDismissTimer()
            switch router.activePanel {
            case .microBlockActive, .microBlockTransition, .microBlockSetup:
                popover.behavior = .transient
            case .timer:
                break
            case .settings:
                router.activePanel = .timer
                popover.behavior = .transient
            }
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
                self.updateStatusItem()
                try? await Task.sleep(for: .milliseconds(100))
            }
        }
    }
}
