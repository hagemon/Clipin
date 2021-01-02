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
