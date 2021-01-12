//
//  KeyManager.swift
//  Clipin
//
//  Created by 一折 on 2021/1/11.
//

import Cocoa
import HotKey
import Carbon

class KeyMonitorManager: NSObject {
    static let shared = KeyMonitorManager()
    var hotKey: HotKey?
    var clipMonitor: Any?
    var preferenceMonitor: Any?
    
    func registerHotKey(key: Key, modifiers: NSEvent.ModifierFlags) {
        self.hotKey = HotKey(key: key, modifiers: modifiers, keyDownHandler: {
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
        })
        Storage.saveKey(key: key)
        Storage.saveModifierFlags(modifiers: modifiers)
    }
    
    func pauseHotKey() {
        guard let hotKey = self.hotKey else { return }
        hotKey.isPaused = true
    }
    
    func resignHotKey() {
        guard let hotKey = self.hotKey else { return }
        hotKey.isPaused = false
    }
    
    func registerClipMonitor() {
        self.clipMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: {
            (event) -> NSEvent? in
            let status = ClipManager.shared.status
            if status != .off && event.keyCode == kVK_Escape {
                ClipManager.shared.end()
            }
            else if (status == .ready || status == .select) && event.keyCode == kVK_Return {
                NotificationCenter.default.post(name: NotiNames.clipEnd.name, object: self, userInfo: nil)
            }
            if status == .off {
                return event
            }else{
                return nil
            }
        })
    }
    
    func removeClipMonitor() {
        if self.clipMonitor != nil{
            NSEvent.removeMonitor(self.clipMonitor!)
        }
    }
}
