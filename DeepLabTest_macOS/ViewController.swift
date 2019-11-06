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
    
    var model: VNCoreMLModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resultImageView.alphaValue = 0.5
        
        guard let model = (try? VNCoreMLModel(for: DeepLabV3().model)) else {
            // Could not load MLModel
            // Check "FCRN.mlmodel" exists in your project
            fatalError()
        }
        self.model = model
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func processImage(_ url: URL) {
        print("process image", url)
        
        
        let request = VNCoreMLRequest(model: self.model, completionHandler: onVisionRequestComplete)
        request.imageCropAndScaleOption = .centerCrop
        
        let handler = VNImageRequestHandler(url: url, options: [:])
        try? handler.perform([request])
        
        
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
    
    private func onVisionRequestComplete(request: VNRequest, error: Error?) {
        
        guard let observations = request.results as? [VNCoreMLFeatureValueObservation],
              let depth = observations.first?.featureValue.multiArrayValue else {
            return
        }
        
        //
        let width = 513
        let height = 513
        var data: [UInt8] = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0 ..< height {
            for x in 0 ..< width {
                let i = y * width + x
                let table = ColorTables.DeepLabV3[depth[i].intValue]
                data[i * 4 + 0] = table[0]
                data[i * 4 + 1] = table[1]
                data[i * 4 + 2] = table[2]
                data[i * 4 + 3] = 255
            }
        }
        
        data.withUnsafeBytes { ptr in
            let context = CGContext(data: UnsafeMutableRawPointer(mutating: ptr.baseAddress!),
                                    width: width,
                                    height: height,
                                    bitsPerComponent: 8,
                                    bytesPerRow: width * 4,
                                    space: CGColorSpaceCreateDeviceRGB(),
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            guard let image = context?.makeImage() else  {
                print("no image")
                return
            }
            self.resultImageView.image = NSImage(cgImage: image, size: NSSize(width: width, height: height))
        }
        
    }
    
    
    
}

