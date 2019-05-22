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

class DetailExerciseViewController: UITableViewController {

    fileprivate var sets: Results<Set>?
    fileprivate final let identifierCell = "RepsCell"
//    fileprivate lazy var realm = try! Realm()
//    fileprivate lazy var realm = try! Realm(configuration: RealmConfig.exerciseRealmConfig) // использоварие своего файла конфигурации Realm для легкой миграции
    fileprivate var regularConstraints = [NSLayoutConstraint]()
    fileprivate var compactConstraints = [NSLayoutConstraint]()
    
    // Переменные для передачи данных между контроллерами
    var selectedExercise: Exercise?

    
    fileprivate let exerciseButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.backgroundColor = #colorLiteral(red: 0.8462908864, green: 0.1336644292, blue: 0.1662362516, alpha: 0.7495184075) //UIColor(red: 255, green: 0, blue: 0, alpha: 0.75)
        button.setTitle("+", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 36)
        button.titleEdgeInsets.top = -5
        button.layer.zPosition = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addShadow(offset: CGSize.zero, color: .black, radius: 4, opacity: 0.25) //добавлен с помощью метода addShadow в extension для View
        return button
    }()
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    fileprivate lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Название упражнения отображаемое в Navigation Bar
        navigationItem.title = selectedExercise?.name
        
        // Переименование кнопки "Назад" для возврата на Main View Controller
        let backButtonItem = UIBarButtonItem(title: NSLocalizedString("To Exercises", comment: "To Exercises"), style: UIBarButtonItem.Style.plain, target: self, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButtonItem
        
        // Добавление кнопки "Редактировать"
        navigationItem.rightBarButtonItem = editButtonItem
        
        // Регистрируем ячейку для таблицы
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifierCell)
        
        loadSets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addSetButton()
    }
    
    //MARK: - Methods
    
    // Загружаем подходы для выбранного упражнения
    fileprivate func loadSets() {

        if selectedExercise != nil {
            
            do {
                let realm = try Realm()
//                let realm = try Realm(configuration: RealmConfig.exerciseRealmConfig) // использоварие своего файла конфигурации Realm для легкой миграции
                
                // Если используется связь между Exercise и Set
//                sets = selectedExercise?.sets.sorted(byKeyPath: "date", ascending: false)
                
                // Если между Exercise и Set нет связи
                sets = realm.objects(Set.self).filter("exercise = %@", selectedExercise!).sorted(byKeyPath: "date", ascending: false)
                
            } catch {
                debugPrint("Loading sets for the selected exercise failed!")
            }
        }
    }
    
    // Создаем кнопку "Add Set"
    fileprivate func addSetButton() {
        let sizeButton: CGFloat = 60
        
        exerciseButton.layer.cornerRadius = sizeButton / 2
        view.addSubview(exerciseButton)
        exerciseButton.addTarget(self, action: #selector(addSetButtonTapped(_:)), for: .touchUpInside)
        
        // Ограничения для кнопки "Add Set"
        let widthButton = exerciseButton.widthAnchor.constraint(equalToConstant: sizeButton)
        let heightButton = exerciseButton.heightAnchor.constraint(equalToConstant: sizeButton)
        let centerXButton = exerciseButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor)
        let tralingButton = view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: exerciseButton.trailingAnchor, constant: 20)
        let bottomButton = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: exerciseButton.bottomAnchor, constant: 20)
        
        NSLayoutConstraint.activate([widthButton, heightButton, bottomButton])
        
        regularConstraints.append(centerXButton)
        compactConstraints.append(tralingButton)
    }
    
    // Отображение изображения стрелки при открытом/закрытом состоянии даты упраженения
    fileprivate func showOrHideRepsImage(button: UIButton) -> UIImage {
        let section = button.tag
        let hideImage = UIImage(named: "arrow-up")
        let showImage = UIImage(named: "arrow-down")
        guard let repsImage = (sets?[section].isVisible)! ? hideImage : showImage else { return showImage! }
        return repsImage
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
    
    // Действие при нажатии кнопки "Add Set"
    @objc private func addSetButtonTapped(_ sender: UIButton) {
        
        guard tableView.isEditing == false else {
            let ac = UIAlertController(title: NSLocalizedString("Error!", comment: "Error!"), message: NSLocalizedString("In Editing mode, you cannot add a new set", comment: "In Editing mode, you cannot add a new set"), preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .cancel)
            
            ac.addAction(ok)
            present(ac, animated: true, completion: nil)
            
            return
        }
        
        // Создание всплывающего окна
        let popoverContent = AddSetForExerciseController()
        popoverContent.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(popoverContent, animated: true)

        popoverContent.delegate = self
    }
    
    // Отобразить/скрыть выполненные упражнения при нажатии на дату
    @objc private func showOrHideRepsWhenDateTapped(button: UIButton) {
        let section = button.tag
        var indexPathToOpenOrClose = [IndexPath]()
        
        guard let indexReps = sets?[section].reps.indices else { return }
        
        for row in indexReps {
            let indexPath = IndexPath(row: row, section: section)
            indexPathToOpenOrClose.append(indexPath)
        }
        
        guard let isVisible = sets?[section].isVisible else { return }
        
        do {
            let realm = try Realm()
            //    let realm = try Realm(configuration: RealmConfig.exerciseRealmConfig) // использоварие своего файла конфигурации Realm для легкой миграции
            
            try realm.write {
                self.sets?[section].isVisible = !isVisible
                
                if isVisible {
                    button.setImage(showOrHideRepsImage(button: button), for: .normal)
                    tableView.deleteRows(at: indexPathToOpenOrClose, with: .fade)
                } else {
                    button.setImage(showOrHideRepsImage(button: button), for: .normal)
                    tableView.insertRows(at: indexPathToOpenOrClose, with: .fade)
                }
                
            }
        } catch {
            fatalError("Error when showing/hiding results for the date! - \(error)")
        }
    }
    
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
    
    // Активация ограничений при повороте экрана - Regular or Compact Screens
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.verticalSizeClass == .regular {
            NSLayoutConstraint.deactivate(compactConstraints)
            NSLayoutConstraint.activate(regularConstraints)
        } else {
            NSLayoutConstraint.deactivate(regularConstraints)
            NSLayoutConstraint.activate(compactConstraints)
        }
    }
}

//MARK: - TableView DataSource & Delegate

extension DetailExerciseViewController {
    
    //MARK: - TableView DataSource methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
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
    
    //MARK: - TableView Delegate methods

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let date = sets?[section].date else { return UIView() }
        
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: 200, height: 40))
        label.text = dateFormatter.string(from: date)
        label.textAlignment = .left
        
        let button = UIButton(type: .custom)
        let showOrHideImage = showOrHideRepsImage(button: button)
        
        button.setImage(showOrHideImage, for: .normal)
        button.imageEdgeInsets.right = 20
        button.contentHorizontalAlignment = .trailing
        button.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        button.tag = section
        button.addTarget(self, action: #selector(showOrHideRepsWhenDateTapped), for: .touchUpInside)

        button.addSubview(label)
        
        return button
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let set = sets?[indexPath.section] else { return UITableViewCell() }
        let reps = set.reps[indexPath.row].reps
        let time = set.reps[indexPath.row].time
        
        // Создаем ячейку для времени и количества повторов упражнения
        // Перепределяемая ячейка
//        var cell = tableView.dequeueReusableCell(withIdentifier: identifierCell, for: indexPath)
        
        // Простая ячейка
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifierCell)
        
        cell.textLabel?.text = String(reps)
        cell.detailTextLabel?.text = timeFormatter.string(from: time)
        //        cell.layoutMargins.left = 30
        
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
            
//            do {
//                let realm = try Realm()
////                let realm = try Realm(configuration: RealmConfig.exerciseRealmConfig) // использоварие своего файла конфигурации Realm для легкой миграции
//
//                realm.beginWrite()
//                realm.delete(selectedRepsInSet)
////                tableView.deleteRows(at: [indexPath], with: .fade)
//                try realm.commitWrite()
//            } catch {
//                fatalError("Delete cell failed!")
//            }
            
//            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if selectedSet.reps.isEmpty {
                
                RealmPerform.action(.delete, for: selectedSet)
                
//                do {
//                    let realm = try Realm()
////                let realm = try Realm(configuration: RealmConfig.exerciseRealmConfig) // использоварие своего файла конфигурации Realm для легкой миграции
//
//                    realm.beginWrite()
//                    realm.delete(selectedSet)
//                    try realm.commitWrite()
//                } catch {
//                    fatalError("Delete cell failed!")
//                }
                
//                tableView.deleteSections(indexSetSection, with: .fade)
            }
            tableView.reloadData()
        }
    }
    
    fileprivate func delete(object: Object) {
        do {
            let realm = try Realm()
            realm.beginWrite()
            realm.delete(object)
            try realm.commitWrite()
        } catch {
            
        }
    }
}

//MARK: - Selected Reps Delegate

extension DetailExerciseViewController: SelectedRepsDelegate {
    func sendReps(number: Int) {
        
        // Создание первого подхода для упражнения
        guard let sets = self.sets, let dateFromSets = sets.first?.date else {
            
            // Добавление повторения в первый подход
            create(.set, withValue: number)
            
            return
        }
        
        // Создание подхода
        if Calendar.current.component(.day, from: Date()) > Calendar.current.component(.day, from: dateFromSets) {
            debugPrint("Текущая дата больше последней")
            
            create(.set, withValue: number)
            
        } else if Calendar.current.component(.day, from: Date()) < Calendar.current.component(.day, from: dateFromSets) {
            debugPrint("Текущая дата меньше последней")
            
            let currentDate = searchDate(in: sets)
            
            if currentDate.isFound {
                create(.reps, withValue: number)
            } else {
                create(.set, withValue: number)
            }
            
        } else if Calendar.current.isDateInToday(dateFromSets) {
            debugPrint("Даты равны")
            
            create(.reps, withValue: number)
        }
    }
    
    // Поиск текущей даты в выполненных подходах упражнения
    fileprivate func searchDate(in sets: Results<Set>) -> (isFound: Bool,byIndex: Int?) {
        
        for index in 0..<sets.count {
            if Calendar.current.isDateInToday(sets[index].date) {
                return (true, index)
                
            }
        }
        return (false, nil)
    }
    
    // Добавление повторений к существующей дате
    fileprivate func addToTodayDate(reps: Reps, for sets: Results<Set>) {
        let date = self.searchDate(in: sets)
        
        if let index = date.byIndex {
            sets[index].isVisible = true
            sets[index].reps.append(reps)
        }
    }
    
    // Создание подхода и повторения упражнения
    fileprivate func create(_ type: ExerciseType, withValue repeats: Int) {
        
        let date = Date()
        
        // Создание повторения
        let reps = Reps()
        reps.reps = repeats
        reps.time = date
        reps.exercise = selectedExercise
        
        // Создание подхода
        let set = Set()
        set.date = date
        set.exercise = selectedExercise
        
        set.reps.append(reps)
        
        
//        DispatchQueue(label: "realmQueue").sync {
//            do {
//                let realm = try Realm()
////                let realm = try Realm(configuration: RealmConfig.exerciseRealmConfig) // использоварие своего файла конфигурации Realm для легкой миграции
//                try realm.write {
//                    switch type {
//                    case .set:
//                        realm.add(set)
//
//                        // Если используется связь между Exercise и Set
////                        selectedExercise?.sets.append(set)
//
//                    case .reps:
//                        realm.add(reps)
//
//                        if let sets = self.sets {
//                           addToTodayDate(reps: reps, for: sets)
//                        }
//
//                    }
//                    debugPrint("Added \(type)!")
//                }
//            } catch {
//                fatalError("Can't create a new \(type)!")
//            }
//        }
        
        DispatchQueue(label: "realmQueue").sync {
            switch type {
            case .set:
                RealmPerform.action(.add, for: set)
            case .reps:
                RealmPerform.action(.add, for: reps, in: sets)
            }
            debugPrint("Added \(type)!")
        }
        self.tableView.reloadData()
    }
    
    enum ExerciseType {
        case set
        case reps
    }
}
