//
//  DataCallback.swift
//  Exercises
//
//  Created by Vitaly Badion on 10/2/18.
//  Copyright © 2018 Vitaly Badion. All rights reserved.
//

import Foundation

// Подробная статья об создании https://swiftbook.ru/post/tutorials/do-you-forget-write-weak-in-closures/
struct DataTransfer<Input> {
    private var callback: ((Input) -> Void)?
    
    mutating func passData<Object: AnyObject>(to object: Object, with callback: @escaping ((Object, Input) -> Void)) {
        self.callback = { [weak object] input in
            guard let object = object else { return }
            callback(object, input)
        }
    }
}
