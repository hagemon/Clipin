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
    let hotKey = HotKey(key: .a, modifiers: [.shift, .command])

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: {
            (event) -> NSEvent? in
            let status = ClipManager.shared.status
            if status != .off && event.keyCode == kVK_Escape {
                ClipManager.shared.end()
            }
            if (status == .ready || status == .select) && event.keyCode == kVK_Return {
                NotificationCenter.default.post(name: NotiNames.clipEnd.name, object: self, userInfo: nil)
            }
            return nil
        })
        
        self.hotKey.keyUpHandler = {
            guard ClipManager.shared.status == .off else {
                return
            }
            self.capture(NSDate.now.timestamp())
        }
        
        
        guard let button = self.statusItem.button else { return }
        button.image = NSImage(named: NSImage.Name("StatusBarIcon"))
//        button.action = #selector(showMenu)
        
        self.statusItem.menu = NSMenu(title: "menu")
        guard let menu = self.statusItem.menu else { return }
        menu.addItem(withTitle: "Preferences", action: nil, keyEquivalent: "p")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "q")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func capture(_ dest:String) -> Void {
        ClipManager.shared.start()
    }
    
    @objc func showMenu() {
        
    }
    
    @objc func quit() {
        NSApp.terminate(nil)
    }


}

