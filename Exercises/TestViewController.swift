//
//  TestViewController.swift
//  Exercises
//
//  Created by Vitaly Badion on 13.09.2018.
//  Copyright © 2018 Vitaly Badion. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    

    var textLabel = "Test"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        //view.addSubview(textLabel)
        
        let buttonBack = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        buttonBack.setTitle("Назад", for: .normal)
        buttonBack.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        view.addSubview(buttonBack)
        
        
        
        navigationItem.title = "Test"
    
        print(textLabel)
    }
    @objc func goBack() {
    var controllersAray = self.navigationController?.viewControllers
    controllersAray?.removeLast()
        if let newController = controllersAray {
            self.navigationController?.viewControllers = newController
        }
//        navigationController?.popToViewController(DetailViewController(), animated: true)
//        navigationController?.popViewController(animated: true)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
