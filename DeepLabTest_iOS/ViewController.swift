//
//  ViewController.swift
//  DeepLabTest_iOS
//
//  Created by Koki Ibukuro on 2019/11/05.
//  Copyright © 2019 Koki Ibukuro. All rights reserved.
//

import UIKit
import CoreML
import Vision



class ViewController: UIViewController {

    @IBOutlet weak var sourceImageView: UIImageView!
    @IBOutlet weak var resultImageView: UIImageView!
    
    var model: VNCoreMLModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let model = (try? VNCoreMLModel(for: DeepLabV3().model)) else {
            // Could not load MLModel
            // Check "FCRN.mlmodel" exists in your project
            fatalError()
        }
        self.model = model
    }

    @IBAction func onLoadImage(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true)
    }
    
    func processImage(_ url: URL) {
        print("process image", url)
            
            
        let request = VNCoreMLRequest(model: self.model, completionHandler: onVisionRequestComplete)
        request.imageCropAndScaleOption = .centerCrop
            
        let handler = VNImageRequestHandler(url: url, options: [:])
        try? handler.perform([request])
            
        guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else {
            return
        }
        self.sourceImageView.image = UIImage(data: data)
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
            self.resultImageView.image = UIImage(cgImage: image)
        }
        
    }
  
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            picker.dismiss(animated: true)
        }
        
        guard let url = info[.imageURL] as? URL else {
            return
        }
        
        self.processImage(url)
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("did cancel")
        picker.dismiss(animated: true)
  }
}

