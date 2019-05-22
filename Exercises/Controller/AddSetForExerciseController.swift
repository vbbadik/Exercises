//
//  PickerView.swift
//  Exercises
//
//  Created by Vitaly Badion on 9/25/18.
//  Copyright © 2018 Vitaly Badion. All rights reserved.
//

protocol SelectedRepsDelegate: class {
    func sendReps(number: Int)
}

import UIKit

class AddSetForExerciseController: UIViewController {
    
    weak var delegate: SelectedRepsDelegate?
    
    private let frameView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let colorHeaderForFrame: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.8823529412, green: 0.8823529412, blue: 0.8823529412, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Done", comment: "Done"), for: .normal)
        button.contentHorizontalAlignment = .right
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), for: .normal)
        button.contentHorizontalAlignment = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let picker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        
        addView()
        viewConstraints()
    }
    
    private func addView(){
        let arrayView = [frameView, saveButton, cancelButton]
        for item in arrayView {
            view.addSubview(item)
        }
        
        frameView.addSubview(picker)
        frameView.addSubview(colorHeaderForFrame)
        
        picker.dataSource = self
        picker.delegate = self
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    private func viewConstraints() {
        // Ограничения
        // Frame View
        let frameHeight = frameView.heightAnchor.constraint(equalToConstant: view.bounds.height / 3)
        let frameWidth = frameView.widthAnchor.constraint(equalToConstant: view.bounds.width)
        let frameLeft = frameView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        let frameRight = frameView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        let frameBottom = frameView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        NSLayoutConstraint.activate([frameWidth, frameHeight, frameLeft, frameRight, frameBottom])
        
        // Save Button
        saveButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        saveButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor, multiplier: 1).isActive = true
        frameView.trailingAnchor.constraint(equalTo:saveButton.trailingAnchor,  constant: 15).isActive = true
        saveButton.topAnchor.constraint(equalTo: frameView.topAnchor).isActive = true
        
        // Cancel Button
        cancelButton.heightAnchor.constraint(equalTo: saveButton.heightAnchor, multiplier: 1).isActive = true
        cancelButton.widthAnchor.constraint(equalTo: saveButton.widthAnchor, multiplier: 1).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: frameView.leadingAnchor, constant: 15).isActive = true
        cancelButton.topAnchor.constraint(equalTo: frameView.topAnchor).isActive = true
        
        // Picker
        picker.leadingAnchor.constraint(equalTo: frameView.leadingAnchor).isActive = true
        picker.trailingAnchor.constraint(equalTo: frameView.trailingAnchor).isActive = true
        picker.topAnchor.constraint(equalTo: frameView.topAnchor, constant: 20).isActive = true
        
        // Color Header for Frame
        colorHeaderForFrame.heightAnchor.constraint(equalTo: saveButton.heightAnchor, multiplier: 1).isActive = true
        colorHeaderForFrame.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 1).isActive = true
        colorHeaderForFrame.leadingAnchor.constraint(equalTo: frameView.leadingAnchor).isActive = true
        colorHeaderForFrame.trailingAnchor.constraint(equalTo: frameView.trailingAnchor).isActive = true
        colorHeaderForFrame.topAnchor.constraint(equalTo: frameView.topAnchor).isActive = true
    }

    //MARK: - Action
    
    @objc private func saveButtonTapped() {
        dismiss(animated: true) {
            let reps = self.picker.selectedRow(inComponent: 0) * 10 + self.picker.selectedRow(inComponent: 1)// + 1
            self.delegate?.sendReps(number: reps)
        }
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: false, completion: nil)
    }
    
}

extension AddSetForExerciseController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
}

extension AddSetForExerciseController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        let result = "\(row + 1)"
//        return result
        return String(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return CGFloat(30)
    }
}
