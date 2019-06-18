//
//  UIImageView.swift
//  Exercises
//
//  Created by Vitaly Badion on 5/30/19.
//  Copyright © 2019 Vitaly Badion. All rights reserved.
//

import UIKit

extension UIImageView {
    
    var imageColor: UIColor? {
        get { return tintColor }
        
        set {
            guard let image = image else { return }
            if newValue != nil {
                self.image = image.withRenderingMode(.alwaysTemplate)
                tintColor = newValue
            } else {
                self.image = image.withRenderingMode(.alwaysOriginal)
                tintColor = UIColor.clear
            }
        }
    }
}
