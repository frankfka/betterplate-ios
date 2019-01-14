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
    
    // Sorts a list of foods given a sort type
    func sortFoods(for foodList: Results<Food>, with sortType: FoodSortType) -> Results<Food> {
        
        // Compare & use the relevant property name
        // TODO - might want to store these property names in a constants class so they stay consistent if anything changes
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
        
        // Cannot sort Realm by a non-property, so a workaround must be found
//        else if sortType == .SORT_BY_DEC_HEALTH {
//            return foodList.sorted(byKeyPath: "healthScore", ascending: false)
//        }
        
        return foodList
    }
    
    // Filters a list of foods given a dictionary of parameters
    func filterFoods(for foodList: Results<Food>, with filters: Dictionary<FoodFilters, String>) -> Results<Food> {
        
        // Convert boolean values to 1 & 0
        var wantsGF = 0
        var wantsVeg = 0
        if Bool(filters[.WANTS_GF]!)! {
            wantsGF = 1
        }
        if Bool(filters[.WANTS_VEG]!)! {
            wantsVeg = 1
        }
        
        // Construct the filter query
        let filterString = "(isGF == \(wantsGF)) AND (isVegetarian == \(wantsVeg)) AND "
            + "(calories <= \(filters[.MAX_CALS]!)) AND (calories >= \(filters[.MIN_CALS]!)) AND "
            + "(fat <= \(filters[.MAX_FAT]!)) AND (fat >= \(filters[.MIN_FAT]!)) AND "
            + "(carbohydrates <= \(filters[.MAX_CARBS]!)) AND (carbohydrates >= \(filters[.MIN_CARBS]!)) AND "
            + "(protein <= \(filters[.MAX_PROTEIN]!)) AND (protein >= \(filters[.MIN_PROTEIN]!))"
        return foodList.filter(filterString)
    
    }
    
    // Returns a formatted string with the health warnings for a particular food, with new lines between each warning
    // Returns nil if no health warnings exist -> easier to check whether we need to update UI
    func getHealthWarnings(for food: Food) -> String? {
        
        var warningString = ""
        if food.calories >= 1100 {
            warningString += "High in Calories\n"
        }
        if food.sodium >= 1200 {
            warningString += "High in Sodium\n"
        }
        if food.sugar >= 20 {
            warningString += "High in Sugar\n"
        }
        if food.transFat >= 1 {
            warningString += "High in Trans Fat\n"
        }
        warningString = warningString.trimmingCharacters(in: .whitespacesAndNewlines)
        return warningString.count > 0 ? warningString : nil
    }
    
    // Returns the macronutrient breakdown for a list of foods as a dictionary
    func getMacrosInPercent(for foods: [Food]) -> [Macronutrient: Double] {
        
        var macrosDict: [Macronutrient: Double] = [Macronutrient.CARBS: 0, Macronutrient.FAT: 0, Macronutrient.PROTEIN: 0]
        var totalCals = 0.0
        var totalCarbs = 0.0
        var totalProtein = 0.0
        var totalFat = 0.0
        
        for food in foods {
            let calsFromCarbs = food.carbohydrates * 4
            let calsFromProtein = food.protein * 4
            let calsFromFat = food.fat * 9
            totalCarbs = totalCarbs + calsFromCarbs
            totalFat = totalFat + calsFromFat
            totalProtein = totalProtein + calsFromProtein
            totalCals = totalCals + (calsFromFat + calsFromCarbs + calsFromProtein)
        }
        
        macrosDict[Macronutrient.CARBS] = totalCarbs / totalCals
        macrosDict[Macronutrient.FAT] = totalFat / totalCals
        macrosDict[Macronutrient.PROTEIN] = totalProtein / totalCals
        
        return macrosDict
    }
    
}

// Enums for filter/sort comparison
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

enum Macronutrient {
    case CARBS
    case PROTEIN
    case FAT
}
