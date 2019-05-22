//
//  Set.swift
//  Exercises
//
//  Created by Vitaly Badion on 3/15/19.
//  Copyright © 2019 Vitaly Badion. All rights reserved.
//

import Foundation
import RealmSwift

class Set: Object {
    @objc dynamic var isVisible = true
    @objc dynamic var date = Date()
    @objc dynamic var exercise: Exercise? = nil
    let reps = List<Reps>()
    // Связь между Exercise и Set
//    let exercise = LinkingObjects(fromType: Exercise.self, property: "sets")
}
