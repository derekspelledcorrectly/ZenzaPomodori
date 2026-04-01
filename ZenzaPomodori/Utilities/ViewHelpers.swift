import SwiftUI

/// Creates an invisible button that responds to a keyboard shortcut.
/// Used to bind shortcuts without visible UI elements.
func hiddenShortcut(
    _ key: KeyEquivalent,
    modifiers: EventModifiers = [],
    action: @escaping () -> Void
) -> some View {
    Button(action: action) { EmptyView() }
        .keyboardShortcut(key, modifiers: modifiers)
        .frame(width: 0, height: 0)
        .opacity(0)
}
