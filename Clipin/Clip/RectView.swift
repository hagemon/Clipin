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
    var showDots = false
    var paths: [(NSBezierPath, DotType)] = []
    
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
        if self.showDots {
            self.drawDots(rect: rect)
        }
    }
    
    private func drawDots(rect: NSRect) {
        let radius: CGFloat = 1.5
        let dots = self.getDotsCoord(with: rect, radius: radius)
        self.paths = []
        for (dot, type) in dots {
            let path = NSBezierPath(ovalIn: NSRect(origin: dot, size: CGSize(width: radius*2, height: radius*2)))
            self.paths.append((path, type))
            path.lineWidth = 3
            NSColor.white.set()
            path.stroke()
        }
    }
    
    func getDotsCoord(with rect:NSRect, radius: CGFloat) -> [(NSPoint, DotType)] {
        let width = rect.width
        let height = rect.height
        let origin = rect.offsetBy(dx: -radius, dy: -radius).origin
        let dots: [(NSPoint, DotType)] = [
            (origin, .corner),
            (origin.offsetBy(dx: width/2, dy: 0), .bottom),
            (origin.offsetBy(dx: 0, dy: height/2), .left),
            (origin.offsetBy(dx: width, dy: 0), .corner),
            (origin.offsetBy(dx: 0, dy: height), .corner),
            (origin.offsetBy(dx: width, dy: height/2), .right),
            (origin.offsetBy(dx: width/2, dy: height), .top),
            (origin.offsetBy(dx: width, dy: height), .corner)
        ].map({
            (point, type) in
            return (NSPoint(x: Int(point.x), y: Int(point.y)), type)
        })
        return dots
    }
    
}
