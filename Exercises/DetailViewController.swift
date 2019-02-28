//
//  DetailViewController.swift
//  Exercise
//
//  Created by Vitaly Badion on 11.06.2018.
//  Copyright © 2018 Vitaly Badion. All rights reserved.
//

// Используется способ реализованный в видео https://www.youtube.com/watch?v=ClrSpJ3txAs

import UIKit

class DetailViewController: UITableViewController {
    
    final let identifierCell = "SetCell"
    var selectedExercise: String?
    var sets: [Set]? //= [Set]()
    private var regularConstraints = [NSLayoutConstraint]()
    private var compactConstraints = [NSLayoutConstraint]()
//    private let accessoryTypeHideButton = UIImage(named: "arrow-up")
//    private let accessoryTypeShowButton = UIImage(named: "arrow-down")
    var competionHandler: (([Set]) -> Void)?
    
    let exerciseButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.backgroundColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.75)
        button.setTitle("+", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 36)
        button.titleEdgeInsets.top = -5
        button.layer.zPosition = 2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addShadow(offset: CGSize.zero, color: .black, radius: 4, opacity: 0.25) //добавлен с помощью метода addShadow в extension для View
        return button
    }()
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        // US English Locale (en_US)
        formatter.locale = Locale(identifier: "en_US")
        // RU Russian Locale (ru_RU)
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        // US English Locale (en_US)
        formatter.locale = Locale(identifier: "en_US")
        // RU Russian Locale (ru_RU)
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    override func loadView() {
        super.loadView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Название упражнения отображаемое в Navigation Bar
        navigationItem.title = selectedExercise
        // Переименование кнопки "Назад" для возврата на Main View Controller
        let backButtonItem = UIBarButtonItem(title: NSLocalizedString("To Exercises", comment: "To Exercises"), style: UIBarButtonItem.Style.plain, target: self, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButtonItem
        // Добавление кнопки "Редактировать"
        navigationItem.rightBarButtonItem = editButtonItem
        // Создаем ячейку в таблице
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifierCell)
        
//        sets = [Set(isVisible: true, date: "25 сент. 2018 г.", reps: [13, 10, 9], time: ["18:10", "18:15", "18:20"]),
//                Set(isVisible: false, date: "21 сент. 2018 г.", reps: [13, 10, 9], time: ["18:10", "18:15", "18:20"]),
//                Set(isVisible: false, date: "19 сент. 2018 г.", reps: [13, 10, 9], time: ["20:10", "20:12", "20:14"])]
        sets = [Set(isVisible: true, date: Date(), reps: [1, 2, 3], time: [Date(), Date(), Date()]),
                Set(isVisible: true, date: Date(), reps: [1, 2, 3], time: [Date(), Date(), Date()]),
                Set(isVisible: true, date: Date(), reps: [1, 2, 3], time: [Date(), Date(), Date()])]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addSetButton()
          print("viewWillAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Отправка подробных данных о выполнении упражения в Main View Controller
        guard let infoOfSets = self.sets else { return }
        self.competionHandler?(infoOfSets)

        print("viewWillDisappear")
    }
    
    override func viewWillLayoutSubviews() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Создаем кнопку "Add Exercise"
    func addSetButton() {
        let sizeButton: CGFloat = 60
        
        exerciseButton.layer.cornerRadius = sizeButton / 2
        view.addSubview(exerciseButton)
        exerciseButton.addTarget(self, action: #selector(addSetButtonTapped(_:)), for: .touchUpInside)
        
        // Constraints for button "Add Set"
        let widthButton = exerciseButton.widthAnchor.constraint(equalToConstant: sizeButton)
        let heightButton = exerciseButton.heightAnchor.constraint(equalToConstant: sizeButton)
        let centerXButton = exerciseButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor)
        let tralingButton = view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: exerciseButton.trailingAnchor, constant: 20)
        let bottomButton = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: exerciseButton.bottomAnchor, constant: 20)
        
        NSLayoutConstraint.activate([widthButton, heightButton, bottomButton])
        
        regularConstraints.append(centerXButton)
        compactConstraints.append(tralingButton)
        
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
    @objc func addSetButtonTapped(_ sender: UIButton) {
        guard tableView.isEditing == false else {
            let ac = UIAlertController(title: NSLocalizedString("Error!", comment: "Error!"), message: NSLocalizedString("In Editing mode, you cannot add a new set", comment: "In Editing mode, you cannot add a new set"), preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            ac.addAction(ok)
            present(ac, animated: true, completion: nil)
            return
        }

        let popoverContent = AddSetForExerciseController()
        popoverContent.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(popoverContent, animated: true, completion: nil)

        popoverContent.delegate = self
    }
    
    // Додавление нового подхода через Alert Controller
//    @objc func saveButtonTapped() {
//
//        let pickerAlert = UIAlertController(title: NSLocalizedString("Choose reps", comment: "Choose reps"), message: "", preferredStyle: .alert)
//        let picker = UIPickerView()
//        picker.translatesAutoresizingMaskIntoConstraints = false
//        pickerAlert.view.addSubview(picker)
//        picker.dataSource = self
//        picker.delegate = self
//
//        let save = UIAlertAction(title: NSLocalizedString("Add", comment: "Add"), style: .cancel) { action in
//            let currentDate = Date()
//            let date = self.dateFormatter.string(from: currentDate)
//            let time = self.timeFormatter.string(from: currentDate)
//            let reps = picker.selectedRow(inComponent: 0) + 1
//
//           // guard let reps = self.selectedReps else { return }
//            // Создание подхода
//            if self.sets != nil {
//                if date == self.sets?.first?.date {
//                    self.sets?[0].isVisible = true
//                    self.sets?[0].reps.append(reps)
//                    self.sets?[0].time.append(time)
//                } else {
//                    let addReps = Set(isVisible: true, date: date, reps: [reps], time: [time])
//                    self.sets?.insert(addReps, at: 0)
//                }
//            } else {
//                self.sets = [Set(isVisible: true, date: date, reps: [reps], time: [time])]
//            }
//
//            self.tableView.reloadData()
//        }
//
//        pickerAlert.addAction(save)
//        present(pickerAlert, animated: true, completion: nil)
//
//
//        //Constraints
//        picker.leadingAnchor.constraint(equalTo: pickerAlert.view.leadingAnchor).isActive = true
//        picker.trailingAnchor.constraint(equalTo: pickerAlert.view.trailingAnchor).isActive = true
//        picker.topAnchor.constraint(equalTo: pickerAlert.view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
//        pickerAlert.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: picker.bottomAnchor, constant: 30).isActive = true
//    }
    
    //MARK: - Table view Data source & Delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sets?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        guard let dateSets = sets else { return "" }
//        return dateSets[section].date
        // OR
        guard let date = sets?[section].date else { return "" }
        return dateFormatter.string(from: date)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let date = sets?[section].date else { return UIView() }
        let dateToShow = dateFormatter.string(from: date)
        let button = UIButton(type: .system)
        button.setTitle(dateToShow, for: .normal)
        
        return button
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dateSets = sets {
            if dateSets[section].isVisible {
                return dateSets[section].reps.count + 1
            } else {
                return 1
            }
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataIndex = indexPath.row - 1
        let hideImage = UIImage(named: "arrow-up")
        let showImage = UIImage(named: "arrow-down")
        let accessoryViewHideButton = UIImageView(image: hideImage)
        let accessoryViewShowButton = UIImageView(image: showImage)
        
        guard let set = sets?[indexPath.section] else { return UITableViewCell() }
        let date = set.date
        let reps = set.reps
        let time = set.time
        
        if indexPath.row == 0 {
            // Создаем ячейку на основе даты упражения, если ее еще нет
            let cell = tableView.dequeueReusableCell(withIdentifier: identifierCell, for: indexPath)
            cell.textLabel?.text = dateFormatter.string(from: date)
            cell.accessoryView = (sets?[indexPath.section].isVisible)! ? accessoryViewHideButton : accessoryViewShowButton
//            cell.accessoryType = .detailButton
            cell.layoutMargins.left = 20
            return cell
        } else {
            // Создаем ячейку для времени и количества повторов упражнения
            var cell = tableView.dequeueReusableCell(withIdentifier: identifierCell, for: indexPath)
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifierCell)
            cell.textLabel?.text = String(reps[dataIndex])
            cell.detailTextLabel?.text = dateFormatter.string(from: time[dataIndex])
//            cell.textLabel?.text = "\(date.reps[dataIndex]) - \(date.time[dataIndex])"
            cell.accessoryView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
//            cell.accessoryType = .none
            cell.layoutMargins.left = 30
            return cell
        }
        
        
        //        if indexPath.row == 0 {
        //            // Создаем ячейку на основе даты упражения, если ее еще нет
        //            guard let cell = tableView.dequeueReusableCell(withIdentifier: identifierCell, for: indexPath) as? DetailExerciseViewCell else { return UITableViewCell() }
        //            let date = dateExercise[indexPath.row]
        //            sets?[indexPath.section].date = dateFormatter.string(from: date)
        //            cell.dateLabel?.text = sets?[indexPath.section].date
        //            return cell
        //        } else {
        //            // Создаем ячейку для времени и количества повторов упражнения
        //            guard let cell = tableView.dequeueReusableCell(withIdentifier: identifierCell, for: indexPath) as? DetailExerciseViewCell else { return UITableViewCell() }
        //            guard let date = sets?[indexPath.section] else { return UITableViewCell() }
        //            cell.timeLabel?.text = date.time[dataIndex]
        //            cell.repeatLabel?.text = date.reps[dataIndex]
        //            return cell
        //        }
        //        let cell = tableView.dequeueReusableCell(withIdentifier: identifierCell, for: indexPath) as? DetailExerciseViewCell
        //        let date = dateExercise[indexPath.row]
        //        cell?.dateLabel?.text = dateFormatter.string(from: date)
        //        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
                if sets?[indexPath.section].isVisible == true {
                    sets?[indexPath.section].isVisible = false
                    let section = IndexSet.init(integer: indexPath.section)
                    tableView.reloadSections(section, with: .fade)
                } else {
                    sets?[indexPath.section].isVisible = true
                    let section = IndexSet(integer: indexPath.section)
                    tableView.reloadSections(section, with: .none)
                }
    }
    
    // При нажатии на кнопку Accessory показывается или скрываются результаты упражнения с временем
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if sets?[indexPath.section].isVisible == true {
            sets?[indexPath.section].isVisible = false
            let section = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(section, with: .fade)
        } else {
            sets?[indexPath.section].isVisible = true
            let section = IndexSet(integer: indexPath.section)
            tableView.reloadSections(section, with: .none)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        let indexSetSection = IndexSet(integer: indexPath.section)
//        let indexPathRow = indexPath.row
//        let date = sets?[indexPath.row].date
//        let reps = sets?[indexPath.row].reps
//        let time = sets?[indexPath.row].time

        let index = IndexPath(row: indexPath.row, section: indexPath.section)

        if sets?[indexPath.section].reps == nil {
            sets?.remove(at: indexPath.section)
            tableView.deleteSections(indexSetSection, with: .fade)
        }


//        if ((sets?[indexPath.section]) != nil) {
//            //Работает при удалении даты
//            sets?.remove(at: indexPath.section)
//            tableView.deleteSections(indexSetSection, with: .fade)
//        } else
            if ((sets?[indexPath.row].reps) != nil) {
//            tableView.beginUpdates()
            let deleteReps = sets?[indexPath.section].reps.remove(at: indexPath.row)
            print(deleteReps!)
            let deleteTime = sets?[indexPath.section].time.remove(at: indexPath.row)
            print(deleteTime!)
            tableView.deleteRows(at: [index], with: .fade)
                            tableView.reloadData()
//            tableView.endUpdates()
        } else {
            sets?.remove(at: indexPath.row)
            tableView.deleteSections(indexSetSection, with: .fade)
        }

            tableView.reloadData()
        

//        if editingStyle == .delete {
//            sets?[indexPath.section].reps.remove(at: indexPath.row)
//            sets?[indexPath.section].time.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//            if (sets?[indexPath.section].reps.isEmpty)! {
//               sets?.remove(at: indexPath.section)
//               tableView.deleteSections(indexSetSection, with: .fade)
//        }
//          tableView.reloadData()
//        }
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
    
    //Activate constraints for device orientation - Regular or Compact Screens
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

// Нужны при использовании метода saveButtonTapped()
//extension DetailViewController: UIPickerViewDataSource {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return 50
//    }
//}
//
//extension DetailViewController: UIPickerViewDelegate {
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        let result = "\(row + 1)"
//        return result
//    }
//}

extension DetailViewController: SelectedRepsDelegate {
    func sendReps(number: Int) {
        let reps = number
        let calendar = Calendar.current
        let date = Date()
        var lastDate = DateComponents()
        let currentDate = calendar.dateComponents([.day, .month, .year], from: date)
        if let dateFromSets = self.sets?.first?.date {
            lastDate = calendar.dateComponents([.day, .month, .year], from: dateFromSets)
        }
        
        // Сравнение даты с использованием DateFormatter
        //        let currentDate = dateFormatter.string(from: date)
        //        let lastDate = dateFormatter.string(from: dateFromSets)
        
        // Создание подхода
        if self.sets != nil {
            if currentDate == lastDate {
                self.sets?[0].isVisible = true
                self.sets?[0].reps.append(reps)
                self.sets?[0].time.append(date)
            } else {
                let addReps = Set(isVisible: true, date: date, reps: [reps], time: [date])
                self.sets?.insert(addReps, at: 0)
                // Скрытие результатов прошедших дат
//                if let sets = sets {
//                    for index in 1..<sets.count {
//                        self.sets?[index].isVisible = false
//                    }
//                }
            }
        } else {
            self.sets = [Set(isVisible: true, date: date, reps: [reps], time: [date])]
        }
        self.tableView.reloadData()
    }
}
