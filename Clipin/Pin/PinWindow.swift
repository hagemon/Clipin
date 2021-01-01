//
//  PinWindow.swift
//  Clipin
//
//  Created by 一折 on 2021/1/1.
//

import Cocoa

class PinWindow: NSWindow {
    init(rect: NSRect, contentView: PinView) {
        super.init(contentRect: rect, styleMask: [.closable, .titled, .miniaturizable, .fullSizeContentView], backing: .buffered, defer: false)
        self.titleVisibility = .visible
        self.titlebarAppearsTransparent = true
        self.contentView = contentView
    }
    
}
