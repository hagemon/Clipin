//
//  PinWindowController.swift
//  Clipin
//
//  Created by 一折 on 2021/1/1.
//

import Cocoa

class PinWindowController: NSWindowController {

    var pinWindow: PinWindow?
        
    override init(window: NSWindow?) {
        super.init(window: window)
    }
    
    init(window: PinWindow) {
        super.init(window: window)
        self.pinWindow = window
        guard let window = self.window, let view = window.contentView else { return }
        let trackingArea = NSTrackingArea(rect: view.frame, options: [.activeAlways, .mouseEnteredAndExited], owner: self, userInfo: [:])
        view.addTrackingArea(trackingArea)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
        
    override func mouseEntered(with event: NSEvent) {
        guard let window = self.pinWindow else { return }
        window.showTitle()
    }
    
    override func mouseExited(with event: NSEvent) {
        guard let window = self.pinWindow else { return }
        window.hideTitle()
    }
        
}
