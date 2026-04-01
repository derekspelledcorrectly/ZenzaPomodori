import os

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "dev.derekspelledcorrectly.ZenzaPomodori"

    static let services = Logger(subsystem: subsystem, category: "services")
    static let storage = Logger(subsystem: subsystem, category: "storage")
}
