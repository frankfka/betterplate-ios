//
//  CurrentMealService.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-16.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import Foundation
import RealmSwift
import SVProgressHUD

class CurrentMealService {
    
    let userRealm = try! Realm(configuration: RealmConfig.userDataConfig())
    let dataRealm = try! Realm(configuration: RealmConfig.foodDataConfig())
    
    func removeFoodFromMeal(food: Food) {
        let matchingFoods = getCurrentMealList().filter("foodId == \(food.foodId)")
        if matchingFoods.count > 0 {
            do {
                try userRealm.write {
                    userRealm.delete(matchingFoods[0])
                    SVProgressHUD.showSuccess(withStatus: "Removed From Meal")
                    SVProgressHUD.dismiss(withDelay: TimeInterval(exactly: 2)!)
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
                SVProgressHUD.showSuccess(withStatus: "Added to Meal")
                SVProgressHUD.dismiss(withDelay: TimeInterval(exactly: 2)!)
            }
        } catch {
            print("Could not add item to meal \(error)")
        }
    }
    
    // TODO consider just using the result class
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
    private func getCurrentMealList() -> Results<CurrentMealItem> {
        return userRealm.objects(CurrentMealItem.self)
    }
    
}
