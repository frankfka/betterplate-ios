//
//  AllRestaurantsViewController.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-16.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import UIKit
import RealmSwift

class AllRestaurantsViewController: UITableViewController {
    
    let realm = try! Realm(configuration: RealmConfig.foodDataConfig())
    var restaurants: Results<Restaurant>?

    override func viewDidLoad() {
        super.viewDidLoad()
        getAllRestaurants()
        tableView.register(UINib(nibName: "RestaurantCell", bundle: nil), forCellReuseIdentifier: "restaurantCell")
        // Do any additional setup after loading the view.
    }

    func getAllRestaurants() {
        restaurants = realm.objects(Restaurant.self)
        tableView.reloadData()
    }
    
    //MARK: - TableView Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as! RestaurantCell
        if let restaurant = restaurants?[indexPath.row] {
            cell.restaurantNameLabel.text = restaurant.restaurantName
            cell.restaurantImage.image = UIImage(named: restaurant.imageKey)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "restaurantToMenuSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! MenusViewController
        if let currentSelectedIndexPath = tableView.indexPathForSelectedRow {
            destinationVC.parentRestuaurantId = restaurants?[currentSelectedIndexPath.row].restaurantId
        }
    }

}
