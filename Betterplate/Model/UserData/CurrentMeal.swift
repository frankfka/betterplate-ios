//
//  CurrentMeal.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-16.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import Foundation
import RealmSwift

class CurrentMeal: Object {
    @objc dynamic var mealId: Int = 0
    let mealFoodIds: [Int] = []
    
    override static func primaryKey() -> String? {
        return "mealId"
    }
    
}
