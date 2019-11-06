//
//  UnityCoreML.swift
//  DeepLabTest_macOS
//
//  Created by Koki Ibukuro on 2019/11/06.
//  Copyright © 2019 Koki Ibukuro. All rights reserved.
//


import CoreML
import Vision

public protocol UnityCoreMLResultDelegate: AnyObject {
    func onUnityCoreMLResult(array:MLMultiArray)
}

public struct UnityCoreML {
    
    private let model: VNCoreMLModel
    public var delegate: UnityCoreMLResultDelegate?
    
    init() {
        guard let model = try? VNCoreMLModel(for: DeepLabV3().model) else {
            fatalError()
        }
        self.model = model
    }
    
    public func predict(_ url: URL) {
        print("process image: ", url)
        
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
}
