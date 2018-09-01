//
//  ViewController.swift
//  DemoML
//
//  Created by Charles Martin Reed on 9/1/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "test.jpg")!
        
        //images should be given at whatever size they were trained at: Googleplaces-205 is 224x224.
        //1
        let modelSize = 224
        UIGraphicsBeginImageContextWithOptions(CGSize(width: modelSize, height: modelSize), true, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: modelSize, height: modelSize))
        
        //this gives us a new UIImage, from the old image but resized properly for our model
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //convert from UIImage to CVPixelBuffer, which CoreML needs
        //might want to wrap this in a helper function if you need to re-use it
        //2
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else { return }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: newImage.size.height)
        context?.scaleBy(x: 1.1, y: -1.0)
        
        UIGraphicsPushContext(context!)
        newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        //instantiate the model class and pass it the buffer image
        //3
        let model = GoogLeNetPlaces()
        guard let prediction = try? model.prediction(sceneImage: pixelBuffer!) else { return }
        print(prediction.sceneLabel)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

