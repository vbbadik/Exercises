//
//  AddButton.swift
//  Exercises
//
//  Created by Vitaly Badion on 5/23/19.
//  Copyright © 2019 Vitaly Badion. All rights reserved.
//

import UIKit

class SetButton: UIViewController {
    typealias handlerConstraints = () -> ()
    
    var exerciseButton = UIButton()
    fileprivate var regularConstraints = [NSLayoutConstraint]()
    fileprivate var compactConstraints = [NSLayoutConstraint]()
    
    fileprivate var sizeButton: CGFloat {
        return 60
    }
    
    // Create AddSet button
    func setButton() {
        exerciseButton.frame.size = CGSize(width: sizeButton, height: sizeButton)
        exerciseButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exerciseButton)
    }
    
    func customizeButton() {
        exerciseButton.setTitle("+", for: .normal)
        exerciseButton.setTitleColor(.white, for: .normal)
        exerciseButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
        exerciseButton.titleEdgeInsets.top = -5
        exerciseButton.backgroundColor = #colorLiteral(red: 0.8462908864, green: 0.1336644292, blue: 0.1662362516, alpha: 1)
        exerciseButton.layer.cornerRadius = sizeButton / 2
        exerciseButton.addShadow(offset: CGSize.zero, color: .black, radius: 4, opacity: 0.25)
    }
    
    // Constraints for AddSet button
    func buttonConstraints(){
        let widthButton = exerciseButton.widthAnchor.constraint(equalToConstant: sizeButton)
        let heightButton = exerciseButton.heightAnchor.constraint(equalTo: exerciseButton.widthAnchor)
        let centerXButton = exerciseButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        let trailingButton = view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: exerciseButton.trailingAnchor, constant: 20)
        let bottomButton = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: exerciseButton.bottomAnchor, constant: 20)
        
        NSLayoutConstraint.activate([widthButton, heightButton, bottomButton])
        
        regularConstraints.append(centerXButton)
        compactConstraints.append(trailingButton)
    }
    
    // Activate constraints for class device
    func activateCurrentButtonConstrains() {
        NSLayoutConstraint.deactivate(regularConstraints + compactConstraints)
        
        if traitCollection.verticalSizeClass == .regular {
            NSLayoutConstraint.activate(regularConstraints)
        } else {
            NSLayoutConstraint.activate(compactConstraints)
        }
    }
}
