//
//  FoodDetailViewController.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-16.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import UIKit
import RealmSwift
import Charts

class FoodDetailViewController: UIViewController {
    
    let realm = try! Realm(configuration: RealmConfig.foodDataConfig())
    var foodId:Int?
    let mealService = CurrentMealService()
    let foodService = FoodService()
    let viewService = ViewHelperService()
    
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var nutritionSummaryLabel: UILabel!
    @IBOutlet weak var servingSizeLabel: UILabel!
    // Nutriton Stuff
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var totFatLabel: UILabel!
    @IBOutlet weak var satFatLabel: UILabel!
    @IBOutlet weak var transFatLabel: UILabel!
    @IBOutlet weak var cholesterolLabel: UILabel!
    @IBOutlet weak var sodiumLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var fiberLabel: UILabel!
    @IBOutlet weak var sugarLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var calciumLabel: UILabel!
    @IBOutlet weak var ironLabel: UILabel!
    @IBOutlet weak var vitALabel: UILabel!
    @IBOutlet weak var vitCLabel: UILabel!
    // Nutrition Breakdown
    @IBOutlet weak var pieChart: PieChartView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let currentFoodId = foodId {
            let food = realm.objects(Food.self).filter("foodId == \(currentFoodId)")[0]
            foodNameLabel.text = food.foodName
            nutritionSummaryLabel.text = "\(Int(food.calories)) Cal | C: \(Int(food.carbohydrates))g F: \(Int(food.fat))g P: \(Int(food.protein))g"
            if let servingSize = food.servingSize {
                servingSizeLabel.text = "Serving Size: \(servingSize)"
            }
            // Separate method so we can extract this stuff later
            populateNutritionViews(for: food)
        } else {
            print("Current food ID not initialized")
            // Show some error?
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        if let currentFoodId = foodId {
            mealService.addFoodToMeal(withId: currentFoodId)
        }
    }
    
    private func populateNutritionViews(for food: Food) {
        
        // Populate labels
        caloriesLabel.text = "\(food.calories) Cal"
        totFatLabel.text = "\(food.fat) g"
        satFatLabel.text = "\(food.saturatedFat) g"
        transFatLabel.text = "\(food.transFat) g"
        cholesterolLabel.text = "\(food.cholesterol) mg"
        sodiumLabel.text = "\(food.sodium) mg"
        carbsLabel.text = "\(food.carbohydrates) g"
        fiberLabel.text = "\(food.fiber) g"
        sugarLabel.text = "\(food.sugar) g"
        proteinLabel.text = "\(food.protein) g"
        calciumLabel.text = "\(food.calcium) %"
        ironLabel.text = "\(food.iron) %"
        vitALabel.text = "\(food.vitaminA) %"
        vitCLabel.text = "\(food.vitaminC) %"
        
        // Populate chart only if there are calories
        pieChart.noDataFont = UIFont (name: "HelveticaNeue-Light", size: 16)
        pieChart.noDataText = "This item has no macronutrients."
        if food.calories >= 4 {
            let macros = foodService.getMacrosInPercent(for: [food])
            viewService.initializeNutritionPieChart(for: pieChart, percentageProtein: macros[Macronutrient.PROTEIN]!, percentageCarbs: macros[Macronutrient.CARBS]!, percentageFat: macros[Macronutrient.FAT]!)
        }
        // Else do nothing, Charts will display "No data available"
        
    }
}
