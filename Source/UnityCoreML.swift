//
//  UnityCoreML.swift
//  DeepLabTest_macOS
//
//  Created by Koki Ibukuro on 2019/11/06.
//  Copyright © 2019 Koki Ibukuro. All rights reserved.
//


import CoreImage
import CoreML
import Vision
import MetalKit

@objc public protocol UnityCoreMLResultDelegate: AnyObject {
    func onUnityCoreMLResult(array:MLMultiArray)
}

@objc public class UnityCoreML: NSObject {
    
    public var delegate: UnityCoreMLResultDelegate?
    public var scaleOption: VNImageCropAndScaleOption = .centerCrop
    
    private var model: VNCoreMLModel?

    
    /** Load *.mlmodel file
     */
    public func loadModel(_ url: URL) {
        guard let mlmodel = try? MLModel(contentsOf: url),
            let model = try? VNCoreMLModel(for: mlmodel) else {
            fatalError()
        }
        self.model = model
        print("model loaded: ", url)
    }
    
    /** Predict from image url
     */
    public func predict(url: URL) {
        let handler = VNImageRequestHandler(url: url)
        self.predict(handler: handler)
    }

    /** Predict from raw image buffer (for Unity plugin)
     */
    public func predict(texture: MTLTexture) {
        
        // https://ringsbell.blog.fc2.com/blog-entry-1319.html
        guard let image = CIImage(mtlTexture: texture, options: nil) else {
            print("texture could not loaded")
            return
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        self.predict(handler: handler)
    }
    
    private func predict(handler: VNImageRequestHandler) {
        guard let model = self.model else {
            print("model is not loaded")
            return
        }
        
        let request = VNCoreMLRequest(model: model, completionHandler: self.onVisionRequestComplete)
        request.imageCropAndScaleOption = self.scaleOption
        
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
