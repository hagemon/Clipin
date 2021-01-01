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
        NotificationCenter.default.addObserver(self, selector: #selector(self.end), name: NotiNames.pinEnd.name, object: nil)
    }
    
    func start() {
        for screen in NSScreen.screens {
            let clipWindowController = ClipWindowController()
            let clipWindow = ClipWindow(contentRect: screen.frame, styleMask: .fullSizeContentView, backing: .buffered, defer: false, screen: screen)
            clipWindowController.window = clipWindow
            clipWindow.contentView = ClipView(frame: screen.frame)
            controllers.append(clipWindowController)
            self.status = .ready
            clipWindowController.capture(screen)
        }
    }
    
    @objc func end() {
        for controller in self.controllers {
            controller.window?.orderOut(nil)
        }
        self.controllers.removeAll()
        self.status = .off
    }
    
}

