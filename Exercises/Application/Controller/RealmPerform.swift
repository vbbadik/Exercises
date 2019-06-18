//
//  RealmPerform.swift
//  Exercises
//
//  Created by Vitaly Badion on 5/21/19.
//  Copyright © 2019 Vitaly Badion. All rights reserved.
//

import Foundation
import RealmSwift

enum Action {
    case add
    case delete
    case update
    case move
}

final class RealmPerform: Object {
    
    typealias implementationClosure = (Realm) -> Void
    
    // Implementation of actions with Realm through closure
    static func action(_ type: Action, for object: Object? = nil, additionalHandler: implementationClosure? = nil) {
        do {
            let realm = try Realm()
//            let realm = try Realm(configuration: RealmConfig.exerciseRealmConfig) // использование своего файла конфигурации Realm для легкой миграции
            realm.beginWrite()
            
            switch type {
            case .add:
                if additionalHandler != nil {
                    additionalHandler!(realm)
                }
                if let object = object {
                    realm.add(object)
                }
            case .delete:
                if additionalHandler != nil {
                    additionalHandler!(realm)
                }
                if let object = object {
                    realm.delete(object)
                }
            case .update:
                if additionalHandler != nil {
                    additionalHandler!(realm)
                }
            case .move:
                if additionalHandler != nil {
                    additionalHandler!(realm)
                }
            }
            
            try realm.commitWrite()
            
            debugPrint("Action \(type) with an object successful!")
        } catch {
            fatalError("Action \(type) with the an failed - \(error)!")
        }
    }
    
}

extension RealmPerform {
    
    // Implementation of actions with Realm
    static func action(_ type: Action, for object: Object, with newName: String? = nil, in sets: Results<Set>? = nil) {
        do {
            let realm = try Realm()
//            let realm = try Realm(configuration: RealmConfig.exerciseRealmConfig) // использование своего файла конфигурации Realm для легкой миграции
            realm.beginWrite()
            
            switch type {
                
            case .add:
                realm.add(object)
                
                if object is Reps {
                    guard let sets = sets else { return }
                    addToTodayDate(reps: object as! Reps, for: sets)
                }
                
            case .delete:
                if object is Exercise {
                    // If use the relationship between Exercise and Sets
//                    let deleteExercise = object as! Exercise
//                        if !deleteExercise.sets.isEmpty {
//
//                            for set in deleteExercise.sets {
//                                realm.delete(set.reps)
//                            }
//
//                            realm.delete(deleteExercise.sets)
//                        }
                    
                    // If there is no relationship between Exercise and Sets
                    let exerciseSets = realm.objects(Set.self).filter("exercise = %@", object as! Exercise)

                        for set in exerciseSets {
                            realm.delete(set.reps)
                            realm.delete(set)
                        }
                }
                
                realm.delete(object)
                
            case .update:
                if object is Exercise {
                    guard let newName = newName else { return }
                    (object as! Exercise).name = newName
                }
                
            default: break // @unknown default: break - for Swift 5
            }
            try realm.commitWrite()
            
            debugPrint("Action \(type) with an object successful!")
        } catch {
            fatalError("Action \(type) with the an failed - \(error)!")
        }
    }
    
    static func add(_ set: Set, to exercise: Exercise) {
        do {
            let realm = try Realm()
//            let realm = try Realm(configuration: RealmConfig.exerciseRealmConfig) // использование своего файла конфигурации Realm для легкой миграции
            realm.beginWrite()
            
            exercise.sets.append(set)
            
            try realm.commitWrite()
        } catch {
            fatalError("Can't move a exercise")
        }
    }
    
    static func move(_ exercises: Results<Exercise>, from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let source = exercises[sourceIndexPath.row]
        let destinationID = exercises[destinationIndexPath.row].sortID
        
        do {
            let realm = try Realm()
//            let realm = try Realm(configuration: RealmConfig.exerciseRealmConfig) // использование своего файла конфигурации Realm для легкой миграции
            realm.beginWrite()
            
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
            
            try realm.commitWrite()
        } catch {
            fatalError("Can't move a exercise")
        }
    }
    
    private static func addToTodayDate(reps: Reps, for sets: Results<Set>) {
        
        for index in 0..<sets.count {
            if Calendar.current.isDateInToday(sets[index].date) {
                sets[index].isVisible = true
                sets[index].reps.append(reps)
            }
        }
    }
    
}
