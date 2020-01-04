//
//  Functions.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 7/24/19.
//  Copyright © 2019 William  Uchegbu. All rights reserved.
//

import Foundation
import UIKit

func blurImage(usingImage image: UIImage, blurAmount: CGFloat) -> UIImage? {
    guard let ciImage = CIImage(image: image) else{
        return nil
    }
    
    let blurFilter = CIFilter(name: "CIGaussianBLur")
    blurFilter?.setValue(ciImage, forKey: kCIInputImageKey)
    blurFilter?.setValue(blurAmount, forKey: kCIInputRadiusKey)
    
    guard let outputImage = blurFilter?.outputImage else {return nil}
    return UIImage(ciImage: outputImage)
}

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 10.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}

func flipImageDown(theImage: UIImage) -> UIImage {
    return UIImage(cgImage: theImage.cgImage!, scale: theImage.scale, orientation: UIImage.Orientation.downMirrored)
}

func openWarningAlert(){
    
}

func openStringInputAlert(vc: UIViewController, title: String, message: String){
    var input = String()
    let alert  = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addTextField(configurationHandler: {(textField) in
        input = textField.text ?? ""
    })
    
    vc.present(vc, animated: true, completion: nil)
    
    
    
}

func openBoolInputAlert(vc: UIViewController, title: String, message: String)->Bool{
    var response: Bool?
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: {(action) in response = true})
    let noAction = UIAlertAction(title: "No", style: .default, handler: {(action) in response = false})
    
    alert.addAction(yesAction)
    alert.addAction(noAction)
    vc.present(alert, animated: true)
    while(true){if response==true || response==false{break}}
    return response!
}
