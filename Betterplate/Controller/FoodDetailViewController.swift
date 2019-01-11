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
        
        // Populate chart
        // First calculate the macro percentages
        let totalMacros = food.carbohydrates * 4 + food.protein * 4 + food.fat * 9 // Percentages are based on total calories
        let percentageCarbs = food.carbohydrates * 4 / totalMacros
        let percentageProtein = food.protein * 4 / totalMacros
        let percentageFat = food.fat * 9 / totalMacros
        
        // Data entries corresponding to the percentages
        let proteinDataEntry = PieChartDataEntry(value: percentageProtein, label: "Protein")
        let carbsDataEntry = PieChartDataEntry(value: percentageCarbs, label: "Carbs")
        let fatDataEntry = PieChartDataEntry(value: percentageFat, label: "Fat")
        
        // Chart setup - define the list of entries
        let chartDataEntries = [proteinDataEntry, carbsDataEntry, fatDataEntry]
        
        // Define data set (just the 3 percentages)
        let chartDataSet = PieChartDataSet(values: chartDataEntries, label: "")
        chartDataSet.colors = ChartColorTemplates.material()
        chartDataSet.selectionShift = CGFloat(0)
        
        // Define the chart data
        let chartData = PieChartData(dataSet: chartDataSet)
        // This prevents label values from being squished together
        // We just stop showing values if a food is predominantly carbs/fat/protein
        if((percentageCarbs < 0.1 && percentageFat < 0.1) || (percentageCarbs < 0.1 && percentageProtein < 0.1) || (percentageFat < 0.1 && percentageProtein < 0.1)) {
            print("in here")
            chartData.setDrawValues(false)
        }
        let percentFormatter = NumberFormatter() // We want to format with percentages
        percentFormatter.numberStyle = .percent
        percentFormatter.maximumFractionDigits = 0
        percentFormatter.multiplier = 1
        percentFormatter.percentSymbol = "%"
        chartData.setValueFormatter(DefaultValueFormatter(formatter: percentFormatter))
        chartData.setValueFont(.systemFont(ofSize: 14, weight: .regular))
        chartData.setValueTextColor(.white)
        
        // Legend settings
        let chartLegend = pieChart.legend
        chartLegend.font = .systemFont(ofSize: 14, weight: .regular)
        chartLegend.formSize = CGFloat(integerLiteral: 14)
        chartLegend.wordWrapEnabled = true
        chartLegend.horizontalAlignment = .center
        chartLegend.verticalAlignment = .bottom
        chartLegend.orientation = .horizontal
        
        // Pie Chart Settings
        pieChart.data = chartData
        pieChart.drawEntryLabelsEnabled = false
        pieChart.chartDescription?.enabled = true
        pieChart.holeRadiusPercent = CGFloat(0.2)
        pieChart.entryLabelColor = .white
        pieChart.transparentCircleRadiusPercent = CGFloat(0)
        pieChart.usePercentValuesEnabled = true
        
    }
}
