import AppKit

enum MenuBuilder {
    static func build(target: AppDelegate) -> NSMenu {
        let main = NSMenu()
        let appMenu = submenu(title: "FitTrack", in: main)
        add("menu.about", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), to: appMenu, target: NSApp)
        appMenu.addItem(.separator())
        let services = submenu(title: NSLocalizedString("menu.services", comment: "Menu"), in: appMenu)
        NSApp.servicesMenu = services
        appMenu.addItem(.separator())
        add("menu.hide", action: #selector(NSApplication.hide(_:)), key: "h", to: appMenu, target: NSApp)
        add("menu.hideOthers", action: #selector(NSApplication.hideOtherApplications(_:)), key: "h", to: appMenu, target: NSApp, modifiers: [.command, .option])
        add("menu.showAll", action: #selector(NSApplication.unhideAllApplications(_:)), to: appMenu, target: NSApp)
        appMenu.addItem(.separator())
        add("menu.quit", action: #selector(NSApplication.terminate(_:)), key: "q", to: appMenu, target: NSApp)

        let fileMenu = submenu(title: NSLocalizedString("menu.file", comment: "Menu"), in: main)
        add("menu.save", action: #selector(AppDelegate.saveProfile(_:)), key: "s", to: fileMenu, target: target)
        fileMenu.addItem(.separator())
        add("menu.close", action: #selector(NSWindow.performClose(_:)), key: "w", to: fileMenu)

        let editMenu = submenu(title: NSLocalizedString("menu.edit", comment: "Menu"), in: main)
        add("menu.undo", action: Selector(("undo:")), key: "z", to: editMenu)
        add("menu.redo", action: Selector(("redo:")), key: "z", to: editMenu, modifiers: [.command, .shift])
        editMenu.addItem(.separator())
        add("menu.cut", action: #selector(NSText.cut(_:)), key: "x", to: editMenu)
        add("menu.copy", action: #selector(NSText.copy(_:)), key: "c", to: editMenu)
        add("menu.paste", action: #selector(NSText.paste(_:)), key: "v", to: editMenu)
        add("menu.selectAll", action: #selector(NSText.selectAll(_:)), key: "a", to: editMenu)

        let windowMenu = submenu(title: NSLocalizedString("menu.window", comment: "Menu"), in: main)
        add("menu.minimize", action: #selector(NSWindow.performMiniaturize(_:)), key: "m", to: windowMenu)
        add("menu.zoom", action: #selector(NSWindow.performZoom(_:)), to: windowMenu)
        windowMenu.addItem(.separator())
        add("menu.front", action: #selector(NSApplication.arrangeInFront(_:)), to: windowMenu, target: NSApp)
        NSApp.windowsMenu = windowMenu
        return main
    }

    private static func submenu(title: String, in parent: NSMenu) -> NSMenu {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        let menu = NSMenu(title: title)
        item.submenu = menu
        parent.addItem(item)
        return menu
    }

    private static func add(
        _ key: String,
        action: Selector,
        key shortcut: String = "",
        to menu: NSMenu,
        target: AnyObject? = nil,
        modifiers: NSEvent.ModifierFlags = .command
    ) {
        let item = NSMenuItem(title: NSLocalizedString(key, comment: "Menu item"), action: action, keyEquivalent: shortcut)
        item.target = target
        item.keyEquivalentModifierMask = modifiers
        menu.addItem(item)
    }
}
