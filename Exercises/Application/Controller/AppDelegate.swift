//
//  AppDelegate.swift
//  Exercise
//
//  Created by Vitaly Badion on 10.06.2018.
//  Copyright © 2018 Vitaly Badion. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let mainController = ExercisesViewController()
        let navigationController = UINavigationController(rootViewController: mainController)
        
        window?.frame = UIScreen.main.bounds
        window?.backgroundColor = .white
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        // Настройка внешнего вида Navigation Bar
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.8462908864, green: 0.1336644292, blue: 0.1662362516, alpha: 1)
        UINavigationBar.appearance().tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().isTranslucent = false //Полупрозрачный Navigation Bar
        navigationController.navigationBar.barStyle = .black //Белый цвет для символов в статус баре
        
        // Миграция базы данных Realm
        
//        Realm.Configuration.defaultConfiguration = Realm.Configuration(
//            schemaVersion: 1,
//            migrationBlock: { migration, oldSchemaVersion in
//                if (oldSchemaVersion < 1) {
//                    // The enumerateObjects(ofType:_:) method iterates
//                    // over every Person object stored in the Realm file
//                    migration.enumerateObjects(ofType: Exercise.className()) { oldObject, newObject in
//                        // combine name fields into a single field
//                        newObject!["sortID"] = 0
//                    }
//                }
//        })
//        
//        let realm = try! Realm()
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        return true
    }

}

