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
    
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var addToMealButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do some checking?
        food = realm.objects(Food.self).filter("foodId == \(foodId!)")[0]
        foodNameLabel.text = food?.foodName
        CurrentMealService().getCurrentMealList()
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
