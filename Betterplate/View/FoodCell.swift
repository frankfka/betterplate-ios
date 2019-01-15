//
//  FoodCell.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-19.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import UIKit

class FoodCell: UITableViewCell {

    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var nutritionLabel: UILabel!
    @IBOutlet weak var servingLabel: UILabel!
    @IBOutlet weak var healthWarningLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // This clears the labels so that the dequed cell does not perserve
    // its state and affect display of other cells
    override func prepareForReuse() {
        servingLabel.text = ""
        healthWarningLabel.text = ""
    }
    
    // Update the UI for a given food
    func updateLabels(for food: Food) {
        
        // Will always have nutritional label & food name
        foodNameLabel.text = food.foodName
        nutritionLabel.text = "\(Int(food.calories)) Cal | C: \(Int(food.carbohydrates))g F: \(Int(food.fat))g P: \(Int(food.protein))g"
        // Serving size may not exist
        if let servingSize = food.servingSize {
            servingLabel.text = "Serving Size: " + servingSize
        }
        // Health labels may not exist if the food is healthy enough
        if let healthWarnings = FoodService().getHealthWarnings(for: food) {
            healthWarningLabel.text = healthWarnings
        }
        
    }
}
