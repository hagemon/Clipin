//
//  PinView.swift
//  Clipin
//
//  Created by hagemon on 2021/1/1.
//

import Cocoa

class PinView: NSView {
    
    var image: NSImage?
    
    init(image: NSImage) {
        super.init(frame: .zero)
        self.image = image
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        guard let image = self.image else { return }
        image.draw(in: self.frame, from: self.frame, operation: .sourceOver, fraction: 1.0)
    }
    
}
