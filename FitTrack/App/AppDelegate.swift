import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuItemValidation {
    private var container: AppContainer?
    private var mainWindowController: MainWindowController?
    private var isPreparingToQuit = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        let configuration = LaunchConfiguration.current()
        let container = AppContainer(configuration: configuration)
        self.container = container
        NSApp.mainMenu = MenuBuilder.build(target: self)

        let controller = MainWindowController(
            viewModel: container.bootstrapViewModel,
            requestQuit: { NSApp.terminate(nil) },
            revealData: { [weak self] in self?.revealDataDirectory() }
        )
        mainWindowController = controller
        if !configuration.isUnitTesting {
            controller.showWindow(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
        container.bootstrapViewModel.start()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag { mainWindowController?.showWindow(nil) }
        return true
    }

    @objc func saveProfile(_ sender: Any?) {
        if let window = mainWindowController?.window, !window.makeFirstResponder(nil) { return }
        guard let viewModel = container?.bootstrapViewModel, viewModel.canSave else { return }
        viewModel.save()
    }

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(saveProfile(_:)) {
            return container?.bootstrapViewModel.canSave ?? false
        }
        return true
    }

    // MARK: - Safe termination

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if isPreparingToQuit { return .terminateLater }
        if let window = mainWindowController?.window, !window.makeFirstResponder(nil) { return .terminateCancel }
        guard let container = container, container.hasPendingChanges else { return .terminateNow }
        isPreparingToQuit = true
        saveBeforeQuitting(application: sender)
        return .terminateLater
    }

    private func saveBeforeQuitting(application: NSApplication) {
        // Always defer the reply until applicationShouldTerminate has returned terminateLater.
        DispatchQueue.main.async {
            guard let container = self.container else {
                application.reply(toApplicationShouldTerminate: true)
                return
            }
            container.prepareToClose { result in
                switch result {
                case .success:
                    application.reply(toApplicationShouldTerminate: true)
                case .failure(let error):
                    self.presentSaveFailure(error, application: application)
                }
            }
        }
    }

    private func presentSaveFailure(_ error: Error, application: NSApplication) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = NSLocalizedString("quit.error.title", comment: "Save failure")
        alert.informativeText = error.localizedDescription
        alert.addButton(withTitle: NSLocalizedString("action.retry", comment: "Retry"))
        alert.addButton(withTitle: NSLocalizedString("quit.keepEditing", comment: "Cancel quit"))
        alert.addButton(withTitle: NSLocalizedString("quit.discard", comment: "Explicitly discard unsaved draft"))

        let respond: (NSApplication.ModalResponse) -> Void = { response in
            switch response {
            case .alertFirstButtonReturn:
                self.saveBeforeQuitting(application: application)
            case .alertThirdButtonReturn:
                application.reply(toApplicationShouldTerminate: true)
            default:
                self.isPreparingToQuit = false
                application.reply(toApplicationShouldTerminate: false)
            }
        }
        if let window = mainWindowController?.window, window.isVisible {
            alert.beginSheetModal(for: window, completionHandler: respond)
        } else {
            respond(alert.runModal())
        }
    }

    private func revealDataDirectory() {
        guard let url = container?.persistence.storageDirectoryURL,
            FileManager.default.fileExists(atPath: url.path) else { return }
        _ = NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
    }
}
