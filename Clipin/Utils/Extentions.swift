//
//  Extentions.swift
//  Clipin
//
//  Created by 一折 on 2020/12/31.
//

import Cocoa

extension NSSize {
    public static func *(aSize: NSSize, t:CGFloat) -> NSSize {
        return NSSize(width: aSize.width*t, height: aSize.height*t)
    }
}
