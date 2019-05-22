//
//  Reps.swift
//  Exercises
//
//  Created by Vitaly Badion on 3/28/19.
//  Copyright © 2019 Vitaly Badion. All rights reserved.
//

import Foundation
import RealmSwift

class Reps: Object {
    @objc dynamic var reps = 0
    @objc dynamic var time = Date()
    @objc dynamic var exercise: Exercise? = nil
//    let exercise = LinkingObjects(fromType: Set.self, property: "exercise")
    let set = LinkingObjects(fromType: Set.self, property: "reps")
}
