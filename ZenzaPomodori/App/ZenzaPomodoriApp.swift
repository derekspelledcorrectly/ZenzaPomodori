import SwiftUI

@main
struct ZenzaPomodoriApp: App {
    var body: some Scene {
        MenuBarExtra("Zenza Pomodori", systemImage: "timer") {
            Text("Zenza Pomodori")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 8)

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
            .padding(.bottom, 4)
        }
        .menuBarExtraStyle(.window)
    }
}
