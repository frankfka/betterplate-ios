//
//  MealViewController.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-16.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import UIKit

class MealViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var itemsInMeal: [Food] = []
    let mealService = CurrentMealService()
    @IBOutlet weak var mealItemsTable: UITableView!
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
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        itemsInMeal = mealService.getFoodsInMeal()
        mealItemsTable.reloadData()
    }
    
    //MARK: - Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsInMeal.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealItemCell")!
        cell.textLabel?.text = itemsInMeal[indexPath.row].foodName
        return cell
    }
    
    private func populateNutritionViews(for food: Food) {
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
    }
    
}
