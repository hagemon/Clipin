//
//  RectUtil.swift
//  Clipin
//
//  Created by 一折 on 2021/1/4.
//

import Cocoa

class RectUtil: NSObject {
    static func getRect(aPoint: NSPoint, bPoint:NSPoint) -> NSRect{
        return NSIntegralRect(NSRect(
            x: min(aPoint.x, bPoint.x),
            y: min(aPoint.y, bPoint.y),
            width: abs(aPoint.x-bPoint.x),
            height: abs(aPoint.y-bPoint.y)
        ))
    }
    
    static func detectOverflow(rect: NSRect, in window:NSWindow) -> RectIssue {
        let origin = rect.origin
        let points = [origin,
                      origin.offsetBy(dx: rect.width, dy: 0),
                      origin.offsetBy(dx: 0, dy: rect.height),
                      origin.offsetBy(dx: rect.width, dy: rect.height)
        ]
        var xFlag = false
        var yFlag = false
        for p in points {
            if p.x < 0 || p.x > window.frame.width{
                xFlag = true
            }
            if p.y < 0 || p.y > window.frame.height{
                yFlag = true
            }
        }
        if xFlag && yFlag {
            return .bothOverflow
        }else if xFlag {
            return .xOverflow
        }else if yFlag {
            return .yOverflow
        }else{
            return .normal
        }
    }
}
