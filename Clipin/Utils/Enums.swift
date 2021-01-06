//
//  Enum.swift
//  Clipin
//
//  Created by hagemon on 2020/12/30.
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

enum DotType {
    case corner
    case top
    case bottom
    case right
    case left
    case none
}

enum RectIssue {
    case xOverflow
    case yOverflow
    case bothOverflow
    case normal
}

