//
//  RestaurantService.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-20.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import Foundation
import RealmSwift

class RestaurantService {
    
    var dataRealm = try! Realm(configuration: RealmConfig.foodDataConfig())
    var allRestaurants: Results<Restaurant>
    
    init() {
        allRestaurants = dataRealm.objects(Restaurant.self).sorted(byKeyPath: "restaurantName", ascending: true)
    }
    
    func getHealthierPicks(for restaurant: Restaurant) -> Results<Food> {
        return getAllFoods(for: restaurant.restaurantId).filter("isFeatured == \(1)")
    }
    
    func getAllFoods(for restaurantId: Int) -> Results<Food> {
        let restaurantMenus = dataRealm.objects(Menu.self).filter("restaurantId == \(restaurantId)")
        var filterString = "menuId == "
        for menu in restaurantMenus {
            filterString.append("\(menu.menuId) OR menuId == ")
        }
        filterString.removeLast(13)
        return dataRealm.objects(Food.self).filter(filterString)
    }
    
    func getRestaurant(from restaurantId: Int) -> Restaurant? {
        let matchingRestaurants = allRestaurants.filter("restaurantId == \(restaurantId)")
        if matchingRestaurants.count > 0 {
            return matchingRestaurants[0]
        }
        return nil
    }
    
    func getAllRestaurantResults() -> Results<Restaurant> {
        return dataRealm.objects(Restaurant.self).sorted(byKeyPath: "restaurantName", ascending: true)
    }
    
}
