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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateLabels(for food: Food) {
        foodNameLabel.text = food.foodName
        nutritionLabel.text = "\(Int(food.calories)) Cal | C: \(Int(food.carbohydrates))g F: \(Int(food.fat))g P: \(Int(food.protein))g"
        if let servingSize = food.servingSize {
            servingLabel.text = "Serving Size: " + servingSize
        }
    }
}
