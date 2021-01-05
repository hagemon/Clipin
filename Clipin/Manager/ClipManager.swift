//
//  ClipManager.swift
//  Clipin
//
//  Created by 一折 on 2020/12/27.
//

import Cocoa

class ClipManager {
    
    static let shared = ClipManager()
    
    var controllers: [ClipWindowController] = []
    var status: ClipStatus = .off {
        didSet {
            print(self.status)
        }
    }
    
    private init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.end),
                                               name: NotiNames.pinEnd.name,
                                               object: nil)
    }
    
    func start() {
        NotificationCenter.default.post(name: NotiNames.pinNormal.name, object: nil)
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
        self.status = .off
    }
    
}

