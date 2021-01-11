//
//  ClipManager.swift
//  Clipin
//
//  Created by hagemon on 2020/12/27.
//

import Cocoa
import Carbon
import HotKey

class ClipManager {
    
    static let shared = ClipManager()
    
    var controllers: [ClipWindowController] = []
    var windowsInfo: [CFArray] = []
    var status: ClipStatus = .off {
        didSet {
            // print(self.status)
        }
    }
    var monitor: Any?
    var hotKey: HotKey = HotKey(key: .a, modifiers: [.command, .shift])
    
    private init() {
        self.registerHotKey(key: Storage.getKey(), modifiers: Storage.getModifierFlags())
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.end),
                                               name: NotiNames.pinEnd.name,
                                               object: nil)
    }
    
    func registerHotKey(key: Key, modifiers: NSEvent.ModifierFlags) {
        self.hotKey = HotKey(key: key, modifiers: modifiers)
        self.hotKey.keyDownHandler = {
            guard CGPreflightScreenCaptureAccess() else {
                let alert = NSAlert()
                alert.messageText = "Require screen record access."
                alert.runModal()
                CGRequestScreenCaptureAccess()
                return
            }
            guard ClipManager.shared.status == .off else {
                return
            }
            ClipManager.shared.start()
        }
        Storage.saveKey(key: key)
        Storage.saveModifierFlags(modifiers: modifiers)
    }
    
    func start() {
        NotificationCenter.default.post(name: NotiNames.pinNormal.name, object: nil)
        
//        guard let info = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) else { return }
//        print(info)
//        for i in 0...CFArrayGetCount(info) {
//            let windowInfo = CFArrayGetValueAtIndex(info, i)
//            print(windowInfo!)
//        }
        
        NSApplication.shared.activate(ignoringOtherApps: true)
        KeyMonitorManager.shared.registerClipMonitor()
        
        for screen in NSScreen.screens {
            let view = ClipView(frame: screen.frame)
            let clipWindow = ClipWindow(contentRect: screen.frame, contentView: view)
            let clipWindowController = ClipWindowController(window: clipWindow)
            controllers.append(clipWindowController)
            self.status = .ready
            clipWindowController.capture(screen)
        }
        
    }
    
    @objc func end() {
        NotificationCenter.default.post(name: NotiNames.pinFloating.name, object: nil)
        for controller in self.controllers {
            controller.window?.orderOut(nil)
        }
        self.controllers.removeAll()
        KeyMonitorManager.shared.removeClipMonitor()
        self.status = .off
    }
    
}

