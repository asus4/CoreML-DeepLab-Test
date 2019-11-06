//
//  UnityCoreML.swift
//  DeepLabTest_macOS
//
//  Created by Koki Ibukuro on 2019/11/06.
//  Copyright © 2019 Koki Ibukuro. All rights reserved.
//


import CoreML
import Vision

protocol UnityCoreMLResultDelegate: AnyObject {
    func onUnityCoreMLResult(array:MLMultiArray)
}

struct UnityCoreML {
    
    let model: VNCoreMLModel
    public var delegate: UnityCoreMLResultDelegate?
    
    init() {
        guard let model = try? VNCoreMLModel(for: DeepLabV3().model) else {
            fatalError()
        }
        self.model = model
    }
    
    public func predict(_ url: URL) {
        let request = VNCoreMLRequest(model: self.model, completionHandler: onVisionRequestComplete)
        request.imageCropAndScaleOption = .centerCrop
        
        let handler = VNImageRequestHandler(url: url, options: [:])
        try? handler.perform([request])
    }
    
    private func onVisionRequestComplete(request: VNRequest, error: Error?) {
        
        guard let observations = request.results as? [VNCoreMLFeatureValueObservation],
              let depth = observations.first?.featureValue.multiArrayValue else {
            print("ML request fail")
            return
        }
        
        if self.delegate != nil {
            self.delegate?.onUnityCoreMLResult(array: depth)
            return
        }
    }
    
    public static func arrayToCGImage(_ arr: MLMultiArray) -> CGImage? {
        //
        let width = 513
        let height = 513
        var data: [UInt8] = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0 ..< height {
            for x in 0 ..< width {
                let i = y * width + x
                let table = ColorTables.DeepLabV3[arr[i].intValue]
                data[i * 4 + 0] = table[0]
                data[i * 4 + 1] = table[1]
                data[i * 4 + 2] = table[2]
                data[i * 4 + 3] = 255
            }
        }
        
        // Try to get image
        var image: CGImage?
        data.withUnsafeBytes { ptr in
            let context = CGContext(data: UnsafeMutableRawPointer(mutating: ptr.baseAddress!),
                                    width: width,
                                    height: height,
                                    bitsPerComponent: 8,
                                    bytesPerRow: width * 4,
                                    space: CGColorSpaceCreateDeviceRGB(),
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            image = context?.makeImage()
        }
        return image
    }
}
