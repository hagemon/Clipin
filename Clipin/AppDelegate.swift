//
//  AppDelegate.swift
//  Clipin
//
//  Created by 一折 on 2020/12/19.
//

import Cocoa
import Carbon
import HotKey

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: {
            (event) -> NSEvent? in
            if ClipManager.shared.status != .off && event.keyCode == kVK_Escape {
                ClipManager.shared.end()
            }
            if ClipManager.shared.status == .off && event.modifierFlags.contains(.shift) {
                if event.keyCode == kVK_ANSI_A {
                    self.capture(NSDate.now.timestamp())
                }
            }
            if ClipManager.shared.status == .select && event.keyCode == kVK_Return {
                NotificationCenter.default.post(name: NotiNames.clipEnd.name, object: self, userInfo: nil)
            }
            return event
        })
        
        guard let button = self.statusItem.button else { return }
        button.image = NSImage(named: NSImage.Name("StatusBarIcon"))
        button.action = #selector(showMenu)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func capture(_ dest:String) -> Void {
        ClipManager.shared.start()
    }
    
    @objc func showMenu() {
    }


}

