//
//  Exercise.swift
//  Exercise
//
//  Created by Vitaly Badion on 10.06.2018.
//  Copyright © 2018 Vitaly Badion. All rights reserved.
//

import Foundation
import RealmSwift

class Exercise: Object {
    
    @objc dynamic public private(set) var id = 0 // public устанавливается для getter, а private(set) для setter
    @objc dynamic var name = ""
    // Связь между Exercise и Set
//    let sets = List<Set>()
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    private func createID() -> Int {
        do {
            let realm = try Realm()
            if let lastID = realm.objects(Exercise.self).sorted(byKeyPath: "id").last?.id {
                id = lastID + 1
                return id
            }
        } catch {
            debugPrint("Can't create ID!")
        }
        return 0
    }
    
    convenience init(name: String) {
        self.init()
        self.id = createID()
        self.name = name
    }
}
