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
    
    private var lock = false

    override func windowDidLoad() {
        super.windowDidLoad()
        // add enter observer
    }
    
    init(window: ClipWindow) {
        super.init(window: window)
        self.window = window
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func capture(_ screen:NSScreen) {
        guard let window = self.window else { return }
        NotificationCenter.default.addObserver(self, selector: #selector(self.done), name: NotiNames.clipEnd.name, object: nil)
        let cgScreenImage = CGDisplayCreateImage(CGMainDisplayID())
        self.screenImage = NSImage(cgImage: cgScreenImage!, size: screen.frame.size)
        window.backgroundColor = NSColor(white: 0, alpha: 0.5)
        self.clipView = window.contentView as? ClipView
        self.showWindow(nil)
    }
    
    func highlight() {
//        if self.highlightRect == nil {
//            return
//        }
//        else if self.screenImage != nil && self.lastRect.equalTo(self.highlightRect!){
//            if self.clipView != nil && !self.clipView!.showDots {
//
//            }
//            return
//        }
//        else if self.screenImage == nil && self.clipView?.image == nil{
//            return
//        }
        guard let highlightRect = self.highlightRect,
              let image = self.screenImage,
              let view = self.clipView
        else { return }
        DispatchQueue.main.async {
//            guard let view = self.clipView,
//                  let highlightRect = self.highlightRect
//            else {return}
            if view.image == nil {
                view.image = image
            }
            let rect = self.window?.convertFromScreen(highlightRect)
            view.drawingRect = rect
            view.needsDisplay = true
            self.lastRect = highlightRect
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
            guard let rect = self.highlightRect, rect.contains(location) else { return }
            self.isDragging = true
            self.lastPoint = location
        default:
            return
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        switch ClipManager.shared.status {
        case .start:
            if self.highlightRect != nil {
                ClipManager.shared.status = .select
                self.clipView!.showDots = true
                self.highlight()
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
        guard !self.lock else {
            return
        }
        self.lock = true
        let location = event.locationInWindow
        switch ClipManager.shared.status {
        case .start:
            self.highlightRect = NSUnionRect(NSRect(origin: self.startPoint!, size: CGSize(width: 1, height: 1)), NSRect(origin: location, size: CGSize(width: 1, height: 1)))
            self.highlight()
        case .select:
            guard var rect = self.highlightRect,
                  self.isDragging
            else { break }
            // bounds detection
            var dx = location.x - self.lastPoint!.x
            var dy = location.y - self.lastPoint!.y
            let offsetRect = rect.offsetBy(dx: dx, dy: dy)
            switch self.detectOverflow(rect: offsetRect) {
            case .bothOverflow:
                dx = 0
                dy = 0
            case .xOverflow:
                dx = 0
            case .yOverflow:
                dy = 0
            default:
                break
            }
            rect = rect.offsetBy(dx: dx, dy: dy)
            self.highlightRect = rect
            self.lastPoint = location
            self.startPoint = rect.origin
            self.highlight()
        default:
            break
        }
        self.lock = false
    }
    
    private func detectOverflow(rect: NSRect) -> RectIssue {
        let origin = rect.origin
        let points = [origin,
                      origin.offsetBy(dx: rect.width, dy: 0),
                      origin.offsetBy(dx: 0, dy: rect.height),
                      origin.offsetBy(dx: rect.width, dy: rect.height)
        ]
        guard let window = self.window else { return .normal }
        var xFlag = false
        var yFlag = false
        for p in points {
            if p.x < 0 || p.x > window.frame.width{
                xFlag = true
            }
            if p.y < 0 || p.y > window.frame.height{
                yFlag = true
            }
        }
        if xFlag && yFlag {
            return .bothOverflow
        }else if xFlag {
            return .xOverflow
        }else if yFlag {
            return .yOverflow
        }else{
            return .normal
        }
    }
    
    enum RectIssue {
        case xOverflow
        case yOverflow
        case bothOverflow
        case normal
    }
    
}
