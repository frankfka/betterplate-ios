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
    
    // TODO change these to nicer labels
    static let calories = 0
    static let fat = 1
    static let saturatedFat = 2
    static let transFat = 3
    static let cholesterol = 4
    static let sodium = 5
    static let carbohydrates = 6
    static let fiber = 7
    static let sugar = 8
    static let protein = 9
    static let calcium = 10
    static let iron = 11
    static let vitaminA = 12
    static let vitaminC = 13
    
    let userRealm = try! Realm(configuration: RealmConfig.userDataConfig())
    let dataRealm = try! Realm(configuration: RealmConfig.foodDataConfig())
    
    func removeFoodFromMeal(withId foodId: Int) {
        let matchingFoods = getCurrentMealList().filter("foodId == \(foodId)")
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
    
    func addFoodToMeal(withId foodId: Int) {
        let newMealItem = CurrentMealItem()
        newMealItem.foodId = foodId
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
    
    func getMealNutrition(for listOfFoods: [Food]) -> [Int: Double] {
        var calories = 0.0
        var fat = 0.0
        var saturatedFat = 0.0
        var transFat = 0.0
        var cholesterol = 0.0
        var sodium = 0.0
        var carbohydrates = 0.0
        var fiber = 0.0
        var sugar = 0.0
        var protein = 0.0
        var calcium = 0.0
        var iron = 0.0
        var vitaminA = 0.0
        var vitaminC = 0.0
        for food in listOfFoods {
            calories += food.calories
            fat += food.fat
            saturatedFat += food.saturatedFat
            transFat += food.transFat
            cholesterol += food.cholesterol
            sodium += food.sodium
            carbohydrates += food.carbohydrates
            fiber += food.fiber
            sugar += food.sugar
            protein += food.protein
            calcium += food.calcium
            iron += food.iron
            vitaminA += food.vitaminA
            vitaminC += food.vitaminC
        }
        return [CurrentMealService.calories: calories,
        CurrentMealService.fat: fat,
        CurrentMealService.saturatedFat: saturatedFat,
        CurrentMealService.transFat: transFat,
        CurrentMealService.cholesterol: cholesterol,
        CurrentMealService.sodium: sodium,
        CurrentMealService.carbohydrates: carbohydrates,
        CurrentMealService.fiber: fiber,
        CurrentMealService.protein: protein,
        CurrentMealService.calcium: calcium,
        CurrentMealService.iron: iron,
        CurrentMealService.vitaminA: vitaminA,
        CurrentMealService.vitaminC: vitaminC]
    }
    
    // Returns list of food ID's, if none currently exists in realm, will populate one automatically
    private func getCurrentMealList() -> Results<CurrentMealItem> {
        return userRealm.objects(CurrentMealItem.self)
    }
    
}
