//
//  DetailViewController.swift
//  Exercise
//
//  Created by Vitaly Badion on 11.06.2018.
//  Copyright © 2018 Vitaly Badion. All rights reserved.
//

// Используется способ реализованный в видео https://www.youtube.com/watch?v=VFtsSEYDNRU

import UIKit
import RealmSwift

final class SetsViewController: UITableViewController {

    fileprivate var sets: Results<Set>?
    fileprivate var regularConstraints = [NSLayoutConstraint]()
    fileprivate var compactConstraints = [NSLayoutConstraint]()
    fileprivate let exerciseButton = UIButton()
    fileprivate let repsButton = SetButton()
    
    // Variables to pass data between controllers
    var selectedExercise: Exercise?

    // MARK: - Lifestyle methods
    
    override func loadView() {
        super.loadView()
        
        setButton()
        buttonConstraints()
        activateCurrentButtonConstrains()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        registerCell()
        customizeButton()
        loadSets()
        
        exerciseButton.superview?.bringSubviewToFront(exerciseButton) // Moving the button to the foreground
    }
    
/* override func viewDidLayoutSubviews() {
//        view.bringSubviewToFront(exerciseButton)
        // OR
//        exerciseButton.superview?.bringSubviewToFront(exerciseButton)
    } */
    
    // MARK: - Methods
    
    // Loading sets for the selected exercise
    fileprivate func loadSets() {
        DispatchQueue(label: "realmQueue").sync {
            if selectedExercise != nil {
                // If use the relationship between Exercise and Sets
                sets = selectedExercise?.sets.sorted(byKeyPath: "date", ascending: false)
                
                // If there is no relationship between Exercise and Sets
//                do {
//                    let realm = try Realm()
////                    let realm = try Realm(configuration: RealmConfig.exerciseRealmConfig) // использоварие своего файла конфигурации Realm для легкой миграции
//                    sets = realm.objects(Set.self).filter("exercise = %@", selectedExercise!).sorted(byKeyPath: "date", ascending: false)
//                } catch {
//                    debugPrint("Loading sets for the selected exercise failed!")
//                }
            }
        }
    }
    
    fileprivate func setupNavigationBar() {
        // Exercise name displayed on Navigation Bar
        navigationItem.title = selectedExercise?.name
        
        // Rename the Back button to return to Main View Controller
        let backButtonItem = UIBarButtonItem(title: NSLocalizedString("To Exercises", comment: "To Exercises"), style: UIBarButtonItem.Style.plain, target: self, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButtonItem
        
        // Adding the Edit button
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    fileprivate func registerCell() {
        // Register cell for table
        tableView.register(RepsCell.self, forCellReuseIdentifier: RepsCell.reuseIdentifier)
        tableView.register(HeaderView.self, forHeaderFooterViewReuseIdentifier: HeaderView.reuseIdentifier)
    }
    
    // MARK: - Actions
    
    // Action to tapping the Edit button on Navigation Bar
    //    @objc func goToEditTable() {
    //        tableView.isEditing = !tableView.isEditing
    //        if tableView.isEditing {
    //            setEditing(true, animated: true)
    //        } else {
    //            setEditing(false, animated: true)
    //        }
    //    }
}

// MARK: - TableView DataSource methods

extension SetsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        self.view.bringSubviewToFront(exerciseButton)
        return sets?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //#1
//        if let dateSets = sets?[section] {
//            if dateSets.isVisible {
//                return dateSets.reps.count
//            } else {
//                return 0
//            }
//        }
//        return 0
        
        //#2
        guard let dateSets = sets?[section], dateSets.isVisible == true else { return 0 }
        
        return dateSets.reps.count
    }
}

// MARK: - TableView Delegate methods

extension SetsViewController {
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Create a header for cell
        guard let set = sets?[section],
              let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderView.reuseIdentifier) as? HeaderView else { return UIView() }
        header.delegate = self
        header.configure(set, by: section)
        
        self.view.bringSubviewToFront(exerciseButton) // Moving the button to the foreground
        
        return header
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40 //UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 40
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create a cell for time and exercise reps
        guard let set = sets?[indexPath.section],
              let cell = tableView.dequeueReusableCell(withIdentifier: RepsCell.reuseIdentifier, for: indexPath) as? RepsCell else { return UITableViewCell() }
        cell.configure(from: set, by: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
   
        guard let selectedSet = sets?[indexPath.section] else {
            fatalError("Can't getting section!")
        }
        
        let selectedRepsInSet = selectedSet.reps[indexPath.row]
        
        if editingStyle == .delete {
            RealmPerform.action(.delete, for: selectedRepsInSet)
            
            if selectedSet.reps.isEmpty {
                RealmPerform.action(.delete, for: selectedSet)
            }
            tableView.reloadData()
        }
    }
}

// MARK: - AddSet button

extension SetsViewController {
    
    fileprivate var sizeButton: CGFloat {
        return 60
    }
    
    // Create AddSet button
    fileprivate func setButton() {
        exerciseButton.frame.size = CGSize.zero
        exerciseButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exerciseButton)
        exerciseButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
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
        let centerXButton = exerciseButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor)
        let trailingButton = view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: exerciseButton.trailingAnchor, constant: 20)
        let bottomButton = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: exerciseButton.bottomAnchor, constant: 20)

        NSLayoutConstraint.activate([widthButton, heightButton, bottomButton])

        regularConstraints.append(centerXButton)
        compactConstraints.append(trailingButton)
    }
    
    // Activate constraints for class device
    fileprivate func activateCurrentButtonConstrains() {
        NSLayoutConstraint.deactivate(regularConstraints + compactConstraints)
        
        if traitCollection.userInterfaceIdiom == .phone {
            if traitCollection.verticalSizeClass == .regular {
                NSLayoutConstraint.activate(regularConstraints)
            } else {
                NSLayoutConstraint.activate(compactConstraints)
            }
        } else if traitCollection.userInterfaceIdiom == .pad {
            NSLayoutConstraint.activate(compactConstraints)
        }
        
    }
    
    // Action on tap Add Set button
    @objc private func buttonTapped(_ sender: UIButton) {
        
        guard tableView.isEditing == false else {
            let ac = UIAlertController(title: NSLocalizedString("Error!", comment: "Error!"), message: NSLocalizedString("In Editing mode, you cannot add a new set", comment: "In Editing mode, you cannot add a new set"), preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .cancel)
            
            ac.addAction(ok)
            present(ac, animated: true, completion: nil)
            
            return
        }
        
        // Create popup controller
        let popoverContent = AddRepsController()
        popoverContent.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        popoverContent.delegate = self
        self.present(popoverContent, animated: true)
    }
    
}

// MARK: - Rotation

extension SetsViewController {
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    // Activate constraints when rotating device - Regular or Compact Screens
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        activateCurrentButtonConstrains()
        
        print("Activate constraints in traitCollection")
        
    }
}

// MARK: - HeaderView Delelegate methods

extension SetsViewController: HeaderViewDelegate {
    func toggleSection(_ header: HeaderView, section: Int) {

        var indexPathToOpenOrClose = [IndexPath]()
        
        guard let indexReps = sets?[section].reps.indices else { return }
        
        for row in indexReps {
            let indexPath = IndexPath(row: row, section: section)
            indexPathToOpenOrClose.append(indexPath)
        }
        
        guard let isVisible = sets?[section].isVisible else { return }
        
        DispatchQueue(label: "realmQueue").sync {
            RealmPerform.action(.update, additionalHandler: { _ in
                self.sets?[section].isVisible = !isVisible
                
                if isVisible {
                    header.collapsed(false)
                    self.tableView.deleteRows(at: indexPathToOpenOrClose, with: .fade)
                } else {
                    header.collapsed(true)
                    self.tableView.insertRows(at: indexPathToOpenOrClose, with: .fade)
                }
            })
        }
    }
}

// MARK: - Selected Reps Delegate

extension SetsViewController: SelectedRepsDelegate {
    func sendReps(number: Int) {
        
        // Creating a first approach for exercise
        guard let sets = self.sets, let dateFromSets = sets.first?.date else {
            
            // Adding repeat to the first set
            create(.set, withValue: number)
            
            return
        }
        
        // Creating a set
        if Calendar.current.isDateInToday(dateFromSets) {
            debugPrint("Dates are equal")
            
            create(.reps, withValue: number)
            
        } else if Calendar.current.component(.month, from: Date()) >= Calendar.current.component(.month, from: dateFromSets) &&
            Calendar.current.component(.day, from: Date()) > Calendar.current.component(.day, from: dateFromSets) {
            debugPrint("The current date is more then last")
            
            create(.set, withValue: number)
            
        } else if Calendar.current.component(.month, from: Date()) <= Calendar.current.component(.month, from: dateFromSets) ||
            Calendar.current.component(.month, from: Date()) >= Calendar.current.component(.month, from: dateFromSets) &&
            Calendar.current.component(.day, from: Date()) < Calendar.current.component(.day, from: dateFromSets) {
            debugPrint("The current date is less then last")
            
            let currentDate = searchDate(in: sets)
            
            if currentDate.isFound {
                create(.reps, withValue: number)
            } else {
                create(.set, withValue: number)
            }
        }
    }
    
    // Search for the current date in the completed sets
    fileprivate func searchDate(in sets: Results<Set>) -> (isFound: Bool,byIndex: Int?) {
        
        for index in 0..<sets.count {
            if Calendar.current.isDateInToday(sets[index].date) {
                return (true, index)
                
            }
        }
        return (false, nil)
    }
    
    // Adding replays to an existing date
    fileprivate func addToTodayDate(reps: Reps, for sets: Results<Set>) {
        let date = self.searchDate(in: sets)

        if let index = date.byIndex {
            sets[index].isVisible = true
            sets[index].reps.append(reps)
        }
    }
    
    // Creating an set and reps the exercise
    fileprivate func create(_ type: ExerciseType, withValue repeats: Int) {
        
        let date = Date()
        
        // Create reps
        let reps = Reps()
        reps.reps = repeats
        reps.time = date
        reps.exercise = selectedExercise
        
        // Create set
        let set = Set()
        set.date = date
//        set.exercise = selectedExercise
        
        set.reps.append(reps)
        
        // ver.1
        DispatchQueue(label: "realmQueue").sync {
            switch type {
            case .set:
                
                // If use the relationship between Exercise and Sets
                RealmPerform.action(.add, for: set) { _ in
                    self.selectedExercise?.sets.append(set)
                }
            case .reps:
                RealmPerform.action(.add, for: reps) { _ in
                    if let sets = self.sets {
                        self.addToTodayDate(reps: reps, for: sets)
                    }
                }
                // If there is no relationship between Exercise and Sets
//                RealmPerform.action(.add, for: set)
            }
        }
        
        // ver.2
//        DispatchQueue(label: "realmQueue").sync {
//            switch type {
//            case .set:
//                RealmPerform.action(.add, for: set)
//                RealmPerform.add(set, to: self.selectedExercise!)
//            case .reps:
//                RealmPerform.action(.add, for: reps, in: sets)
//            }
//            debugPrint("Added \(type)!")
//        }
        
        self.tableView.reloadData()
    }
    
    enum ExerciseType {
        case set
        case reps
    }
}
