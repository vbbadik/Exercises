//
//  TableViewController.swift
//  Exercise
//
//  Created by Vitaly Badion on 10.06.2018.
//  Copyright © 2018 Vitaly Badion. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    
//    var exercises = ["Push-Ups", "Pull-Ups", "Sit-Ups","Push-Ups", "Pull-Ups", "Sit-Ups"]
    var exercises = [Exercise]()
    fileprivate let identifierCell = "ExersiceCell"
    weak var actionButtonInACToEnable : UIAlertAction?
    var name: String?
    var sets: [Set]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("Exercises", comment: "Exercises")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addExerciseTapButton(sender:)))
        navigationItem.rightBarButtonItem = editButtonItem //UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(goToEditTable))

        
        //navigationItem.rightBarButtonItem?.action = #selector(goToEditTable)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifierCell)
        
        exercises = [Exercise(name: "Push-Ups"),
                     Exercise(name: "Sit-Ups"),
                     Exercise(name: "Pull-Ups")]

        
//        exercises = [Exercise(name: "Push-Ups", sets: nil),
//                     Exercise(name: "Pull-Ups", sets: nil),
//                     Exercise(name: "Sit-Ups", sets: nil),
//                     Exercise(name: "Push-Ups", sets: nil),
//                     Exercise(name: "Pull-Ups", sets: nil),
//                     Exercise(name: "Sit-Ups", sets: nil)]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        actionButtonInACToEnable = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Actions

    // Действие при нажатии кнопки "Edit" в Navigation Bar
//    @objc func goToEditTable() {
//        tableView.isEditing = !tableView.isEditing
//        if tableView.isEditing {
//            setEditing(true, animated: true)
//        } else {
//            setEditing(false, animated: true)
//        }
//    }
    
    // Действие при нажатии кнопки "Add Exercise" - Добавление нового упражениния с помощью активации кнопки добавить, если поле не пустое
    @objc fileprivate func addExerciseTapButton(sender: UIButton) {
        let alertTitle = NSLocalizedString("Add Exercise", comment: "Add Exercise")
        let placeholderTitle = NSLocalizedString("Enter name exercise", comment: "Name exercise")
        let addTitleButton = NSLocalizedString("Add", comment: "Add button")
        let cancelTitleButton = NSLocalizedString("Cancel", comment: "Cancel")
        
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { [weak self] textField in
            textField.placeholder = placeholderTitle
            self?.textFieldProperty(textField)
            textField.addTarget(self, action: #selector(self?.textChanged(sender:)), for: .editingChanged)
        })
        
        let add = UIAlertAction(title: addTitleButton, style: .default, handler: { action in
            let exercise = alert.textFields!.first?.text
            if let newExercise = exercise {
                let addNewExersice = Exercise(name: newExercise)//, sets: nil)
                self.exercises.append(addNewExersice)
                self.tableView.reloadData()
            }
        })
        
        let cancel = UIAlertAction(title: cancelTitleButton, style: .cancel, handler: nil)
        
        alert.addAction(add)
        alert.addAction(cancel)
        
        self.actionButtonInACToEnable = add
        add.isEnabled = false
        self.present(alert, animated: true, completion: nil)
    }
    
    // Активация кнопки "Add" в Alert Controller
    @objc fileprivate func textChanged(sender: UITextField) {
        if sender.text?.isEmpty == false && sender.text != nil {
            self.actionButtonInACToEnable!.isEnabled = true
        } else {
            self.actionButtonInACToEnable!.isEnabled = false
        }
    }
    
    //MARK: - Table view Data source & Delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return exercises.count
    }
    
    // Добавление ячеек в таблицу для отображения на экране устройства
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifierCell, for: indexPath)
        
        cell.textLabel?.text = exercises[indexPath.row].name
        
        return cell
    }
    
    // Реализация действий для всмахивания с правой стороны экрана
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: NSLocalizedString("Delete", comment: "Delete")) { (action, indexPath) in
            self.exercises.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let edit = UITableViewRowAction(style: .normal, title: NSLocalizedString("Edit", comment: "Edit")) { (action, indexPath) in
            let ac = UIAlertController(title: NSLocalizedString("Editing", comment: "Editing"), message: NSLocalizedString("Enter a new name", comment: "Enter a new name"), preferredStyle: .alert)
            ac.addTextField(configurationHandler: { (textField) in
                self.textFieldProperty(textField)
                textField.text = self.exercises[indexPath.row].name
                textField.addTarget(self, action: #selector(self.textChanged(sender:)), for: .editingChanged)
            })
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                if let newNameOfExercise = ac.textFields?.first?.text {
                    self.exercises[indexPath.row].name = newNameOfExercise
                    tableView.reloadData()
                }
                
            })
            let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
            
            ac.addAction(ok)
            ac.addAction(cancel)
            self.actionButtonInACToEnable = ok
            ok.isEnabled = true
            self.present(ac, animated: true, completion: nil)
        }
        
        delete.backgroundColor = .red
        edit.backgroundColor = .blue
        return [delete, edit]
    }
    
    // Снимаем выделение с ячейки и переходим на Second View Controller
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let exercise = exercises[indexPath.row]
        sets = [Set]()
        let detailExercise = DetailExerciseViewController()
        detailExercise.selectedExercise = exercise.name
        detailExercise.sets = exercise.sets
        // Получение информации о выполненных повторениях управжнения из Detail View Controller
        detailExercise.competionHandler = { [weak self] sets in
            self!.exercises[indexPath.row].sets = sets
        }
        // Замена кнопки возврата обратно в Main View Controller с "Упражнения" на "Назад"
//        let backItem = UIBarButtonItem()
//        backItem.title = "Back"
//        navigationItem.backBarButtonItem = backItem
        // Переход на Detail Exercise View Controller
        navigationController?.pushViewController(detailExercise, animated: true)
    }
    
    // Реализовываем перетаскивание ячеек в таблице
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moveExercise = exercises[sourceIndexPath.row]
        exercises.remove(at: sourceIndexPath.row)
        exercises.insert(moveExercise, at: destinationIndexPath.row)
        
    }
    
//     // Override to support conditional editing of the table view.
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }
//
//
//
//     // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            self.exercises.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .none {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
//    }
    
    
    //MARK: - Rotation
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}

// MARK: - Property for Text Field
extension MainViewController: UITextInputTraits {
    fileprivate func textFieldProperty(_ textField: UITextField) {
        //textField.clearsOnBeginEditing = true
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .yes
        textField.keyboardAppearance = .dark
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
    }
}

//MARK: - TextField Delegate
extension MainViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.clearButtonMode = .whileEditing
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - Shadow for button
extension UIView {
    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        let layer = self.layer
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        
        let backgroundCGColor = self.backgroundColor?.cgColor
        self.backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
}

//extension UserDefaults {
//    // Сохранение данных
//    func setExercise(exercise: [Exercise]?, forKey key: String) {
//        var exerciseData: NSData?
//        if let exercise = exercise {
//            exerciseData = NSKeyedArchiver.archivedData(withRootObject: exercise) as NSData?
//        }
//        set([exerciseData], forKey: key)// UserDefault Built-in Method into Any?
//    }
//    // Извлечение данных
//    func exerciseForKey(key: String) -> Exercise? {
//        var exercise: Exercise?
//        if let exerciseData = data(forKey: key) {
//            exercise = NSKeyedUnarchiver.unarchiveObject(with: exerciseData) as? Exercise
//        }
//        return exercise
//    }
//}
