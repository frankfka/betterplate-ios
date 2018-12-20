//
//  RestaurantOverviewViewController.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-19.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import UIKit
import RealmSwift

class RestaurantOverviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let realm = try! Realm(configuration: RealmConfig.foodDataConfig())
    var parentRestuaurantId: Int?
    var restaurant: Restaurant?
    var healthierPicks: [Food]?
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var healthierPicksTable: FitContentTableView!
    @IBOutlet weak var restaurantTitle: UILabel!
    @IBOutlet weak var isFavoritedBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let restaurantId = parentRestuaurantId {
            
            // Get Restaurants
            restaurant = realm.objects(Restaurant.self).filter("restaurantId == \(restaurantId)")[0]
            
            // Update images & favorites
            headerImage.image = UIImage(named: restaurant!.imageKey)
            //TODO Change background color
            restaurantTitle.text = restaurant!.restaurantName
            updateIsFavorite(toggle: false)
            
            // Set up tableview
            healthierPicksTable.delegate = self
            healthierPicksTable.dataSource = self
            healthierPicksTable.isScrollEnabled = false
            healthierPicks = RestaurantService().getHealthierPicks(for: restaurant!)
            healthierPicksTable.register(UINib(nibName: "FoodCell", bundle: nil), forCellReuseIdentifier: "foodCell")
            healthierPicksTable.rowHeight = UITableView.automaticDimension
            healthierPicksTable.estimatedRowHeight = 60
            
        }
    }
    
    //MARK: - Button methods & segues
    @IBAction func favoriteBarButtonPressed(_ sender: UIBarButtonItem) {
        updateIsFavorite(toggle: true)
    }
    
    @IBAction func viewMenuButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "restaurantOverviewToMenusSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! MenusViewController
        destinationVC.parentRestuaurantId = parentRestuaurantId!
    }
    
    //MARK: - Tableview methods
    // TODO should superclass food tableviews
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return healthierPicks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath) as! FoodCell
        let food = healthierPicks![indexPath.row]
        cell.foodNameLabel.text = food.foodName
        cell.updateNutritionLabel(for: food)
        return cell
    }    
    
    // MARK: - Helper methods
    private func updateIsFavorite(toggle: Bool) {
        let favoriteRestaurantService = FavoriteRestaurantService()
        var isFavorited = favoriteRestaurantService.isRestaurantFavorited(restaurant: restaurant!)
        if toggle && isFavorited {
            isFavorited = !isFavorited
            favoriteRestaurantService.removeRestaurantFromFavorites(restaurant: restaurant!)
        } else if toggle && !isFavorited {
            isFavorited = !isFavorited
            favoriteRestaurantService.addRestaurantToFavorites(restaurant: restaurant!)
        }
        if isFavorited {
            isFavoritedBarButton.image = UIImage(named: "favorite_filled_primary")
        } else {
            isFavoritedBarButton.image = UIImage(named: "favorite_primary")
        }
    }

}
