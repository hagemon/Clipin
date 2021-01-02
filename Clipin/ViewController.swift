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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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


