//
//  TableViewController.swift
//  Exercise
//
//  Created by Vitaly Badion on 10.06.2018.
//  Copyright © 2018 Vitaly Badion. All rights reserved.
//

import UIKit
import RealmSwift

final class ExercisesViewController: UITableViewController {
    
    fileprivate var exercises: Results<Exercise>?
//    fileprivate var listExercises: List<Exercise>?
    fileprivate final let identifierCell = "ExersiceCell"
    fileprivate weak var actionButtonInACToEnable : UIAlertAction?
    
    // Variables to pass data between controllers
    fileprivate var name: String?
    
    override func loadView() {
        super.loadView()
//        listExercises = List<Exercise>()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        // Register cell for table
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifierCell)
        
        loadExercises()
        
    }
    
    // MARK: - Methods

    // Loading exercises
    fileprivate func loadExercises() {
        DispatchQueue(label: "realmQueue").sync {
            do {
                let realm = try Realm()
//            let realm = try Realm(configuration: RealmConfig.exerciseRealmConfig) // использование своего файла конфигурации Realm для легкой миграции
                self.exercises = realm.objects(Exercise.self).sorted(byKeyPath: "sortID")
            } catch {
                debugPrint("Exercise loading failed!")
            }
            
            // If use listExercises
//            guard let exercises = self.exercises, let arrayExercises = self.listExercises else { return }
//            for item in exercises {
//                arrayExercises.append(item)
//            }
        }
    }
    
    fileprivate func setupNavigationBar() {
        // Title of the exercise in Navigation Bar
        navigationItem.title = localizedTitle("Exercises")
        
        // Adding Add and Edit button
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addExerciseTapButton(sender:)))
        navigationItem.rightBarButtonItem = editButtonItem//UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(goToEditTable))
        
//        navigationItem.rightBarButtonItem?.action = #selector(goToEditTable)
        
        // Large title in Navigation Bar
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    fileprivate func localizedTitle(_ title: String, comment: String? = nil) -> String {
        if let comment = comment {
            return NSLocalizedString(title, comment: comment)
        } else {
            return NSLocalizedString(title, comment: title)
        }
    }
    
    
    //MARK: - Actions

    // Action to tapping the Edit button on Navigation Bar
    @objc func goToEditTable() {
        tableView.isEditing = !tableView.isEditing
        if tableView.isEditing {
            setEditing(true, animated: true)
        } else {
            setEditing(false, animated: true)
        }
    }
    
    // Action to tapping the Add button - Adding a new exercise using the add button if the field is not empty
    @objc fileprivate func addExerciseTapButton(sender: UIButton) {
        
        let alertTitle = localizedTitle("Add Exercise")
        let placeholderTitle = localizedTitle("Enter name exercise", comment: "Name exercise")
        let addTitleButton = localizedTitle("Add", comment: "Add button")
        let cancelTitleButton = localizedTitle("Cancel", comment: "Cancel button")
        
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
            
            DispatchQueue(label: "realmQueue").sync {
                RealmPerform.action(.add, for: newExercise)
//                self.listExercises?.append(newExercise)
                self.tableView.reloadData()
            }
            
        }
        
        let cancel = UIAlertAction(title: cancelTitleButton, style: .cancel)
        
        alert.addAction(add)
        alert.addAction(cancel)
        
        self.actionButtonInACToEnable = add
        add.isEnabled = false
        
        self.present(alert, animated: true)
    }
    
    // Activation the Add button on Alert Controller
    @objc fileprivate func textChanged(sender: UITextField) {
        if sender.text?.isEmpty == false && sender.text != nil {
            self.actionButtonInACToEnable!.isEnabled = true
        } else {
            self.actionButtonInACToEnable!.isEnabled = false
        }
    }
}

// MARK: - TableView DataSource methods

extension ExercisesViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return listExercises?.count ?? 1
        return exercises?.count ?? 1
    }
    
    // Adding cells to a table to display on the device screen
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifierCell, for: indexPath)
        cell.textLabel?.text = exercises?[indexPath.row].name
//        cell.textLabel?.text = listExercises?[indexPath.row].name
        return cell
    }
}

// MARK: - TableView Delegate methods

extension ExercisesViewController {
    // Swipe action on the right side of the screen
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .default, title: localizedTitle("Delete")) { (action, indexPath) in
            
            if let deleteExercise = self.exercises?[indexPath.row] {
//            if let deleteExercise = self.listExercises?[indexPath.row] {
            
                // ver.1 - use closure
                DispatchQueue(label: "realmQueue").sync {
                    RealmPerform.action(.delete, for: deleteExercise) { realm in
                        // If use the relationship between Exercise and Sets
                        if !deleteExercise.sets.isEmpty {

                            for set in deleteExercise.sets {
                                realm.delete(set.reps)
                            }

                            realm.delete(deleteExercise.sets)
                        }
                        
                        // If there is no relationship between Exercise and Sets
//                        let exerciseSets = realm.objects(Set.self).filter("exercise == %@", deleteExercise)
//
//                        for set in exerciseSets {
//                            realm.delete(set.reps)
//                            realm.delete(set)
//                        }
                    }
                }
                
                // ver.2
//                DispatchQueue(label: "realmQueue").sync {
//                    RealmPerform.action(.delete, for: deleteExercise)
//                }
                
            }
//            self.listExercises?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let edit = UITableViewRowAction(style: .normal, title: localizedTitle("Edit")) { (action, indexPath) in
            
            let ac = UIAlertController(title: self.localizedTitle("Editing"), message: self.localizedTitle("Enter a new name"), preferredStyle: .alert)
            
            ac.addTextField(configurationHandler: { textField in
                self.textFieldProperty(textField)
                textField.text = self.exercises?[indexPath.row].name
                textField.addTarget(self, action: #selector(self.textChanged(sender:)), for: .editingChanged)
            })
            
            let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                if let newNameOfExercise = ac.textFields?.first?.text,
                   let exercise = self.exercises?[indexPath.row]  {
                    //ver.1
                    DispatchQueue(label: "realmQueue").sync {
                        RealmPerform.action(.update, additionalHandler: { _ in
                            exercise.name = newNameOfExercise
                        })
                    }
                    //ver.2
//                    DispatchQueue(label: "realmQueue").sync {
//                        RealmPerform.action(.update, for: exercise, with: newNameOfExercise)
//                    }
                }
                self.tableView.reloadData()
            })
            
            let cancel = UIAlertAction(title: self.localizedTitle("Cancel"), style: .cancel)
            
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
    
    // Remove the selection from cell and go to Second View Controller
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let exercise = exercises?[indexPath.row] else {
            fatalError("Can't get exercise")
        }
        
        let detailExercise = SetsViewController()
        detailExercise.selectedExercise = exercise
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Replacing the back button in the Main View Controller from "Exercise" to "Back"
//        let backItem = UIBarButtonItem()
//        backItem.title = "Back"
//        navigationItem.backBarButtonItem = backItem
        
        // Go to Detail Exercise View Controller
        navigationController?.pushViewController(detailExercise, animated: true)
    }
    
    // We implement dragging of cells in the table
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        guard let exercises = exercises else { return }

        DispatchQueue(label: "realmQueue").sync {
            RealmPerform.action(.move) { _ in
                let source = exercises[sourceIndexPath.row]
                let destinationID = exercises[destinationIndexPath.row].sortID
                
                if sourceIndexPath.row < destinationIndexPath.row {
                    for index in sourceIndexPath.row...destinationIndexPath.row {
                        let object = exercises[index]
                        object.sortID -= 1
                    }
                } else {
                    for index in (destinationIndexPath.row..<sourceIndexPath.row).reversed() {
                        let oblect = exercises[index]
                        oblect.sortID += 1
                    }
                }
                source.sortID = destinationID
            }
        }
    
//        DispatchQueue(label: "realmQueue").sync {
//            RealmPerform.move(exercises, from: sourceIndexPath, to: destinationIndexPath)
//        }
        
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

// MARK: - Property for TextField

extension ExercisesViewController: UITextInputTraits {
    
    fileprivate func textFieldProperty(_ textField: UITextField) {
        //textField.clearsOnBeginEditing = true
        textField.autocapitalizationType = .sentences
        textField.autocorrectionType = .yes
        textField.keyboardAppearance = .dark
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
    }
}

// MARK: - TextField Delegate

extension ExercisesViewController: UITextFieldDelegate {
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.clearButtonMode = .whileEditing
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {
            textField.resignFirstResponder()
        }
        return true
    }
}
