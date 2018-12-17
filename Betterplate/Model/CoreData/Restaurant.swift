//
//  Restaurant.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-15.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import Foundation
import RealmSwift

class Restaurant: Object {
    @objc dynamic var restaurantId: Int = 0
    @objc dynamic var restaurantName: String = ""
    @objc dynamic var brandColor: String = "#FFFFFF"
    @objc dynamic var imageKey: String = ""
    @objc dynamic var healthScore: Int = 0
    @objc dynamic var minCalories: Double = 0
    @objc dynamic var maxCalories: Double = 0
    @objc dynamic var isFeatured: Int = 0
    
    override static func primaryKey() -> String? {
        return "restaurantId"
    }
}
