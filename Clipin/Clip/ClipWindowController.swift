//
//  ClipWindowController.swift
//  Clipin
//
//  Created by hagemon on 2020/12/27.
//

import Cocoa
import Carbon

class ClipWindowController: NSWindowController {
    
    // MARK: - Properties
    
    var startPoint: NSPoint?
    var lastPoint: NSPoint?
    var backView: BackView?
    var rectView: RectView?
    
    var lastRect: NSRect?
    var highlightRect: NSRect?
    var screenImage: NSImage?
    
    var selectDotType: DotType = .none
    var selectDot: NSPoint = .zero
    
    // MARK: - Initialization
        
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    init(window: ClipWindow) {
        super.init(window: window)
        self.window = window
        NotificationCenter.default.addObserver(self, selector: #selector(self.done), name: NotiNames.clipEnd.name, object: nil)
        guard let view = window.contentView else {return}
        let trackingArea = NSTrackingArea(rect: view.frame, options: [.activeAlways, .mouseMoved, .mouseEnteredAndExited], owner: self, userInfo: [:])
        view.addTrackingArea(trackingArea)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Screen Capture
    
    func capture(_ screen:NSScreen) {
        guard let window = self.window as? ClipWindow else { return }
        guard let displayID = screen.deviceDescription[NSDeviceDescriptionKey(rawValue: "NSScreenNumber")] as? CGDirectDisplayID,
              let cgScreenImage = CGDisplayCreateImage(displayID)
        else { return }
        self.screenImage = NSImage(cgImage: cgScreenImage, size: screen.frame.size)
        window.backgroundColor = NSColor(white: 0, alpha: 1)
        self.backView = window.backView
        self.rectView = window.rectView
        self.backView?.image = self.screenImage
        self.rectView?.image = self.screenImage
        self.showWindow(nil)
    }
    
    func highlight() {
        guard let rect = self.highlightRect,
              let image = self.screenImage,
              let rectView = self.rectView
        else { return }
        DispatchQueue.main.async {
            if rectView.image == nil {
                rectView.image = image
            }
            rectView.drawingRect = rect
            rectView.needsDisplay = true
        }
    }
    
    @objc func done() {
        guard let rectView = self.rectView,
              var rect = rectView.drawingRect,
              let window = self.window
        else {
            return
        }
        rectView.showDots = false
        rectView.needsDisplay = true
        rect = NSIntersectionRect(rect, window.frame)
        guard let bitmapRep = rectView.bitmapImageRepForCachingDisplay(in: rect),
              let screen = window.screen
        else {return}
        rectView.cacheDisplay(in: rect, to: bitmapRep)
        PinManager.shared.pin(rep: bitmapRep, rect: rect, screenOrigin: screen.visibleFrame.origin)
    }
    
    func detectWindow(with event: NSEvent) {
        guard let window = self.window,
              let screen = window.screen
        else { return }
        let windowsInfo = ClipManager.shared.windowsInfo
        for info in windowsInfo {
            guard var rect = NSRect(dictionaryRepresentation: info[kCGWindowBounds] as! CFDictionary)
            else {continue}
            var layer = 0
            let ref = info[kCGWindowLayer] as! CFNumber
            CFNumberGetValue(ref, .sInt32Type, &layer)
            rect = RectUtil.correctCGWindowRect(rect: rect, on: screen)
            if rect.contains(event.locationInWindow) && layer == 0 {
                self.highlightRect = rect
                self.highlight()
                break
            }

        }
    }
    
    // MARK: - Mouse Events
    
    override func mouseMoved(with event: NSEvent) {
        guard ClipManager.shared.status == .ready else {
            return
        }
        self.detectWindow(with: event)
    }
    
    override func mouseExited(with event: NSEvent) {
        guard ClipManager.shared.status == .ready,
              let rectView = self.rectView
        else {
            return
        }
        rectView.drawingRect = nil
        rectView.needsDisplay = true
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = event.locationInWindow
        switch ClipManager.shared.status {
        case .ready:
            ClipManager.shared.status = .start
            self.startPoint = location
        case .select:
            guard let rect = self.highlightRect,
                  let rectView = self.rectView,
                  rect.insetBy(dx: -5, dy: -5).contains(location)
            else { return }
            for (path, type) in rectView.paths {
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
            guard let rect = self.highlightRect,
                  let rectView = self.rectView
            else {
                ClipManager.shared.status = .ready
                return
            }
            rectView.showDots = true
            ClipManager.shared.status = .select
            self.lastRect = rect
            self.highlight()
        case .select:
            break
        case .drag, .adjust:
            guard let rect = self.highlightRect,
                  let rectView = self.rectView
            else { return }
            rectView.showDots = true
            self.startPoint = rect.origin
            self.selectDotType = .none
            self.lastRect = rect
            ClipManager.shared.status = .select
        default:
            return
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
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
                  let lastPoint = self.lastPoint,
                  let window = self.window
            else { break }
            
            var dx = location.x - lastPoint.x
            var dy = location.y - lastPoint.y

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
    }
}
