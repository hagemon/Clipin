//
//  Extentions.swift
//  Clipin
//
//  Created by 一折 on 2020/12/31.
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
