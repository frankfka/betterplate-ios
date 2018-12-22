//
//  RestaurantCell.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-18.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import UIKit

class RestaurantCell: UITableViewCell {
    
    @IBOutlet var restaurantNameLabel: UILabel!
    @IBOutlet var restaurantImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateLabels(for restaurant: Restaurant) {
        restaurantNameLabel.text = restaurant.restaurantName
        restaurantImage.image = UIImage(named: restaurant.imageKey)
    }
    
}
