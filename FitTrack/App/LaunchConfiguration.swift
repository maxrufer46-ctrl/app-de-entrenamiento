import Foundation

/// Test stores are isolated from personal data. Test overrides are absent from Release.
struct LaunchConfiguration {
    let storeLocation: CoreDataStack.StoreLocation
    let simulateFirstOpeningFailure: Bool
    let isUnitTesting: Bool

    static func current(processInfo: ProcessInfo = .processInfo) -> LaunchConfiguration {
        #if DEBUG
        let arguments = processInfo.arguments
        if arguments.contains("--ui-testing") {
            if let index = arguments.firstIndex(of: "--ui-test-store-id"),
                index + 1 < arguments.count,
                let identifier = UUID(uuidString: arguments[index + 1]) {
                let directory = FileManager.default.temporaryDirectory
                    .appendingPathComponent("FitTrackUITests", isDirectory: true)
                    .appendingPathComponent(identifier.uuidString, isDirectory: true)
                return LaunchConfiguration(
                    storeLocation: .sqlite(directory.appendingPathComponent("FitTrack.sqlite")),
                    simulateFirstOpeningFailure: arguments.contains("--ui-test-fail-first-open"),
                    isUnitTesting: false
                )
            }
            return LaunchConfiguration(
                storeLocation: .inMemory,
                simulateFirstOpeningFailure: false,
                isUnitTesting: false
            )
        }

        if processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return LaunchConfiguration(
                storeLocation: .inMemory,
                simulateFirstOpeningFailure: false,
                isUnitTesting: true
            )
        }
        #endif

        return LaunchConfiguration(
            storeLocation: .applicationSupport,
            simulateFirstOpeningFailure: false,
            isUnitTesting: false
        )
    }
}
