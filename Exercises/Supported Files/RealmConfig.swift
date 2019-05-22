//
//  RealmConfig.swift
//  Exercises
//
//  Created by Vitaly Badion on 5/11/19.
//  Copyright © 2019 Vitaly Badion. All rights reserved.
//

import Foundation
import RealmSwift

class RealmConfig {
    
    static var exerciseRealmConfig: Realm.Configuration {
        
        let realmPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("realmConfig")
        
        let config = Realm.Configuration(
            fileURL: realmPath,
            schemaVersion: 0,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 0) {
                    // Realm automaticaly detect new and remove properties
                }
        })
        
        return config
    }
}
