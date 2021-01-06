//
//  PinWindow.swift
//  Clipin
//
//  Created by hagemon on 2021/1/1.
//

import Cocoa

class PinWindow: NSWindow {
    init(rect: NSRect, contentView: PinView) {
        super.init(contentRect: rect, styleMask: [.closable, .titled, .miniaturizable, .fullSizeContentView], backing: .buffered, defer: false)
        self.titleVisibility = .visible
        self.titlebarAppearsTransparent = true
        self.contentView = contentView
        self.level = .floating
        self.isMovableByWindowBackground = true
        NotificationCenter.default.addObserver(self, selector: #selector(pinFloating), name: NotiNames.pinFloating.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pinNormal), name: NotiNames.pinNormal.name, object: nil)
    }
    
    func hideTitle() {
        self.styleMask = [.titled, .fullSizeContentView]
    }
    
    func showTitle() {
        self.styleMask = [.closable, .titled, .miniaturizable, .fullSizeContentView]
    }
    
    @objc func pinFloating() {
        self.level = .floating
    }
    
    @objc func pinNormal() {
        self.level = .normal
    }    
    
}
