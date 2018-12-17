//
//  FavoriteRestaurants.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-16.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import Foundation
import RealmSwift

class FavoriteRestaurants: Object {
    @objc dynamic var favoriteRestaurantId: Int = 0
    let favoriteRestaurantIds: [Int] = []
    
    override static func primaryKey() -> String? {
        return "favoriteRestaurantId"
    }
    
}
