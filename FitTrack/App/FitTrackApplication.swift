import AppKit

/// AppKit lifecycle with a Swift 5.3 entry point. This file must not be named main.swift.
@main
struct FitTrackApplication {
    static func main() {
        let application = NSApplication.shared
        let delegate = AppDelegate()
        _ = application.setActivationPolicy(.regular)
        application.delegate = delegate
        withExtendedLifetime(delegate) {
            application.run()
        }
    }
}
