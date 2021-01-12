//
//  PreferenceWindow.swift
//  Clipin
//
//  Created by 一折 on 2021/1/10.
//

import Cocoa
import Carbon
import HotKey

class PreferencesWindow: NSWindow, NSTextFieldDelegate {
    @IBOutlet weak var textField: NSTextField!
    var keyListener: Any?
    
    override func awakeFromNib() {
        self.textField.placeholderString = Storage.getModifierFlags().description+Storage.getKey().description
        self.keyListener = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: {
            event in
            if !event.modifierFlags.isEmpty{
                self.textField.stringValue = event.modifierFlags.description+event.charactersIgnoringModifiers!
                KeyMonitorManager.shared.registerHotKey(
                    key: Key(carbonKeyCode: UInt32(event.keyCode))!,
                    modifiers: event.modifierFlags
                )
            }
            return nil
        })
        self.level = .floating
        super.awakeFromNib()
//        ClipManager.shared.hotKey.isPaused = true
        KeyMonitorManager.shared.pauseHotKey()
    }
    
    override func close() {
//        ClipManager.shared.hotKey.isPaused = false
        KeyMonitorManager.shared.resignHotKey()
        if self.keyListener != nil {
            NSEvent.removeMonitor(self.keyListener!)
        }
        super.close()
    }

}
