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
    var status: ClipStatus = .off {
        didSet {
             print(self.status)
        }
    }
    var windowsInfo: [AnyObject] = []
    
    private init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.end),
                                               name: NotiNames.pinEnd.name,
                                               object: nil)
    }
    
    func start() {
        NotificationCenter.default.post(name: NotiNames.pinNormal.name, object: nil)
        
        guard let windowsInfo = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as [AnyObject]? else { return }
        self.windowsInfo = windowsInfo
        
        NSApplication.shared.activate(ignoringOtherApps: true)
        KeyMonitorManager.shared.registerClipMonitor()
        
        for screen in NSScreen.screens {
            let view = ClipView(frame: screen.frame)
            let clipWindow = ClipWindow(contentRect: screen.frame, contentView: view)
            let clipWindowController = ClipWindowController(window: clipWindow)
            controllers.append(clipWindowController)
            clipWindowController.capture(screen)
        }
        self.status = .ready
        
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

