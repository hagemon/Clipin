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
    }
    
    func start() {
//        print("\(NSScreen.screens.count) screens detected:\n \(NSScreen.screens)")
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
    
    func end() {
        for controller in self.controllers {
            controller.window?.orderOut(nil)
        }
        self.controllers.removeAll()
        self.status = .off
    }
    
}

enum ClipStatus {
    case off
    case ready
    case start
    case select
    case adjust
    case drag
}
