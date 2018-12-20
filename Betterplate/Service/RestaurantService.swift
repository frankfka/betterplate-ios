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
    
    func getHealthierPicks(for restaurant: Restaurant) -> [Food] {
        let restaurantMenus = dataRealm.objects(Menu.self).filter("restaurantId == \(restaurant.restaurantId)")
        var healthierPicks: [Food] = []
        for menu in restaurantMenus {
            for food in dataRealm.objects(Food.self).filter("menuId == \(menu.menuId) AND isFeatured == \(1)") {
                healthierPicks.append(food)
            }
        }
        return healthierPicks
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
