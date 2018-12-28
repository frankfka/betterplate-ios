//
//  MealViewController.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-16.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import UIKit
import RangeSeekSlider

class MealViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var itemsInMeal: [Food] = []
    let mealService = CurrentMealService()
    let viewHelper = ViewHelperService()
    @IBOutlet weak var emptyMealHelpLabel: UILabel!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mealItemsTable: UITableView!
    @IBOutlet weak var mealItemsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mealNutritionOverview: UILabel!
    // Nutrition Stuff
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mealItemsTable.dataSource = self
        mealItemsTable.delegate = self
        mealItemsTable.register(UINib(nibName: "FoodCell", bundle: nil), forCellReuseIdentifier: "foodCell")
        
        updateViews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // BUG - can't put this in updateViews()
        mealItemsTable.setEditing(false, animated: true)
        updateViews()
    }
    
    //MARK: - Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsInMeal.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell") as! FoodCell
        cell.updateLabels(for: itemsInMeal[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            mealService.removeFoodFromMeal(withId: itemsInMeal[indexPath.row].foodId)
            updateViews()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "mealToFoodSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! FoodDetailViewController
        if let currentSelectedIndexPath = mealItemsTable.indexPathForSelectedRow {
            destinationVC.foodId = itemsInMeal[currentSelectedIndexPath.row].foodId
        }
    }
    
    // MARK: - Edit item methods
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if mealItemsTable.isEditing {
            mealItemsTable.setEditing(false, animated: true)
            sender.title = "Edit"
        } else {
            mealItemsTable.setEditing(true, animated: true)
            sender.title = "Done"
        }
    }
    
    // MARK: - Misc helper methods
    private func updateViews() {
        // Update nutrition summary
        
        // Update tableview
        itemsInMeal = mealService.getFoodsInMeal()
        mealItemsTable.reloadData()
        viewHelper.updateTableviewSize(tableView: mealItemsTable, tableViewHeightConstraint: mealItemsHeightConstraint)
        viewHelper.updateScrollViewSize(scrollView: mainScrollView)
        
        // Edit button & help text
        if itemsInMeal.isEmpty {
            editButton.isEnabled = false
            emptyMealHelpLabel.text = "Add items to your meal to see overall nutrition."
            editButton.title = "Edit"
        } else {
            editButton.isEnabled = true
            emptyMealHelpLabel.text = ""
        }
        
        // Update nutritional info
        populateNutritionDetailViews(for: itemsInMeal)
        
    }
    
    private func populateNutritionDetailViews(for foods: [Food]) {
        let mealNutrition = mealService.getMealNutrition(for: foods)
        
        // Overview text
        mealNutritionOverview.text = "\(Int(mealNutrition[CurrentMealService.calories] ?? 0)) Cal | C: \(Int(mealNutrition[CurrentMealService.carbohydrates] ?? 0))g F: \(Int(mealNutrition[CurrentMealService.fat] ?? 0))g P: \(Int(mealNutrition[CurrentMealService.protein] ?? 0))g"
        
        // Details
        caloriesLabel.text = "\(mealNutrition[CurrentMealService.calories] ?? 0) Cal"
        totFatLabel.text = "\(mealNutrition[CurrentMealService.fat] ?? 0) g"
        satFatLabel.text = "\(mealNutrition[CurrentMealService.saturatedFat] ?? 0) g"
        transFatLabel.text = "\(mealNutrition[CurrentMealService.transFat] ?? 0) g"
        cholesterolLabel.text = "\(mealNutrition[CurrentMealService.cholesterol] ?? 0) mg"
        sodiumLabel.text = "\(mealNutrition[CurrentMealService.sodium] ?? 0) mg"
        carbsLabel.text = "\(mealNutrition[CurrentMealService.carbohydrates] ?? 0) g"
        fiberLabel.text = "\(mealNutrition[CurrentMealService.fiber] ?? 0) g"
        sugarLabel.text = "\(mealNutrition[CurrentMealService.sugar] ?? 0) g"
        proteinLabel.text = "\(mealNutrition[CurrentMealService.protein] ?? 0) g"
        calciumLabel.text = "\(mealNutrition[CurrentMealService.calcium] ?? 0) %"
        ironLabel.text = "\(mealNutrition[CurrentMealService.iron] ?? 0) %"
        vitALabel.text = "\(mealNutrition[CurrentMealService.vitaminA] ?? 0) %"
        vitCLabel.text = "\(mealNutrition[CurrentMealService.vitaminC] ?? 0) %"
    }
    
}
