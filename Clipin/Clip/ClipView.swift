//
//  ClipView.swift
//  Clipin
//
//  Created by 一折 on 2020/12/27.
//

import Cocoa

class ClipView: NSView {
    
    var image: NSImage?
    var drawingRect: NSRect?

    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)

        // Drawing code here.
        guard let image = self.image else {
            return
        }
        var rect = NSIntersectionRect(self.drawingRect!, self.bounds)
        rect = NSIntegralRect(rect)
        image.draw(in: rect, from: rect, operation: .sourceOver, fraction: 1.0)
    }
    
}
