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
    
    var unity = UnityCoreML()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        unity.delegate = self
    }

    @IBAction func onLoadImage(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true)
    }
    
    func processImage(_ url: URL) {
        unity.predict(url)
        
        guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else {
            return
        }
        self.sourceImageView.image = UIImage(data: data)
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


extension ViewController: UnityCoreMLResultDelegate {
    public func onUnityCoreMLResult(array:MLMultiArray) {
        guard let image = ColorTables.toDeepLabV3(array, width: 513, height: 513) else {
            return
        }
        
        self.resultImageView.image = UIImage(cgImage: image)
    }
}


