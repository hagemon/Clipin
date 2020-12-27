//
//  ViewController.swift
//  Clipin
//
//  Created by 一折 on 2020/12/19.
//

import Cocoa
import Carbon

class ViewController: NSViewController {
    
    var keyMonitor: Any?
    let root = "./ImageStorage/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fm = FileManager()
        if !fm.fileExists(atPath: self.root) {
            do {
                try fm.createDirectory(at: URL(fileURLWithPath: self.root), withIntermediateDirectories: true, attributes: [:])
            } catch {
                print("Create directory failed")
            }
        }
        self.keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: {
            (event) -> NSEvent? in
            if ClipManager.shared.status != .off && event.keyCode == kVK_Escape {
                ClipManager.shared.end()
            }
            if ClipManager.shared.status == .off && event.modifierFlags.contains(.shift) {
                if event.keyCode == kVK_ANSI_A {
                    self.capture(NSDate.now.timestamp())
                }
            }
            return event
        })
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func shotButtonClickAction(_ sender: Any) {
        self.capture(NSDate.now.timestamp())
    }
    
    func capture(_ dest:String) -> Void {
        ClipManager.shared.start()
    }
    
}

extension Date {
    func timestamp() -> String {
        return String(Date().timeIntervalSince1970)
    }
}

