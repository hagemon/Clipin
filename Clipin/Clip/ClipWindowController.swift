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
    
    var lastRect: NSRect?
    var highlightRect: NSRect?
    var screenImage: NSImage?
    
    var selectDotType: DotType = .none
    var selectDot: NSPoint = .zero
        
    private var lock = false

    override func windowDidLoad() {
        super.windowDidLoad()
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
        guard let highlightRect = self.highlightRect,
              let image = self.screenImage,
              let view = self.clipView
        else { return }
        DispatchQueue.main.async {
            if view.image == nil {
                view.image = image
            }
            let rect = self.window?.convertFromScreen(highlightRect)
            view.drawingRect = rect
            view.needsDisplay = true
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
            guard let rect = self.highlightRect,
                  let view = self.clipView,
                  rect.insetBy(dx: -5, dy: -5).contains(location)
            else { return }
            for (path, type) in view.paths {
                if path.bounds.insetBy(dx: -5, dy: -5).contains(location) {
                    self.selectDotType = type
                    self.selectDot = path.bounds.center()
                    break
                }
            }
            if self.selectDotType != .none {
                ClipManager.shared.status = .adjust
            } else {
                ClipManager.shared.status = .drag
            }
            self.lastPoint = location
        case .drag:
            break
        case .adjust:
            break
        default:
            return
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        switch ClipManager.shared.status {
        case .start:
            guard let rect = self.highlightRect, let view = self.clipView else {
                ClipManager.shared.status = .ready
                return
            }
            ClipManager.shared.status = .select
            view.showDots = true
            self.lastRect = rect
            self.highlight()
        case .select:
            break
        case .drag, .adjust:
            guard let rect = self.highlightRect else { return }
            self.startPoint = rect.origin
            self.selectDotType = .none
            self.lastRect = rect
            ClipManager.shared.status = .select
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
            guard let start = self.startPoint else { return }
            self.highlightRect = RectUtil.getRect(aPoint: start, bPoint: location)
            self.highlight()
        case .adjust:
            guard let lastRect = self.lastRect,
                  self.selectDotType != .none
            else { break }
            let dx = location.x - self.selectDot.x
            let dy = location.y - self.selectDot.y
            var rect: NSRect = .zero
            switch self.selectDotType {
            case .corner:
                let symPoint = lastRect.symmetricalPoint(point: self.selectDot)
                rect = RectUtil.getRect(aPoint: symPoint, bPoint: location)
            case .top:
                rect = RectUtil.getRect(
                    aPoint: lastRect.origin,
                    bPoint: self.selectDot.offsetBy(dx: lastRect.width/2, dy: dy)
                )
            case .bottom:
                rect = RectUtil.getRect(
                    aPoint: lastRect.origin.offsetBy(dx: 0, dy: lastRect.height),
                    bPoint: self.selectDot.offsetBy(dx: lastRect.width/2, dy: dy)
                )
            case .left:
                rect = RectUtil.getRect(
                    aPoint: lastRect.origin.offsetBy(dx: dx, dy: 0),
                    bPoint: self.selectDot.offsetBy(dx: lastRect.width, dy: lastRect.height/2)
                )
            case .right:
                rect = RectUtil.getRect(
                    aPoint: lastRect.origin,
                    bPoint: self.selectDot.offsetBy(dx: dx, dy: lastRect.height/2)
                )
            
            default:
                break
            }
            self.highlightRect = rect
            self.lastPoint = location
            self.startPoint = rect.origin
            self.highlight()
        case .drag:
            guard var rect = self.highlightRect,
                  let window = self.window
            else { break }
            
            var dx = location.x - self.lastPoint!.x
            var dy = location.y - self.lastPoint!.y

            let offsetRect = rect.offsetBy(dx: dx, dy: dy)
            switch RectUtil.detectOverflow(rect: offsetRect, in: window) {
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
    
}
