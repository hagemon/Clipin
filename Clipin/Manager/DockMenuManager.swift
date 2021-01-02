//
//  DockMenuManager.swift
//  Clipin
//
//  Created by 一折 on 2021/1/2.
//

import Cocoa

class DockMenuManager: NSObject {
    static let shared = DockMenuManager()
    private var menu = NSMenu(title: "Clipin")
    
    func addWindow() {
        self.menu.addItem(withTitle: "Window \(self.menu.items.count)", action: #selector(self.selectItem(sender:)), keyEquivalent: "")
    }
    
    func removeWindow(at index:Int) {
        self.menu.removeItem(at: index)
    }
    
    @objc private func selectItem(sender: NSMenuItem) {
        let index = self.menu.index(of: sender)
        NotificationCenter.default.post(name: NotiNames.dockMenuItemSelect.name, object: nil, userInfo: ["index":index])
    }
    
    
}
