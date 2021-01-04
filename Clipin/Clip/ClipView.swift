//
//  ClipView.swift
//  Clipin
//
//  Created dx 一折 on 2020/12/27.
//

import Cocoa

class ClipView: NSView {
    
    var image: NSImage?
    var drawingRect: NSRect?
    var showDots = false

    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)

        // Drawing code here.
        guard let image = self.image else {
            return
        }
        var rect = NSIntersectionRect(self.drawingRect!, self.bounds)
        rect = NSIntegralRect(rect)
        image.draw(in: rect, from: rect, operation: .sourceOver, fraction: 1.0)
        if self.showDots {
            self.drawDots(rect: rect)
        }

    }
    
    private func drawDots(rect: NSRect) {
        let radius: CGFloat = 1.5
        let dots = self.getDotsCoord(with: rect, radius: radius)
        for dot in dots {
            let path = NSBezierPath(ovalIn: NSRect(origin: dot, size: CGSize(width: radius*2, height: radius*2)))
            path.lineWidth = 3
            NSColor.white.set()
            path.stroke()
        }
    }
    
    func getDotsCoord(with rect:NSRect, radius: CGFloat) -> [NSPoint] {
        let width = rect.width
        let height = rect.height
        let origin = rect.origin
        let dots = [
            origin,
            origin.offsetBy(dx: width/2, dy: 0),
            origin.offsetBy(dx: 0, dy: height/2),
            origin.offsetBy(dx: width, dy: 0),
            origin.offsetBy(dx: 0, dy: height),
            origin.offsetBy(dx: width, dy: height/2),
            origin.offsetBy(dx: width/2, dy: height),
            origin.offsetBy(dx: width, dy: height)
        ]
        return dots.map({dot in dot.offsetBy(dx: -radius, dy: -radius)})
    }
    
    
    
}
