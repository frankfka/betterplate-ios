//
//  FavoriteRestaurantService.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-19.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import Foundation
import RealmSwift

class FavoriteRestaurantService {
    
    let userRealm = try! Realm(configuration: RealmConfig.userDataConfig())
    let dataRealm = try! Realm(configuration: RealmConfig.foodDataConfig())
    
    func isRestaurantFavorited(restaurant: Restaurant) -> Bool {
        return getAllFavoriteRestaurants().contains(restaurant)
    }
    
    func addRestaurantToFavorites(restaurant: Restaurant) {
        if !isRestaurantFavorited(restaurant: restaurant) {
            do {
                try userRealm.write {
                    let newFavoriteRestaurant = FavoriteRestaurant()
                    newFavoriteRestaurant.restaurantId = restaurant.restaurantId
                    userRealm.add(newFavoriteRestaurant)
                }
            } catch {
                print("Could not add restaurant \(restaurant.restaurantId) to favorites")
            }
        }
    }
    
    func removeRestaurantFromFavorites(restaurant: Restaurant) {
        if isRestaurantFavorited(restaurant: restaurant) {
            do {
                try userRealm.write {
                    userRealm.delete(getFavoriteRestaurants().filter("restaurantId == \(restaurant.restaurantId)")[0])
                }
            } catch {
                print("Could not remove restaurant \(restaurant.restaurantId) from favorites")
            }
        }
    }
    
    // TODO consider just using the result class
    func getAllFavoriteRestaurants() -> [Restaurant] {
        var allFavoriteRestaurants: [Restaurant] = []
        for restaurant in getFavoriteRestaurants() {
            allFavoriteRestaurants.append(dataRealm.objects(Restaurant.self).filter("restaurantId == \(restaurant.restaurantId)")[0])
        }
        return allFavoriteRestaurants
    }
    
    private func getFavoriteRestaurants() -> Results<FavoriteRestaurant> {
        return userRealm.objects(FavoriteRestaurant.self)
    }
    
}
