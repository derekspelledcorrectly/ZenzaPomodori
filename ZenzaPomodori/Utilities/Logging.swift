import Foundation
import os

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.giantshenanigans.ZenzaPomodori"

    static let services = Logger(subsystem: subsystem, category: "services")
    static let storage = Logger(subsystem: subsystem, category: "storage")
}
