import SwiftUI

@main
struct ZenzaPomodoriApp: App {
    @State private var timer = PomodoroTimer()

    var body: some Scene {
        MenuBarExtra(menuBarTitle, systemImage: menuBarIcon) {
            MenuBarView(timer: timer)
        }
        .menuBarExtraStyle(.window)
    }

    private var menuBarTitle: String {
        timer.phase == .idle ? "Zenza Pomodori" : timer.formattedTime
    }

    private var menuBarIcon: String {
        switch timer.phase {
        case .idle: "timer"
        case .focus: "circle.fill"
        case .shortBreak, .longBreak: "leaf.fill"
        }
    }
}
