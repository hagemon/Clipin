//
//  ClipWindow.swift
//  Clipin
//
//  Created by hagemon on 2020/12/27.
//

import Cocoa

class ClipWindow: NSWindow {
    
    var rectView: RectView
    var backView: BackView
    
    init(contentRect: NSRect, backView: BackView, rectView: RectView) {
        self.rectView = rectView
        self.backView = backView

        super.init(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: false)
//        self.contentView = contentView
        self.contentView?.addSubview(backView)
        self.contentView?.addSubview(rectView)
        self.level = .statusBar
    }
    
}
