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
        let fm = FileManager()
        if !fm.fileExists(atPath: self.root) {
            do {
                try fm.createDirectory(at: URL(fileURLWithPath: self.root), withIntermediateDirectories: true, attributes: [:])
            } catch {
                print("Create directory failed")
            }
        }
    }
    
    func pin(rep: NSBitmapImageRep, rect:NSRect) {
        let image = NSImage(size: rect.size)
        image.addRepresentation(rep)
//        guard let screen = NSScreen.main else { return }
        let view = PinView(image: image)
        let window = PinWindow(rect: rect, contentView: view)
        let controller = PinWindowController(window: window)
        self.controllers.append(controller)
        controller.showWindow(nil)
        NotificationCenter.default.post(name: NotiNames.pinEnd.name, object: nil)
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
    
}
