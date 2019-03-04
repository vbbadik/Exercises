//
//  Exercise.swift
//  Exercise
//
//  Created by Vitaly Badion on 10.06.2018.
//  Copyright © 2018 Vitaly Badion. All rights reserved.
//

import Foundation

struct Exercise: Codable {
    var name: String
    var sets: [Set]?

    init(name: String) {
        self.name = name
    }
}

struct Set: Codable {
    var isVisible: Bool = false
    var date: Date
    var reps: [Int]
    var time: [Date]
}
