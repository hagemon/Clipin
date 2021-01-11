//
//  Storage.swift
//  Clipin
//
//  Created by 一折 on 2021/1/10.
//

import Cocoa
import HotKey

class Storage: NSObject {
    static func getKey() -> Key {
        guard let keyCode = UserDefaults.standard.value(forKey: "keyCode") as? UInt32 else { return .a }
        return Key(carbonKeyCode: keyCode)!
    }
    
    static func getModifierFlags() -> NSEvent.ModifierFlags {
        guard let modifiersFlags = UserDefaults.standard.value(forKey: "modifiersFlags") as? UInt32 else {return [.command, .shift]}
        return NSEvent.ModifierFlags(carbonFlags: modifiersFlags)
    }
    
    static func saveKey(key: Key) {
        UserDefaults.standard.setValue(key.carbonKeyCode, forKey: "keyCode")
    }
    
    static func saveModifierFlags(modifiers: NSEvent.ModifierFlags) {
        UserDefaults.standard.setValue(modifiers.carbonFlags, forKey: "modifiersFlags")
    }
}
