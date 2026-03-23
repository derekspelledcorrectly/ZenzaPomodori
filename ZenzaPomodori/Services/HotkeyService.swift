import Carbon
import Foundation
import Observation

@Observable
@MainActor
final class HotkeyService {
    let settings: SettingsStore

    private(set) var isRegistered: Bool = false
    private var hotkeyRef: EventHotKeyRef?

    var onHotkeyPressed: (() -> Void)?

    init(settings: SettingsStore) {
        self.settings = settings
    }

    func register() {
        unregister()
        guard settings.globalHotkeyEnabled else { return }

        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0x5A50_4D42) // "ZPMB"
        hotKeyID.id = 1

        let modifiers = settings.globalHotkeyModifiers
        let keyCode = settings.globalHotkeyKeyCode

        var ref: EventHotKeyRef?
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &ref
        )

        if status == noErr, let ref {
            hotkeyRef = ref
            isRegistered = true
            installHandler()
        }
    }

    func unregister() {
        if let ref = hotkeyRef {
            UnregisterEventHotKey(ref)
            hotkeyRef = nil
        }
        isRegistered = false
    }

    private func installHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
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
            nil
        )
    }

    func startListening() {
        NotificationCenter.default.addObserver(
            forName: .hotkeyPressed,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.onHotkeyPressed?()
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension Notification.Name {
    static let hotkeyPressed = Notification.Name("ZenzaPomodoriHotkeyPressed")
}
