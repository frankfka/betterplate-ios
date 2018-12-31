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
    
    func sortFoods(for foodList: Results<Food>, with sortType: FoodSortType) -> Results<Food> {
        if sortType == .SORT_BY_ALPHABETICAL {
            return foodList.sorted(byKeyPath: "foodName", ascending: true)
        } else if sortType == .SORT_BY_INC_CAL {
            return foodList.sorted(byKeyPath: "calories", ascending: true)
        } else if sortType == .SORT_BY_DEC_PROTEIN {
            return foodList.sorted(byKeyPath: "protein", ascending: false)
        } else if sortType == .SORT_BY_INC_CARBS {
            return foodList.sorted(byKeyPath: "carbohydrates", ascending: true)
        } else if sortType == .SORT_BY_INC_FAT {
            return foodList.sorted(byKeyPath: "fat", ascending: true)
        }
        
//        else if sortType == .SORT_BY_DEC_HEALTH {
//            return foodList.sorted(byKeyPath: "healthScore", ascending: false)
//        }
        
        return foodList
    }
    
    func filterFoods(for foodList: Results<Food>, with filters: Dictionary<FoodFilters, String>) -> Results<Food> {
        
        //TODO temp workaround until sqlite structure is changed
        var wantsGF = 0
        var wantsVeg = 0
        if Bool(filters[.WANTS_GF]!)! {
            wantsGF = 1
        }
        if Bool(filters[.WANTS_VEG]!)! {
            wantsVeg = 1
        }
        
        let filterString = "(isGF == \(wantsGF)) AND (isVegetarian == \(wantsVeg)) AND "
            + "(calories <= \(filters[.MAX_CALS]!)) AND (calories >= \(filters[.MIN_CALS]!)) AND "
            + "(fat <= \(filters[.MAX_FAT]!)) AND (fat >= \(filters[.MIN_FAT]!)) AND "
            + "(carbohydrates <= \(filters[.MAX_CARBS]!)) AND (carbohydrates >= \(filters[.MIN_CARBS]!)) AND "
            + "(protein <= \(filters[.MAX_PROTEIN]!)) AND (protein >= \(filters[.MIN_PROTEIN]!))"
        return foodList.filter(filterString)
    }
    
}

enum FoodFilters {
    case MIN_CALS
    case MAX_CALS
    case MIN_PROTEIN
    case MAX_PROTEIN
    case MIN_FAT
    case MAX_FAT
    case MIN_CARBS
    case MAX_CARBS
    case WANTS_VEG
    case WANTS_GF
}

enum FoodSortType {
    case SORT_BY_ALPHABETICAL
    case SORT_BY_INC_CAL
    case SORT_BY_DEC_PROTEIN
    case SORT_BY_INC_CARBS
    case SORT_BY_INC_FAT
    case SORT_BY_DEC_HEALTH
}
