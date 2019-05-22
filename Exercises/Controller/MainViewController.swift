//
//  TableViewController.swift
//  Exercise
//
//  Created by Vitaly Badion on 10.06.2018.
//  Copyright © 2018 Vitaly Badion. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {
    
    fileprivate var exercises: Results<Exercise>?
    fileprivate final let identifierCell = "ExersiceCell"
//    fileprivate lazy var realm = try! Realm()
//    fileprivate lazy var realm = try! Realm(configuration: RealmConfig.exerciseRealmConfig) // использоварие своего файла конфигурации Realm для легкой миграции
    fileprivate weak var actionButtonInACToEnable : UIAlertAction?
    
    // Переменные для передачи данных между контроллерами
    fileprivate var name: String?
    
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
    fileprivate func save(exercise: Exercise) {
        DispatchQueue(label: "realmQueue").sync {
            do {
                let realm = try Realm()
                //    let realm = try Realm(configuration: RealmConfig.exerciseRealmConfig) // использоварие своего файла конфигурации Realm для легкой миграции
                try realm.write {
                    realm.add(exercise)
                }
            } catch {
                fatalError("Saving failed \(error)")
            }
        }
        tableView.reloadData()
    }

    // Загрузка упражений
    fileprivate func loadExercises() {
        do {
            let realm = try Realm()
            //                let realm = try Realm(configuration: RealmConfig.exerciseRealmConfig) // использоварие своего файла конфигурации Realm для легкой миграции
            self.exercises = realm.objects(Exercise.self).sorted(byKeyPath: "id")
        } catch {
            debugPrint("Exercise loading failed!")
        }
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
            
            guard let titleExercise = alert.textFields?.first?.text else {
                fatalError("Text Field is empty!")
            }
            
            let newExercise = Exercise(name: titleExercise)

            self.save(exercise: newExercise)
            
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
        return exercises?.count ?? 1
    }
    
    // Добавление ячеек в таблицу для отображения на экране устройства
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifierCell, for: indexPath)
        
        cell.textLabel?.text = exercises?[indexPath.row].name
        
        return cell
    }
    
    //MARK: - TableView Delegate methods
    
    // Реализация действий для всмахивания с правой стороны экрана
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .default, title: NSLocalizedString("Delete", comment: "Delete")) { (action, indexPath) in
            
            if let deleteExercise = self.exercises?[indexPath.row] {
                do {
                    let realm = try Realm()
                    //    let realm = try Realm(configuration: RealmConfig.exerciseRealmConfig) // использоварие своего файла конфигурации Realm для легкой миграции
                    try realm.write {
                        // Если используется связь между Exercise и Set
//                        if !deleteExercise.sets.isEmpty {
//                            
//                            for set in deleteExercise.sets {
//                                realm.delete(set.reps)
//                            }
//                            
//                            realm.delete(deleteExercise.sets)
//                        }
                        
                        // Если между Exercise и Set нет связи

                        let exerciseSets = realm.objects(Set.self).filter("exercise = %@", deleteExercise)
                            
                        for set in exerciseSets {
                            realm.delete(set.reps)
                            realm.delete(set)
                        }

                        realm.delete(deleteExercise)
                    }
                } catch {
                    fatalError("Can't delete exercise! \(error)")
                }
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let edit = UITableViewRowAction(style: .normal, title: NSLocalizedString("Edit", comment: "Edit")) { (action, indexPath) in
            
            let ac = UIAlertController(title: NSLocalizedString("Editing", comment: "Editing"), message: NSLocalizedString("Enter a new name", comment: "Enter a new name"), preferredStyle: .alert)
            
            ac.addTextField(configurationHandler: { textField in
                self.textFieldProperty(textField)
                textField.text = self.exercises?[indexPath.row].name
                textField.addTarget(self, action: #selector(self.textChanged(sender:)), for: .editingChanged)
            })
            
            let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                if let newNameOfExercise = ac.textFields?.first?.text,
                   let exercise = self.exercises?[indexPath.row]  {
                    
                    RealmPerform.action(.update, for: exercise, with: newNameOfExercise)

                }
                self.tableView.reloadData()
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
        
        guard let exercise = exercises?[indexPath.row] else {
            fatalError("Can't get exercise")
        }
        
        let detailExercise = DetailExerciseViewController()
        detailExercise.selectedExercise = exercise
        
        tableView.deselectRow(at: indexPath, animated: true)
        
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
        if let sourceObject = exercises?[sourceIndexPath.row], let destinationObject = exercises?[destinationIndexPath.row] {
            let destinationObjectName = destinationObject.name

//            DispatchQueue(label: "realmQueue").sync {
                do {
                    let realm = try Realm()
//                    let realm = try Realm(configuration: RealmConfig.exerciseRealmConfig) // использоварие своего файла конфигурации Realm для легкой миграции
                    try realm.write {
//                        if sourceIndexPath.row < destinationIndexPath.row {
//                            for index in sourceIndexPath.row...destinationIndexPath.row {
//                                let object = exercises?[index]
//                                object?.id += 1
//                            }
//                        } else if sourceIndexPath.row > destinationIndexPath.row {
//                            for index in (destinationIndexPath.row..<sourceIndexPath.row).reversed() {
//                                let object = exercises?[index]
//                                object?.id -= 1
//                            }
//                        }
                        destinationObject.name = sourceObject.name
                        sourceObject.name = destinationObjectName
                    }
                } catch {
                    fatalError("Can't move a exercise")
                }
//            }
        }
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
