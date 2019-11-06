//
//  ViewController.swift
//  DeepLabTest
//
//  Created by Koki Ibukuro on 2019/11/05.
//  Copyright © 2019 Koki Ibukuro. All rights reserved.
//

import Cocoa
import CoreML
import Vision


class ViewController: NSViewController {
    
    @IBOutlet weak var sourceImageView: NSImageView!
    @IBOutlet weak var resultImageView: NSImageView!
    
    var unity = UnityCoreML()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resultImageView.alphaValue = 0.5
        
        unity.delegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func processImage(_ url: URL) {
        unity.predict(url)
        self.sourceImageView.image = NSImage(contentsOf: url)
    }

    @IBAction func loadButtonClick(_ sender: Any) {
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["jpg", "png"]
        
        panel.begin { (result) in
            if result.rawValue != NSApplication.ModalResponse.OK.rawValue {
                return
            }
            guard let url = panel.url else {
                return
            }
            self.processImage(url)
            
        }
    }
}

extension ViewController: UnityCoreMLResultDelegate {
    public func onUnityCoreMLResult(array:MLMultiArray) {
        guard let image = ColorTables.toDeepLabV3(array, width: 513, height: 513) else {
            return
        }
        
        let size = NSSize(width: image.width, height: image.height)
        self.resultImageView.image = NSImage(cgImage: image, size: size)
    }
}
