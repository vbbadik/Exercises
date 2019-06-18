//
//  SaveAndLoadExersices.swift
//  Exercises
//
//  Created by Vitaly Badion on 3/4/19.
//  Copyright © 2019 Vitaly Badion. All rights reserved.
//

import Foundation

struct SaveAndLoadData<T: Codable> {

    // Сохранение упражения
    func save(_ exercises: [T], to file: URL) {
        
        // Codable protocol
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(exercises)
            try data.write(to: file)
        } catch {
            fatalError("Save failed \(error)")
        }
    }

    // Загрузка упражений
    func load(from file: URL) -> [T] {
        
        // Codable protocol
        guard let data = try? Data(contentsOf: file) else { return [T]() }
        let decoder = PropertyListDecoder()
        
        do {
            return try decoder.decode([T].self, from: data)
        } catch {
            fatalError("Load failed \(error)")
        }
    }
}
