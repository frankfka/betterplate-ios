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
    
    func removeFoodFromMeal(food: Food) {
        
    }
    
    func addFoodToMeal(food: Food) {
        
    }
    
    // Returns list of food ID's, if none currently exists in realm, will populate one automatically
    func getCurrentMealList() {
        let mealObjectResult = userRealm.objects(CurrentMeal.self)
        if mealObjectResult.count > 0 {
            print("in here")
        } else {
            print("No meal object exists, initializing empty meal")
            do {
                try userRealm.write {
                    userRealm.add(CurrentMeal())
                }
            } catch {
                print("Error creating a meal object: \(error)")
            }
        }
        
    }
    
}
