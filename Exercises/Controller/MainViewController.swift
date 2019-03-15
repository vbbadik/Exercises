//
//  TableViewController.swift
//  Exercise
//
//  Created by Vitaly Badion on 10.06.2018.
//  Copyright © 2018 Vitaly Badion. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    
    var exercises = [Exercise]()
    final let identifierCell = "ExersiceCell"
    fileprivate let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Exercises.plist")
    fileprivate weak var actionButtonInACToEnable : UIAlertAction?
    
    // Переменные для передачи данных между контроллерами
    var name: String?
    var sets: [Set]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Название упражнения отображаемое в Navigation Bar
        navigationItem.title = NSLocalizedString("Exercises", comment: "Exercises")
        
        // Добавление кнопок "Добавить" и "Редактировать"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addExerciseTapButton(sender:)))
        navigationItem.rightBarButtonItem = editButtonItem //UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(goToEditTable))

        
        //navigationItem.rightBarButtonItem?.action = #selector(goToEditTable)
        
        // Большие названия в навигационной панели
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Регистрируем ячейку для таблицы
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifierCell)
        
        // Загружаем упражения
        loadExercises()

    }
    
    //MARK: - Saving and Loading Exercises from device memory
    
    // Сохранение упражения
    fileprivate func saveExercises() {

        // Использование глобального метода сохранения
        let data = SaveAndLoadData<Exercise>()
        
        if let file = dataFilePath {
            data.save(exercises, to: file)
        }
        
//        // Codable protocol
//        let encoder = PropertyListEncoder()
//
//        do {
//            let data = try encoder.encode(exercises)
//            try data.write(to: dataFilePath!)
//        } catch {
//            fatalError("Save failed \(error)")
//        }

        tableView.reloadData()
    }

    // Загрузка упражений
    fileprivate func loadExercises() {
        
        // Использование глобального метода загрузки
        let data = SaveAndLoadData<Exercise>()
        
        if let file = dataFilePath {
            exercises = data.load(from: file)
        }

//        // Codable protocol
//        guard let data = try? Data(contentsOf: dataFilePath!) else { return }
//        let decoder = PropertyListDecoder()
//
//        do {
//            exercises = try decoder.decode([Exercise].self, from: data)
//        } catch {
//            fatalError("Load failed \(error)")
//        }
    }
    
    //MARK: - Actions

    // Действие при нажатии кнопки "Edit" в Navigation Bar
    @objc func goToEditTable() {
        tableView.isEditing = !tableView.isEditing
        if tableView.isEditing {
            setEditing(true, animated: true)
        } else {
            setEditing(false, animated: true)
        }
    }
    
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
        
        let add = UIAlertAction(title: addTitleButton, style: .default) { action in
            
            guard let exercise = alert.textFields?.first?.text else {
                fatalError("Text Field is empty!")
            }
            
            let addNewExersice = Exercise(name: exercise)
            self.exercises.append(addNewExersice)
            self.saveExercises()
            
        }
        
        let cancel = UIAlertAction(title: cancelTitleButton, style: .cancel)
        
        alert.addAction(add)
        alert.addAction(cancel)
        
        self.actionButtonInACToEnable = add
        add.isEnabled = false
        
        self.present(alert, animated: true)
    }
    
    // Активация кнопки "Add" в Alert Controller
    @objc fileprivate func textChanged(sender: UITextField) {
        if sender.text?.isEmpty == false && sender.text != nil {
            self.actionButtonInACToEnable!.isEnabled = true
        } else {
            self.actionButtonInACToEnable!.isEnabled = false
        }
    }
    
    //MARK: - Rotation device
    
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

//MARK: - TableView DataSource & Delegate

extension MainViewController {
    
    //MARK: - TableView DataSource methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    
    //MARK: - TableView Delegate methods
    
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
            self.saveExercises()
        }
        
        let edit = UITableViewRowAction(style: .normal, title: NSLocalizedString("Edit", comment: "Edit")) { (action, indexPath) in
            
            let ac = UIAlertController(title: NSLocalizedString("Editing", comment: "Editing"), message: NSLocalizedString("Enter a new name", comment: "Enter a new name"), preferredStyle: .alert)
            
            ac.addTextField(configurationHandler: { textField in
                self.textFieldProperty(textField)
                textField.text = self.exercises[indexPath.row].name
                textField.addTarget(self, action: #selector(self.textChanged(sender:)), for: .editingChanged)
            })
            
            let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                if let newNameOfExercise = ac.textFields?.first?.text {
                    self.exercises[indexPath.row].name = newNameOfExercise
                    self.saveExercises()
                }
                
            })
            
            let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel)
            
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
            self?.exercises[indexPath.row].sets = sets
            self?.saveExercises()
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
        saveExercises()
    }
}

//MARK: - Property for TextField

extension MainViewController: UITextInputTraits {
    
    fileprivate func textFieldProperty(_ textField: UITextField) {
        //textField.clearsOnBeginEditing = true
        textField.autocapitalizationType = .sentences
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
