//
//  StoreManager.swift
//  Arkanoid
//
//  Created by Admin on 17.10.2022.
//

import Foundation

struct StoreManager {
    static let shared = StoreManager()
    
    func save<T> (_ value: T, forKey: String) {
        UserDefaults.standard.set(value, forKey: forKey)
    }
    
    func getValue(forKey: String) -> Any? {
        UserDefaults.standard.value(forKey: forKey) as? Any
    }
}
