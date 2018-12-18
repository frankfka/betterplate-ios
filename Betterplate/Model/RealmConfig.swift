//
//  RealmConfig.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-15.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import Foundation
import RealmSwift

class RealmConfig {
    
    static func foodDataConfig() -> Realm.Configuration {
        return Realm.Configuration(fileURL: Bundle.main.url(forResource: "BetterplateData", withExtension: "realm"), readOnly: true, objectTypes: [Food.self, Menu.self, Restaurant.self])
        
        // The following is for empty Realm data initialization
//        return Realm.Configuration(objectTypes: [Food.self, Menu.self, Restaurant.self])
    }
    
    static func userDataConfig() -> Realm.Configuration {
        return Realm.Configuration(objectTypes: [CurrentMealItem.self, FavoriteRestaurant.self])
    }
    
}
