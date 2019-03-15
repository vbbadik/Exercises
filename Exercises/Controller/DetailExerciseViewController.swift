//
//  DetailViewController.swift
//  Exercise
//
//  Created by Vitaly Badion on 11.06.2018.
//  Copyright © 2018 Vitaly Badion. All rights reserved.
//

// Используется способ реализованный в видео https://www.youtube.com/watch?v=VFtsSEYDNRU

import UIKit

class DetailExerciseViewController: UITableViewController {
    
    final let identifierCell = "RepsCell"
    fileprivate let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Sets.plist")
    fileprivate var regularConstraints = [NSLayoutConstraint]()
    fileprivate var compactConstraints = [NSLayoutConstraint]()
    
    // Переменные для передачи данных между контроллерами
    var selectedExercise: String?
    var sets: [Set]?
    var competionHandler: (([Set]) -> Void)?

    
    fileprivate let exerciseButton: UIButton = {
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
        return formatter
    }()
    
    lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Название упражнения отображаемое в Navigation Bar
        navigationItem.title = selectedExercise
        
        // Переименование кнопки "Назад" для возврата на Main View Controller
        let backButtonItem = UIBarButtonItem(title: NSLocalizedString("To Exercises", comment: "To Exercises"), style: UIBarButtonItem.Style.plain, target: self, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButtonItem
        
        // Добавление кнопки "Редактировать"
        navigationItem.rightBarButtonItem = editButtonItem
        
        // Регистрируем ячейку для таблицы
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifierCell)
        
//        let segmented = UISegmentedControl(items: ["Show", "Hide"])
//        segmented.backgroundColor = .red
//        segmented.tintColor = .white
//        tableView.tableHeaderView = segmented
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addSetButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Отправка подробных данных о выполнении упражения в Main View Controller
        guard let infoOfSets = self.sets else { return }
        self.competionHandler?(infoOfSets)
    }
    
    //MARK: - Methods
    
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
        
        sets?[section].isVisible = !isVisible
        
        if isVisible {
            button.setImage(showOrHideRepsImage(button: button), for: .normal)
            tableView.deleteRows(at: indexPathToOpenOrClose, with: .fade)
        } else {
            button.setImage(showOrHideRepsImage(button: button), for: .normal)
            tableView.insertRows(at: indexPathToOpenOrClose, with: .fade)
        }
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
        
        //        let hideImage = UIImage(named: "arrow-up")
        //        let showImage = UIImage(named: "arrow-down")
        //        let showOrHideRepsImage = (sets?[section].isVisible)! ? hideImage : showImage // UIImageView(frame: .zero)
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: 200, height: 40))
        label.text = dateFormatter.string(from: date)
        label.textAlignment = .left
        
        let button = UIButton(type: .custom)
        let showOrHideImage = showOrHideRepsImage(button: button)
        
        button.setImage(showOrHideImage, for: .normal)
        //        button.setTitle(date, for: .normal)
        //        button.setTitleColor(.black, for: .normal)
        //        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.imageEdgeInsets.right = 20
        button.contentHorizontalAlignment = .trailing
        button.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        button.tag = section
        button.addTarget(self, action: #selector(showOrHideRepsWhenDateTapped), for: .touchUpInside)
        
        //showOrHideRepsImage = (sets?[section].isVisible)! ? hideImage : showImage
        //showOrHideRepsImage.translatesAutoresizingMaskIntoConstraints = false

        button.addSubview(label)
        
        //Constraints for Image
        //        button.trailingAnchor.constraint(equalTo: showOrHideRepsImage.trailingAnchor, constant: 20).isActive = true
        //        showOrHideRepsImage.topAnchor.constraint(equalTo: button.topAnchor, constant: 15).isActive = true
        //        button.bottomAnchor.constraint(equalTo: showOrHideRepsImage.bottomAnchor, constant: 15).isActive = true
        
        return button
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let hideImage = UIImage(named: "arrow-up")
        //        let showImage = UIImage(named: "arrow-down")
        //        let accessoryViewHideButton = UIImageView(image: hideImage)
        //        let accessoryViewShowButton = UIImageView(image: showImage)
        
        guard let date = sets?[indexPath.section] else { return UITableViewCell() }
        let reps = date.reps
        let time = date.time
        
        // Создаем ячейку для времени и количества повторов упражнения
        // Перепределяемая ячейка
//        var cell = tableView.dequeueReusableCell(withIdentifier: identifierCell, for: indexPath)
        
        // Простая ячейка
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifierCell)
        
        cell.textLabel?.text = String(reps[indexPath.row])
        cell.detailTextLabel?.text = timeFormatter.string(from: time[indexPath.row])
        //        cell.accessoryView = (sets?[indexPath.section].isVisible)! ? accessoryViewHideButton : accessoryViewShowButton
        //        cell.layoutMargins.left = 30
        
        return cell
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //        if sets?[indexPath.section].isVisible == true {
        //            sets?[indexPath.section].isVisible = false
        //            let section = IndexSet.init(integer: indexPath.section)
        //            tableView.reloadSections(section, with: .fade)
        //        } else {
        //            sets?[indexPath.section].isVisible = true
        //            let section = IndexSet(integer: indexPath.section)
        //            tableView.reloadSections(section, with: .none)
        //        }
    }

// При нажатии на кнопку Accessory показывается или скрываются результаты упражнения с временем
//    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
//        if sets?[indexPath.section].isVisible == true {
//            sets?[indexPath.section].isVisible = false
//            let section = IndexSet.init(integer: indexPath.section)
//            tableView.reloadSections(section, with: .fade)
//        } else {
//            sets?[indexPath.section].isVisible = true
//            let section = IndexSet(integer: indexPath.section)
//            tableView.reloadSections(section, with: .none)
//        }
//    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let indexSetSection = IndexSet(integer: indexPath.section)
        
        if editingStyle == .delete {
            sets?[indexPath.section].reps.remove(at: indexPath.row)
            sets?[indexPath.section].time.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if sets?[indexPath.section].reps.isEmpty == nil {
                sets?.remove(at: indexPath.section)
                tableView.deleteSections(indexSetSection, with: .fade)
            }
            
            // Сохранение подходов выбранного упражения в файл
//            if let sets = sets, let file = dataFilePath {
//                SaveAndLoadData<Set>().save(sets, to: file)
//            }
            
            tableView.reloadData()
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

//MARK: - Selected Reps Delegate

extension DetailExerciseViewController: SelectedRepsDelegate {
    func sendReps(number: Int) {
    
        let reps = number
        let date = Date()
        guard let dateFromSets = self.sets?.first?.date else {
            // Создание первого подхода для упражнения
            self.sets = [Set(isVisible: true, date: date, reps: [reps], time: [date])]
            
            // Сохранение подходов выбранного упражения в файл
//            if let sets = sets, let file = dataFilePath {
//                SaveAndLoadData<Set>().save(sets, to: file)
//            }
            
            self.tableView.reloadData()
            
            return
        }
        
        // Сравнение даты с использованием DateFormatter
//        let currentDate = dateFormatter.string(from: date)
//        let lastDate = dateFormatter.string(from: dateFromSets)
        
        // Сравнение даты с использованием DateСomponenst
        let calendar = Calendar.current
        let currentDate = calendar.dateComponents([.day, .month, .year], from: date)
        let lastDate = calendar.dateComponents([.day, .month, .year], from: dateFromSets)
        
        // Создание подхода
        if currentDate == lastDate {
            self.sets?[0].isVisible = true
            self.sets?[0].reps.append(reps)
            self.sets?[0].time.append(date)
        } else {
            let addReps = Set(isVisible: true, date: date, reps: [reps], time: [date])
            self.sets?.insert(addReps, at: 0)
        // Скрытие результатов прошедших дат
//            if let sets = sets {
//                for index in 1..<sets.count {
//                    self.sets?[index].isVisible = false
//                }
//            }
        }
        
        // Сохранение подходов выбранного упражения в файл
//        if let sets = sets, let file = dataFilePath {
//            SaveAndLoadData<Set>().save(sets, to: file)
//        }
        
        self.tableView.reloadData()
    }
}
