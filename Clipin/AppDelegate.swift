//
//  AppDelegate.swift
//  Clipin
//
//  Created by hagemon on 2020/12/19.
//

import Cocoa
import Carbon
import HotKey

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        KeyMonitorManager.shared.registerHotKey(key: Storage.getKey(), modifiers: Storage.getModifierFlags())
                        
        guard let button = self.statusItem.button else { return }
        button.image = NSImage(named: NSImage.Name("StatusBarIcon"))
        
        self.statusItem.menu = NSMenu(title: "menu")
        guard let menu = self.statusItem.menu else { return }
        menu.addItem(withTitle: "Preferences", action: #selector(self.openPreferences), keyEquivalent: "p")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit", action: #selector(self.quit), keyEquivalent: "q")
//        self.openPreferences()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func openPreferences() {
        let controller = PreferencesWindowController(windowNibName: "Preferences")
        NSApplication.shared.activate(ignoringOtherApps: true)
        controller.showWindow(nil)
    }

    @objc func quit() {
        NSApp.terminate(nil)
    }


}

