//
//  FoodService.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-20.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import Foundation
import RealmSwift

public class FoodService {
    
    static let SORT_BY_ALPHABETICAL = 0
    static let SORT_BY_INC_CAL = 1
    static let SORT_BY_DEC_PROTEIN = 2
    static let SORT_BY_INC_CARBS = 3
    static let SORT_BY_INC_FAT = 4
    
    func sortFoods(for foodList: Results<Food>, with sortType: Int) -> Results<Food> {
        if sortType == FoodService.SORT_BY_ALPHABETICAL {
            return foodList.sorted(byKeyPath: "foodName", ascending: true)
        } else if sortType == FoodService.SORT_BY_INC_CAL {
            return foodList.sorted(byKeyPath: "calories", ascending: true)
        } else if sortType == FoodService.SORT_BY_DEC_PROTEIN {
            return foodList.sorted(byKeyPath: "protein", ascending: false)
        } else if sortType == FoodService.SORT_BY_INC_CARBS {
            return foodList.sorted(byKeyPath: "carbohydrates", ascending: true)
        } else if sortType == FoodService.SORT_BY_INC_FAT {
            return foodList.sorted(byKeyPath: "fat", ascending: true)
        }
        return foodList
    }
    
}
