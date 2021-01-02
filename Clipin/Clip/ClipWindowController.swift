//
//  ClipWindowController.swift
//  Clipin
//
//  Created by 一折 on 2020/12/27.
//

import Cocoa
import Carbon

class ClipWindowController: NSWindowController {
    
    var startPoint: NSPoint?
    var lastPoint: NSPoint?
    var clipView: ClipView?
    
    var lastRect: NSRect = NSRect.zero
    var highlightRect: NSRect?
    var screenImage: NSImage?
    var isDragging = false
    
    var isActive = false

    override func windowDidLoad() {
        super.windowDidLoad()
        // add enter observer
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func capture(_ screen:NSScreen) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.done), name: NotiNames.clipEnd.name, object: nil)
        let cgScreenImage = CGDisplayCreateImage(CGMainDisplayID())
        self.screenImage = NSImage(cgImage: cgScreenImage!, size: screen.frame.size)
        self.window?.backgroundColor = NSColor(white: 0, alpha: 0.5)
        self.clipView = self.window?.contentView as? ClipView
        self.showWindow(nil)
    }
    
    func highlight() {
        if self.highlightRect == nil {
            return
        }
        else if self.screenImage != nil && self.lastRect.equalTo(self.highlightRect!){
            return
        }
        else if self.screenImage == nil && self.clipView?.image == nil{
            return
        }
        DispatchQueue.main.async {
            if self.clipView?.image == nil {
                self.clipView?.image = self.screenImage
            }
            let rect = self.window?.convertFromScreen(self.highlightRect!)
            self.clipView?.drawingRect = rect
            self.clipView?.needsDisplay = true
            self.lastRect = self.highlightRect!
        }
    }
    
    @objc func done() {
        guard let view = self.clipView,
              let rect = view.drawingRect
        else {
            return
        }
        guard let bitmapRep = view.bitmapImageRepForCachingDisplay(in: rect) else {return}
        view.cacheDisplay(in: rect, to: bitmapRep)
        PinManager.shared.pin(rep: bitmapRep, rect: rect)
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = event.locationInWindow
        switch ClipManager.shared.status {
        case .ready:
            ClipManager.shared.status = .start
            self.startPoint = location
        case .select:
            if self.highlightRect!.contains(location) {
                self.isDragging = true
                self.lastPoint = location
            }
        default:
            return
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        switch ClipManager.shared.status {
        case .start:
            if self.highlightRect != nil {
                ClipManager.shared.status = .select
            } else {
                ClipManager.shared.status = .ready
            }
        case .select:
            self.isDragging = false
            self.startPoint = self.highlightRect!.origin
        default:
            return
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        let location = event.locationInWindow
        switch ClipManager.shared.status {
        case .start:
            self.highlightRect = NSUnionRect(NSRect(origin: self.startPoint!, size: CGSize(width: 1, height: 1)), NSRect(origin: location, size: CGSize(width: 1, height: 1)))
            self.highlight()
        case .select:
            if self.isDragging {
                let dx = location.x - self.lastPoint!.x
                let dy = location.y - self.lastPoint!.y
                self.highlightRect = self.highlightRect!.offsetBy(dx: dx, dy: dy)
                self.lastPoint = location
                self.highlight()
            }
        default:
            return
        }
    }
    
    override func keyDown(with event: NSEvent) {
        print("ha")
    }
    
}
