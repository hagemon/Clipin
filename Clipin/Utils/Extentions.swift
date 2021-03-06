//
//  Extentions.swift
//  Clipin
//
//  Created by hagemon on 2020/12/31.
//

import Cocoa

extension Date {
    func timestamp() -> String {
        return String(Date().timeIntervalSince1970)
    }
}

extension NSPoint {
    func offsetBy(dx:CGFloat, dy: CGFloat) -> NSPoint {
        return NSPoint(x: self.x+dx, y: self.y+dy)
    }
}

extension NSRect {
    func center() -> NSPoint{
        let origin = self.origin
        return NSPoint(x: origin.x+self.width/2, y: origin.y+self.height/2)
        
    }
    
    func symmetricalPoint(point: NSPoint) -> NSPoint {
        let center = self.center()
        return NSPoint(x: Int(2*center.x-point.x), y: Int(2*center.y-point.y))
    }
}
