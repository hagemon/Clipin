//
//  ClipWindowController.swift
//  Clipin
//
//  Created by 一折 on 2020/12/27.
//

import Cocoa
import Carbon

class ClipWindowController: NSWindowController {
    
    var keyMonitor: Any?
    var startPoint: NSPoint?
    var clipView: ClipView?
    
    var lastRect: NSRect = NSRect.zero
    var highlightRect: NSRect?
    var screenImage: NSImage?
    

    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    func capture(_ screen:NSScreen) {
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
            self.clipView?.image = self.screenImage
            let rect = self.window?.convertFromScreen(self.highlightRect!)
            self.clipView?.drawingRect = rect
            self.clipView?.needsDisplay = true
            self.lastRect = self.highlightRect!
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        if ClipManager.shared.status == .ready {
            ClipManager.shared.status = .start
            self.startPoint = event.locationInWindow
        }
    }
    
    override func mouseUp(with event: NSEvent) {

    }
    
    override func mouseDragged(with event: NSEvent) {
        if ClipManager.shared.status == .start {
            self.highlightRect = NSUnionRect(NSRect(origin: self.startPoint!, size: CGSize(width: 1, height: 1)), NSRect(origin: event.locationInWindow, size: CGSize(width: 1, height: 1)))
            self.highlight()
        }
    }
    
}
