//
//  Food.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-15.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import Foundation
import RealmSwift

class Food: Object {
    @objc dynamic var foodId: Int = 0
    @objc dynamic var menuId: Int = 0
    @objc dynamic var foodName: String = ""
    @objc dynamic var servingSize: String?
    @objc dynamic var calories: Double = 0
    @objc dynamic var carbohydrates: Double = 0
    @objc dynamic var protein: Double = 0
    @objc dynamic var fat: Double = 0
    @objc dynamic var saturatedFat: Double = 0
    @objc dynamic var transFat: Double = 0
    @objc dynamic var cholesterol: Double = 0
    @objc dynamic var sodium: Double = 0
    @objc dynamic var fiber: Double = 0
    @objc dynamic var sugar: Double = 0
    @objc dynamic var vitaminA: Double = 0
    @objc dynamic var vitaminC: Double = 0
    @objc dynamic var calcium: Double = 0
    @objc dynamic var iron: Double = 0
    @objc dynamic var isVegan: Int = 0
    @objc dynamic var isVegetarian: Int = 0
    @objc dynamic var isGF: Int = 0
    @objc dynamic var isFeatured: Int = 0
    
    override static func primaryKey() -> String? {
        return "foodId"
    }
    
}
