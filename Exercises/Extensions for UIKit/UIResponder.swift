//
//  UIResponder.swift
//  Exercises
//
//  Created by Vitaly Badion on 5/25/19.
//  Copyright © 2019 Vitaly Badion. All rights reserved.
//

import UIKit

extension UIResponder {
    
    /// The responder chain from the target responder (self)
    ///     to the `UIApplication` and the app delegate
    var responderChain: [UIResponder] {
        var responderChain: [UIResponder] = []
        var currentResponder: UIResponder? = self
        
        while currentResponder != nil {
            responderChain.append(currentResponder!)
            currentResponder = currentResponder?.next
        }
        
        return responderChain
    }
}
