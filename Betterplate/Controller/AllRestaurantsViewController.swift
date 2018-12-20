//
//  AllRestaurantsViewController.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-16.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import UIKit
import RealmSwift

class AllRestaurantsViewController: UITableViewController, UISearchBarDelegate {
    
    let realm = try! Realm(configuration: RealmConfig.foodDataConfig())
    var restaurants: Results<Restaurant>?
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllRestaurants()
        searchBar.delegate = self
        tableView.register(UINib(nibName: "RestaurantCell", bundle: nil), forCellReuseIdentifier: "restaurantCell")
    }

    func getAllRestaurants() {
        restaurants = RestaurantService().getAllRestaurantResults()
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
        performSegue(withIdentifier: "allRestaurantsToOverviewSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! RestaurantOverviewViewController
        if let currentSelectedIndexPath = tableView.indexPathForSelectedRow {
            destinationVC.parentRestuaurantId = restaurants?[currentSelectedIndexPath.row].restaurantId
        }
    }
    
    //MARK: - Search bar methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        restaurants = restaurants?.filter("restaurantName CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "restaurantName", ascending: true)
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0  {
            getAllRestaurants()
            // This grabs the main thread, where UI changes should be persisted
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

}
