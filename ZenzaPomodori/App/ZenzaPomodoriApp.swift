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
final class PopoverManager: NSObject {
    let timer: PomodoroTimer
    private let settings: SettingsStore
    private var statusItem: NSStatusItem?
    private let panel = FloatingPanel()
    private var hostingView: NSHostingView<PopoverContainerView>?
    private var localDismissMonitor: Any?
    private var globalDismissMonitor: Any?
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
        panel.onClose = { [weak self] in
            self?.hidePanel()
        }
    }

    func setup() {
        settings.lastBlockType = .focus
        installEditMenu()

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem = item

        let contentView = PopoverContainerView(
            router: router,
            timer: timer,
            settings: settings,
            soundService: soundService,
            onPanelChange: { [weak self] panel in
                self?.handlePanelChange(panel)
            },
            rotationStore: rotationStore,
            focusNameStore: timer.focusNameStore,
            onSliceStart: { [weak self] items in
                self?.startSlices(with: items)
            }
        )
        let hosting = NSHostingView(rootView: contentView)
        hostingView = hosting
        panel.contentView = hosting

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
            self?.showPanel(activate: true)
        }
        timer.onPhaseChange = { [weak self] _, newPhase in
            guard let self else { return }
            if !newPhase.isFocus {
                self.router.sliceEngine?.deactivate()
                self.router.sliceEngine = nil
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
                self.showPanel()
                self.startAutoDismissTimer()
            }
            self.notificationService.sendCompletionNotification(for: phase)
        }
    }

    func showPanel(activate: Bool = false) {
        guard let button = statusItem?.button,
              let buttonWindow = button.window else { return }

        if !panel.isVisible {
            let buttonRect = buttonWindow.convertToScreen(
                button.convert(button.bounds, to: nil)
            )

            if let hosting = hostingView {
                let fittingSize = hosting.fittingSize
                if fittingSize.width > 0, fittingSize.height > 0 {
                    panel.setContentSize(fittingSize)
                }
            }

            let panelSize = panel.frame.size
            let x = buttonRect.maxX - panelSize.width
            let y = buttonRect.minY - 6 - panelSize.height

            panel.setFrameOrigin(NSPoint(x: x, y: y))
            panel.orderFront(nil)
            installDismissMonitors()

            DispatchQueue.main.async { [weak self] in
                self?.focusDefaultButton()
            }
        }

        if activate {
            NSApp.activate()
            panel.makeKey()
        }
    }

    func hidePanel() {
        panel.orderOut(nil)
        removeDismissMonitors()
        handlePanelClose()
    }

    private func handlePanelClose() {
        cancelAutoDismissTimer()
        if router.activePanel == .settings {
            router.activePanel = .timer
        }
    }

    private func repositionPanel() {
        guard let button = statusItem?.button,
              let buttonWindow = button.window else { return }
        let buttonRect = buttonWindow.convertToScreen(
            button.convert(button.bounds, to: nil)
        )
        let panelSize = panel.frame.size
        let x = buttonRect.maxX - panelSize.width
        let y = buttonRect.minY - 6 - panelSize.height
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    @objc private func handleStatusItemClick() {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            hidePanel()
            showContextMenu()
        } else {
            if panel.isVisible {
                hidePanel()
            } else {
                showPanel(activate: true)
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
        showPanel(activate: true)
    }

    private func handlePanelChange(_ popoverPanel: PopoverPanel) {
        DispatchQueue.main.async { [weak self] in
            guard let self,
                  let contentView = self.hostingView else { return }
            self.panel.recalculateKeyViewLoop()
            switch popoverPanel {
            case .timer:
                if self.timer.phase == .idle,
                   let textField = self.firstTextField(in: contentView) {
                    self.panel.makeFirstResponder(textField)
                    textField.selectText(nil)
                } else if let button = self.firstBorderedButton(in: contentView) {
                    self.panel.makeFirstResponder(button)
                }
            case .settings:
                if let picker = self.firstPopUpButton(in: contentView) {
                    self.panel.makeFirstResponder(picker)
                }
            case .sliceSetup, .sliceActive:
                if let button = self.firstBorderedButton(in: contentView) {
                    self.panel.makeFirstResponder(button)
                }
            }

            let fittingSize = contentView.fittingSize
            if fittingSize.width > 0, fittingSize.height > 0 {
                self.panel.setContentSize(fittingSize)
                self.repositionPanel()
            }
        }
    }

    private func focusDefaultButton() {
        guard let contentView = hostingView else { return }
        panel.autorecalculatesKeyViewLoop = true
        panel.recalculateKeyViewLoop()
        if timer.phase == .idle, let textField = firstTextField(in: contentView) {
            panel.makeFirstResponder(textField)
            textField.selectText(nil)
        } else if let button = firstBorderedButton(in: contentView) {
            panel.makeFirstResponder(button)
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

        if let engine = router.sliceEngine, engine.isActive {
            let formatted = MenuBarFormatting.sliceFormatted(
                sliceSeconds: engine.sliceSecondsRemaining,
                outerFormattedTime: timer.formattedTime,
                focusName: engine.currentItemName,
                position: engine.currentIndex + 1,
                total: engine.rotationItems.count,
                format: settings.sliceMenuBarFormat,
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

    // MARK: - Slices

    private func startSlices(with items: [RotationItem]) {
        let engine = SliceEngine(
            items: items,
            interval: settings.sliceRotationInterval
        )
        engine.onRotationComplete = { [weak self] in
            self?.handleSliceRotation()
        }
        router.sliceEngine = engine
        settings.lastBlockType = .slices
        timer.start()
        engine.activate()
        router.activePanel = .sliceActive
    }

    private func handleSliceRotation() {
        guard router.sliceEngine != nil else { return }

        if settings.sliceSoundEnabled {
            soundService.play(settings.sliceEndSound)
        }

        router.activePanel = .sliceActive
        showPanel(activate: settings.stealFocusOnRotation)

        startAutoDismissTimer()
    }

    // MARK: - Global Hotkey

    private func setupHotkey() {
        hotkeyService.onHotkeyPressed = { [weak self] in
            self?.handleHotkey()
        }
        hotkeyService.onRotationHotkeyPressed = { [weak self] in
            self?.handleRotationHotkey()
        }
        hotkeyService.startListening()
        hotkeyService.register()
        settings.onHotkeySettingsChanged = { [weak self] in
            self?.hotkeyService.register()
        }
    }

    private func handleRotationHotkey() {
        guard let engine = router.sliceEngine, engine.isActive else { return }
        engine.skip()
    }

    private func handleHotkey() {
        if panel.isVisible {
            hidePanel()
        } else {
            showPanel(activate: true)
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
        if router.activePanel == .sliceActive {
            hidePanel()
            return
        }
        guard router.activePanel == .timer else { return }
        hidePanel()
        if settings.autoAdvance, timer.isOvertime {
            timer.next()
        }
    }

    // MARK: - Dismiss Monitors

    private func installDismissMonitors() {
        removeDismissMonitors()

        globalDismissMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self else { return }
                if self.router.activePanel != .settings {
                    self.hidePanel()
                }
            }
        }

        localDismissMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] event in
            DispatchQueue.main.async {
                guard let self else { return }
                if event.window !== self.panel,
                   event.window !== self.statusItem?.button?.window {
                    if self.router.activePanel != .settings {
                        self.hidePanel()
                    }
                }
            }
            return event
        }
    }

    private func removeDismissMonitors() {
        if let monitor = globalDismissMonitor {
            NSEvent.removeMonitor(monitor)
            globalDismissMonitor = nil
        }
        if let monitor = localDismissMonitor {
            NSEvent.removeMonitor(monitor)
            localDismissMonitor = nil
        }
    }

    private func installClickMonitor() {
        guard clickMonitor == nil else { return }
        clickMonitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            DispatchQueue.main.async {
                guard let self else { return }
                if event.window === self.panel {
                    self.cancelAutoDismissTimer()
                }
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
