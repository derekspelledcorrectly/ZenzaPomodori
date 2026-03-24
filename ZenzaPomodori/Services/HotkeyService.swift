import Carbon
import Foundation
import Observation

@Observable
@MainActor
final class HotkeyService {
    let settings: SettingsStore

    private(set) var isRegistered: Bool = false
    private(set) var registrationError: String?
    private var hotkeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private var notificationObserver: Any?

    var onHotkeyPressed: (() -> Void)?

    init(settings: SettingsStore) {
        self.settings = settings
    }

    func register() {
        unregister()
        registrationError = nil
        guard settings.globalHotkeyEnabled else { return }

        guard installHandlerIfNeeded() else { return }

        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0x5A50_4D42) // "ZPMB"
        hotKeyID.id = 1

        var ref: EventHotKeyRef?
        let status = RegisterEventHotKey(
            settings.globalHotkeyKeyCode,
            settings.globalHotkeyModifiers,
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &ref
        )

        if status == noErr, let ref {
            hotkeyRef = ref
            isRegistered = true
        } else {
            isRegistered = false
            registrationError = "Hotkey registration failed (status \(status)). "
                + "Check System Settings > Privacy & Security > Accessibility."
        }
    }

    func unregister() {
        if let ref = hotkeyRef {
            UnregisterEventHotKey(ref)
            hotkeyRef = nil
        }
        isRegistered = false
    }

    func startListening() {
        if let existing = notificationObserver {
            NotificationCenter.default.removeObserver(existing)
        }
        notificationObserver = NotificationCenter.default.addObserver(
            forName: .hotkeyPressed,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.onHotkeyPressed?()
            }
        }
    }

    // MARK: - Private

    /// Install the Carbon event handler once. Subsequent register/unregister
    /// cycles only add/remove the hotkey ref, not the handler.
    @discardableResult
    private func installHandlerIfNeeded() -> Bool {
        guard eventHandlerRef == nil else { return true }

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        var handlerRef: EventHandlerRef?
        let status = InstallEventHandler(
            GetEventDispatcherTarget(),
            { _, event, _ -> OSStatus in
                guard let event else { return OSStatus(eventNotHandledErr) }
                var hotKeyID = EventHotKeyID()
                GetEventParameter(
                    event,
                    UInt32(kEventParamDirectObject),
                    UInt32(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                if hotKeyID.signature == OSType(0x5A50_4D42) {
                    NotificationCenter.default.post(
                        name: .hotkeyPressed,
                        object: nil
                    )
                }
                return noErr
            },
            1,
            &eventType,
            nil,
            &handlerRef
        )

        if status == noErr {
            eventHandlerRef = handlerRef
            return true
        } else {
            registrationError = "Could not install hotkey handler (status \(status))."
            return false
        }
    }
}

extension Notification.Name {
    static let hotkeyPressed = Notification.Name("ZenzaPomodoriHotkeyPressed")
}
