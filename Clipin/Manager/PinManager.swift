//
//  PinManager.swift
//  Clipin
//
//  Created by hagemon on 2020/12/27.
//

import Cocoa

class PinManager: NSObject {
    static let shared = PinManager()
    private let root = "./ImageStorage/"
    var controllers: [PinWindowController] = []
    var activeWindow: PinWindow?
    
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
    }
    
    func pin(rep: NSBitmapImageRep, rect:NSRect, screenOrigin:NSPoint) {
        let image = NSImage(size: rect.size)
        image.addRepresentation(rep)
        let view = PinView(image: image)
        let window = PinWindow(rect: rect, contentView: view)
        let controller = PinWindowController(window: window)
        self.controllers.append(controller)
        window.setFrameOrigin(screenOrigin.offsetBy(dx: rect.origin.x, dy: rect.origin.y))
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
    
    func saveImage(cgImage: CGImage) {
        let url = self.getURL() as CFURL
        guard let dest = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, nil) else { return }
        CGImageDestinationAddImage(dest, cgImage, nil)
        CGImageDestinationFinalize(dest)
        print("save image to \(url)")
    }
    
    private func getURL() -> URL {
        return URL(fileURLWithPath: self.root+NSDate.now.timestamp()+".jpg")
    }
    
}
