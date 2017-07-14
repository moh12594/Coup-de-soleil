//
//  Utilities.swift
//  Coup de soleil
//
//  Created by Mohamed SADAT on 12/07/2017.
//  Copyright © 2017 Mohsadat. All rights reserved.
//

import Foundation


class Utilities {
    
    func getStorage () -> UserDefaults {
        return UserDefaults.standard
    }
    
    func setSkinType (value: String) {
        let defaults = getStorage()
        
        defaults.setValue(value, forKey: defaultKeys.skinType)
        defaults.synchronize()
    }
    
    func getSkinType () -> String {
        let defaults = getStorage()
        if let result = defaults.string(forKey: defaultKeys.skinType) {
            return result
        }
        return SkinType().type1
    }
    
}
