import SwiftUI

struct AboutView: View {
    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    }

    private var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 24)

            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 96, height: 96)

            Text("Zenza Pomodori")
                .font(.system(size: 20, weight: .semibold))
                .padding(.top, 12)

            Text("Version \(version) (\(build))")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .padding(.top, 2)

            Text("Human focus for the agentic era.")
                .font(.system(size: 13).italic())
                .foregroundStyle(.secondary)
                .padding(.top, 8)

            acknowledgements
                .padding(.top, 16)

            VStack(spacing: 2) {
                Text("Built with focus by Derek Shockey")
                Text("© 2026 Giant Shenanigans LLC")
                Text("Licensed under GPL-3.0")
            }
            .font(.system(size: 11))
            .foregroundStyle(.tertiary)
            .padding(.top, 16)

            Spacer().frame(height: 24)
        }
        .frame(width: 300)
        .padding(.horizontal, 24)
    }

    private var acknowledgements: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Acknowledgements")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            Text("Made with ") + linkText("Claude", url: "https://claude.ai") + Text(" by Anthropic")

            Text("Thanks to ") + linkText("akx/Notifications", url: "https://github.com/akx/Notifications") + Text(" for the sounds")

            Text("Thanks to Francesco Cirillo for inventing the Pomodoro Technique")
        }
        .font(.system(size: 11))
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.quaternary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func linkText(_ text: String, url: String) -> Text {
        Text(.init("[\(text)](\(url))"))
    }
}
