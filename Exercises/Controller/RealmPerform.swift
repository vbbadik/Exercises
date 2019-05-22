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
}

class RealmPerform: Object {
    
    class func action(_ type: Action, for object: Object, with newName: String? = nil, in sets: Results<Set>? = nil) {
        do {
            let realm = try Realm()
//            let realm = try Realm(configuration: RealmConfig.exerciseRealmConfig) // использоварие своего файла конфигурации Realm для легкой миграции
            realm.beginWrite()
            
            switch type {
                
            case .add:
                realm.add(object)
                
                if object is Reps {
                    guard let sets = sets else { return }
                    addToTodayDate(reps: object as! Reps, for: sets)
                }
                
            case .delete:
                realm.delete(object)
                
            case .update:
                if object is Exercise {
                    guard let newName = newName else { return }
                    (object as! Exercise).name = newName
                }
            }
            try realm.commitWrite()
            
            debugPrint("Action \(type) with an object successful!")
        } catch {
            fatalError("Action \(type) with the an failed - \(error)!")
        }
    }
    
    
    private class func addToTodayDate(reps: Reps, for sets: Results<Set>) {
        
        for index in 0..<sets.count {
            if Calendar.current.isDateInToday(sets[index].date) {
                sets[index].isVisible = true
                sets[index].reps.append(reps)
            }
        }
    }
}
