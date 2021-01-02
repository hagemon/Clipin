//
//  PinManager.swift
//  Clipin
//
//  Created by 一折 on 2020/12/27.
//

import Cocoa

class PinManager: NSObject {
    static let shared = PinManager()
    private let root = "./ImageStorage/"
    var controllers: [PinWindowController] = []
    
    private override init() {
        super.init()
        let fm = FileManager()
        if !fm.fileExists(atPath: self.root) {
            do {
                try fm.createDirectory(at: URL(fileURLWithPath: self.root), withIntermediateDirectories: true, attributes: [:])
            } catch {
                print("Create directory failed")
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.windowCloseHandler(_:)), name: NotiNames.windowClose.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.windowFront(_:)), name: NotiNames.dockMenuItemSelect.name, object: nil)
    }
    
    func pin(rep: NSBitmapImageRep, rect:NSRect) {
        let image = NSImage(size: rect.size)
        image.addRepresentation(rep)
        let view = PinView(image: image)
        let window = PinWindow(rect: rect, contentView: view)
        let controller = PinWindowController(window: window)
        if self.controllers.isEmpty {
            NSApp.setActivationPolicy(.regular)
        }
        self.controllers.append(controller)
        window.title = "Window \(self.controllers.count)"
        controller.showWindow(nil)
        NotificationCenter.default.post(name: NotiNames.pinEnd.name, object: nil)
        DockMenuManager.shared.addWindow()
    }
    
    private func saveImage(rep: NSBitmapImageRep) {
        let url = self.getURL()
        do {
            let jpegData = rep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [.compressionFactor:1])!
            print("save image to \(url)")
            try jpegData.write(to: url, options: .atomic)
        } catch {
            print("error:\(error)")
        }
    }
    
    private func getURL() -> URL {
        return URL(fileURLWithPath: self.root+NSDate.now.timestamp()+".jpg")
    }
    
    @objc func windowCloseHandler(_ notification: Notification) {
        guard let index = self.controllers.firstIndex(of: notification.object as! PinWindowController) else { return }
        self.controllers.remove(at: index)
        if self.controllers.isEmpty {
            NSApp.setActivationPolicy(.accessory)
        }
        DockMenuManager.shared.removeWindow(at: index)
    }
    
    @objc func windowFront(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let index = userInfo["index"] as? Int,
              let window = self.controllers[index].pinWindow
        else { return }
        window.orderFront(nil)
    }
    
}
