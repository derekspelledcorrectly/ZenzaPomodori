import Carbon
import SwiftUI

struct HotkeyRecorderView: NSViewRepresentable {
    @Binding var keyCode: UInt32
    @Binding var modifiers: UInt32

    func makeNSView(context: Context) -> HotkeyRecorderNSView {
        let view = HotkeyRecorderNSView()
        view.onKeyCaptured = { code, mods in
            keyCode = code
            modifiers = mods
        }
        view.keyCode = keyCode
        view.modifiers = modifiers
        return view
    }

    func updateNSView(_ nsView: HotkeyRecorderNSView, context: Context) {
        nsView.keyCode = keyCode
        nsView.modifiers = modifiers
        nsView.updateTitle()
    }
}

final class HotkeyRecorderNSView: NSView {
    var onKeyCaptured: ((UInt32, UInt32) -> Void)?
    var keyCode: UInt32 = 0
    var modifiers: UInt32 = 0
    private var isRecording = false
    private var monitor: Any?
    private let button = NSButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        button.bezelStyle = .rounded
        button.target = self
        button.action = #selector(toggleRecording)
        addSubview(button)
        updateTitle()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layout() {
        super.layout()
        button.frame = bounds
    }

    override var intrinsicContentSize: NSSize {
        NSSize(width: 120, height: 24)
    }

    @objc private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        isRecording = true
        button.title = "Press shortcut..."
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, self.isRecording else { return event }
            let carbonMods = self.nsModifiersToCarbonModifiers(event.modifierFlags)
            guard carbonMods != 0 else { return event }
            self.keyCode = UInt32(event.keyCode)
            self.modifiers = carbonMods
            self.onKeyCaptured?(self.keyCode, self.modifiers)
            self.stopRecording()
            return nil
        }
    }

    private func stopRecording() {
        isRecording = false
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
        updateTitle()
    }

    func updateTitle() {
        button.title = hotkeyDescription(keyCode: keyCode, modifiers: modifiers)
    }

    private func nsModifiersToCarbonModifiers(_ flags: NSEvent.ModifierFlags) -> UInt32 {
        var result: UInt32 = 0
        if flags.contains(.control) { result |= UInt32(controlKey) }
        if flags.contains(.shift) { result |= UInt32(shiftKey) }
        if flags.contains(.option) { result |= UInt32(optionKey) }
        if flags.contains(.command) { result |= UInt32(cmdKey) }
        return result
    }

    private static let specialKeyNames: [UInt32: String] = [
        36: "\u{21A9}",  // Return
        48: "\u{21E5}",  // Tab
        49: "\u{2423}",  // Space
        51: "\u{232B}",  // Delete
        53: "\u{238B}",  // Escape
        76: "\u{2324}",  // Enter (numpad)
        123: "\u{2190}", // Left arrow
        124: "\u{2192}", // Right arrow
        125: "\u{2193}", // Down arrow
        126: "\u{2191}", // Up arrow
    ]

    private func hotkeyDescription(keyCode: UInt32, modifiers: UInt32) -> String {
        var parts: [String] = []
        if modifiers & UInt32(controlKey) != 0 { parts.append("\u{2303}") }
        if modifiers & UInt32(shiftKey) != 0 { parts.append("\u{21E7}") }
        if modifiers & UInt32(optionKey) != 0 { parts.append("\u{2325}") }
        if modifiers & UInt32(cmdKey) != 0 { parts.append("\u{2318}") }

        if let special = Self.specialKeyNames[keyCode] {
            parts.append(special)
        } else if let inputSource = TISCopyCurrentKeyboardLayoutInputSource()?.takeRetainedValue(),
           let layoutPtr = TISGetInputSourceProperty(inputSource, kTISPropertyUnicodeKeyLayoutData) {
            let data = unsafeBitCast(layoutPtr, to: CFData.self) as Data
            var deadKeyState: UInt32 = 0
            var chars = [UniChar](repeating: 0, count: 4)
            var length: Int = 0
            data.withUnsafeBytes { rawBuffer in
                let ptr = rawBuffer.bindMemory(to: UCKeyboardLayout.self).baseAddress!
                UCKeyTranslate(ptr, UInt16(keyCode), UInt16(kUCKeyActionDisplay),
                               0, UInt32(LMGetKbdType()),
                               UInt32(kUCKeyTranslateNoDeadKeysMask),
                               &deadKeyState, chars.count, &length, &chars)
            }
            if length > 0 {
                parts.append(String(utf16CodeUnits: chars, count: length).uppercased())
            }
        }

        return parts.isEmpty ? "Click to set" : parts.joined()
    }
}
