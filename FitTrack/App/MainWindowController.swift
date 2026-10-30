import AppKit
import SwiftUI

final class MainWindowController: NSWindowController, NSWindowDelegate {
    private let requestQuit: () -> Void

    init(viewModel: BootstrapViewModel, requestQuit: @escaping () -> Void, revealData: @escaping () -> Void) {
        self.requestQuit = requestQuit
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 660),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "FitTrack"
        window.minSize = NSSize(width: 680, height: 540)
        window.isReleasedWhenClosed = false
        window.center()
        _ = window.setFrameAutosaveName("FitTrack.MainWindow")
        window.collectionBehavior.insert(.fullScreenPrimary)
        window.contentView = NSHostingView(rootView: BootstrapView(viewModel: viewModel, revealData: revealData))
        super.init(window: window)
        window.delegate = self
    }

    required init?(coder: NSCoder) {
        return nil
    }

    /// Keep the window available while AppDelegate saves or presents a recoverable error.
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        requestQuit()
        return false
    }
}
