import SwiftUI

struct PopoverContainerView: View {
    @Bindable var router: PopoverRouter
    let timer: PomodoroTimer
    let settings: SettingsStore
    let soundService: SoundService
    let onPanelChange: (PopoverPanel) -> Void

    var body: some View {
        Group {
            switch router.activePanel {
            case .timer:
                MenuBarView(
                    timer: timer,
                    onOpenSettings: { router.activePanel = .settings }
                )
            case .settings:
                SettingsView(
                    settings: settings,
                    soundService: soundService,
                    onBack: { router.activePanel = .timer }
                )
            }
        }
        .onChange(of: router.activePanel) { _, panel in
            onPanelChange(panel)
        }
    }
}
