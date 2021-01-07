//
//  ClipWindow.swift
//  Clipin
//
//  Created by hagemon on 2020/12/27.
//

import Cocoa

class ClipWindow: NSWindow {
    
    init(contentRect: NSRect, contentView: ClipView) {
        super.init(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: false)
        self.contentView = contentView
        self.level = .statusBar
    }
    
}
