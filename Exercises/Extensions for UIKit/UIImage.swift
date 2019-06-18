//
//  UIImage.swift
//  Exercises
//
//  Created by Vitaly Badion on 5/30/19.
//  Copyright © 2019 Vitaly Badion. All rights reserved.
//

import UIKit

extension UIImage {
    
    convenience init?(imageName: String) {
        self.init(named: imageName)
        accessibilityIdentifier = imageName
    }
    
    // /questions/110361/change-color-of-png-in-buttons-ios/688577#688577
    final func imageWithColor(_ newColor: UIColor?) -> UIImage? {
        
        if let newColor = newColor {
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            
            let getContext = UIGraphicsGetCurrentContext()
            
            guard let context = getContext else { return self }
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.setBlendMode(.normal)
            
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            context.clip(to: rect, mask: cgImage!)
            
            newColor.setFill()
            context.fill(rect)
            
            let getImage = UIGraphicsGetImageFromCurrentImageContext()
            
            guard let newImage = getImage else { return self }
            UIGraphicsEndImageContext()
            newImage.accessibilityIdentifier = accessibilityIdentifier
            return newImage
        }
        
        if let accessibilityIdentifier = accessibilityIdentifier {
            return UIImage(imageName: accessibilityIdentifier)
        }
        
        return self
    }
}
