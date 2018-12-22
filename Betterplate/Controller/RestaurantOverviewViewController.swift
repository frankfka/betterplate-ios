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
    var healthierPicks: Results<Food>?
    var pickedFoodItemId: Int?
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var healthierPicksTable: UITableView!
    @IBOutlet weak var restaurantTitle: UILabel!
    @IBOutlet weak var isFavoritedBarButton: UIBarButtonItem!
    @IBOutlet weak var healthierPicksTableHeightConstraint: NSLayoutConstraint!
    
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
            healthierPicksTable.estimatedRowHeight = 80
            healthierPicksTableHeightConstraint.constant = 1000
            UIView.animate(withDuration: 0, animations: {
                self.healthierPicksTable.layoutIfNeeded()
            }) { (complete) in
                var heightOfTableView: CGFloat = 0.0
                // Get visible cells and sum up their heights
                let cells = self.healthierPicksTable.visibleCells
                for cell in cells {
                    heightOfTableView += cell.frame.height
                }
                self.healthierPicksTableHeightConstraint.constant = heightOfTableView
            }
            
            // Update scrollview size
            var contentRect = CGRect.zero
            for view in mainScrollView.subviews {
                contentRect = contentRect.union(view.frame)
            }
            mainScrollView.contentSize = contentRect.size
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
        if segue.identifier == "restaurantOverviewToMenusSegue" {
            let destinationVC = segue.destination as! MenusViewController
            destinationVC.parentRestuaurantId = parentRestuaurantId!
        } else if segue.identifier == "healthyPicksToFoodDetailsSegue" {
            let destinationVC = segue.destination as! FoodDetailViewController
            destinationVC.foodId = pickedFoodItemId!
        }
    }
    
    //MARK: - Tableview methods
    // TODO should superclass food tableviews
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return healthierPicks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath) as! FoodCell
        let food = healthierPicks![indexPath.row]
        cell.updateLabels(for: food)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pickedFoodItemId = healthierPicks![indexPath.row].foodId
        performSegue(withIdentifier: "healthyPicksToFoodDetailsSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
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
