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


//class Exercise: NSObject, NSCoding {
//    var name: String
//    var sets: [Set]?
//
//    init(name: String) {
//        self.name = name
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        self.name = aDecoder.decodeObject(forKey: "name") as! String
//    }
//
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(self.name, forKey: "name")
//    }
//}
//
//class Set: NSObject, NSCoding {
//    var isVisible: Bool = false
//    var date: String
//    var reps: [Int]
//    var time: [String]
//
//    init(isVisible: Bool, date: String, reps: [Int], time: [String]) {
//        self.isVisible = isVisible
//        self.date = date
//        self.reps = reps
//        self.time = time
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        self.isVisible = aDecoder.decodeBool(forKey: "isVisible")
//        self.date = aDecoder.decodeObject(forKey: "date") as! String
//        self.reps = aDecoder.decodeObject(forKey: "reps") as! [Int]
//        self.time = aDecoder.decodeObject(forKey: "time") as! [String]
//    }
//
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(self.isVisible, forKey: "isVisible")
//        aCoder.encode(self.date, forKey: "date")
//        aCoder.encode(self.reps, forKey: "reps")
//        aCoder.encode(self.time, forKey: "time")
//    }
//}
