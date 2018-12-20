//
//  FoodDetailViewController.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-16.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import UIKit
import RealmSwift

class FoodDetailViewController: UIViewController {
    
    let realm = try! Realm(configuration: RealmConfig.foodDataConfig())
    var foodId:Int?
    var food:Food?
    let mealService = CurrentMealService()
    
    @IBOutlet weak var foodNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let currentFoodId = foodId {
            food = realm.objects(Food.self).filter("foodId == \(currentFoodId)")[0]
            foodNameLabel.text = food?.foodName
        } else {
            // Show some error?
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        if let currentFood = food {
            mealService.addFoodToMeal(food: currentFood)
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
