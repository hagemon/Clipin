//
//  extensions.swift
//  Clipin
//
//  Created by 一折 on 2020/12/30.
//

import Foundation

enum ClipStatus {
    case off
    case ready
    case start
    case select
    case adjust
    case drag
}

enum NotiNames: String {
    var name: NSNotification.Name {
        return Notification.Name(self.rawValue)
    }
    case clipEnd = "doEndClip"
    case pinEnd = "doEndPin"
    case pinFloating = "pinFloating"
    case pinNormal = "pinNormal"
}

