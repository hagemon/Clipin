//
//  BackView.swift
//  Clipin
//
//  Created by 一折 on 2021/2/24.
//

import Cocoa

class BackView: NSView {

    var image: NSImage?

    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)

        // Drawing code here.
        guard let image = self.image,
              let window = self.window
        else {
            return
        }
        
        let originFrame = NSRect(origin: .zero, size: window.frame.size)
        image.draw(in: originFrame, from: originFrame, operation: .sourceOver, fraction: 0.5)

    }
    
}
