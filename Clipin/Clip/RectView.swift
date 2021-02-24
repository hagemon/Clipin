//
//  RectView.swift
//  Clipin
//
//  Created by 一折 on 2021/2/12.
//

import Cocoa

class RectView: NSView {
    
    var image: NSImage?
    var drawingRect: NSRect?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        guard let image = self.image,
              let drawingRect = self.drawingRect
        else {
            return
        }
        var rect = NSIntersectionRect(drawingRect, self.bounds)
        rect = NSIntegralRect(rect)
        image.draw(in: rect, from: rect, operation: .sourceOver, fraction: 1.0)
    }
    
}
