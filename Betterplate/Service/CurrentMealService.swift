//
//  CurrentMealService.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-16.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import Foundation
import RealmSwift

class CurrentMealService {
    
    let userRealm = try! Realm(configuration: RealmConfig.userDataConfig())
    let dataRealm = try! Realm(configuration: RealmConfig.foodDataConfig())
    
    func removeFoodFromMeal(food: Food) {
        let matchingFoods = getCurrentMealList().filter("foodId == \(food.foodId)")
        if matchingFoods.count > 0 {
            do {
                try userRealm.write {
                    userRealm.delete(matchingFoods[0])
                }
            } catch {
                print("Could not remove item from meal \(error)")
            }
        }
    }
    
    func addFoodToMeal(food: Food) {
        let newMealItem = CurrentMealItem()
        newMealItem.foodId = food.foodId
        do {
            try userRealm.write {
                userRealm.add(newMealItem)
            }
        } catch {
            print("Could not add item to meal \(error)")
        }
    }
    
    func getFoodsInMeal() -> [Food] {
        let mealItems = getCurrentMealList()
        var foodsInMeal:[Food] = []
        for item in mealItems {
            let foodObjects = dataRealm.objects(Food.self).filter("foodId == \(item.foodId)")
            if foodObjects.count > 0 {
                foodsInMeal.append(foodObjects[0])
            } else {
                print("Somehow no food exists for this meal item with food ID \(item.foodId)")
            }
        }
        return foodsInMeal
    }
    
    // Returns list of food ID's, if none currently exists in realm, will populate one automatically
    func getCurrentMealList() -> Results<CurrentMealItem> {
        return userRealm.objects(CurrentMealItem.self)
    }
    
}
