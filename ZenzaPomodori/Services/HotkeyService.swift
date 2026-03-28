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
    private var rotationHotkeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private var notificationObserver: Any?
    private var rotationNotificationObserver: Any?

    var onHotkeyPressed: (() -> Void)?
    var onRotationHotkeyPressed: (() -> Void)?

    init(settings: SettingsStore) {
        self.settings = settings
    }

    func register() {
        unregister()
        registrationError = nil

        guard installHandlerIfNeeded() else { return }

        if settings.globalHotkeyEnabled {
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
                registrationError = "Hotkey registration failed (status \(status)). "
                    + "Check System Settings > Privacy & Security > Accessibility."
            }
        }

        if settings.rotationHotkeyEnabled {
            var rotKeyID = EventHotKeyID()
            rotKeyID.signature = OSType(0x5A50_4D42) // "ZPMB"
            rotKeyID.id = 2

            var ref: EventHotKeyRef?
            let status = RegisterEventHotKey(
                settings.rotationHotkeyKeyCode,
                settings.rotationHotkeyModifiers,
                rotKeyID,
                GetEventDispatcherTarget(),
                0,
                &ref
            )

            if status == noErr, let ref {
                rotationHotkeyRef = ref
            }
        }
    }

    func unregister() {
        if let ref = hotkeyRef {
            UnregisterEventHotKey(ref)
            hotkeyRef = nil
        }
        if let ref = rotationHotkeyRef {
            UnregisterEventHotKey(ref)
            rotationHotkeyRef = nil
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

        if let existing = rotationNotificationObserver {
            NotificationCenter.default.removeObserver(existing)
        }
        rotationNotificationObserver = NotificationCenter.default.addObserver(
            forName: .rotationHotkeyPressed,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.onRotationHotkeyPressed?()
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
                    let name: Notification.Name = hotKeyID.id == 2
                        ? .rotationHotkeyPressed : .hotkeyPressed
                    NotificationCenter.default.post(name: name, object: nil)
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
    static let rotationHotkeyPressed = Notification.Name("ZenzaPomodoriRotationHotkeyPressed")
}
