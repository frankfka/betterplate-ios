//
//  FoodsViewController.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-16.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import UIKit
import RealmSwift
import PopMenu

class FoodsViewController: UITableViewController, UISearchBarDelegate {
    
    let realm = try! Realm(configuration: RealmConfig.foodDataConfig())
    // For all items
    var parentRestaurantId: Int?
    // For menu
    var parentMenuId: Int?
    // For advanced search
    var foodFilters: [FoodFilters: String]?
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var searchBar: UISearchBar!
    var foods: Results<Food>?
    var foodsToSearchFrom: Results<Food>?
    var selectedSortType: FoodSortType = .SORT_BY_ALPHABETICAL
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Searchbar init
        searchBar.delegate = self
        
        // Tableview methods
        tableView.register(UINib(nibName: "FoodCell", bundle: nil), forCellReuseIdentifier: "foodCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        loadFoods()
    }
    
    private func loadFoods() {
        
        let foodService = FoodService()
        let restaurantService = RestaurantService()
        
        // Retrieve foods from menu or get all (and filter if filters are given)
        if let menuId = parentMenuId {
            
            navItem.title = realm.objects(Menu.self).filter("menuId == \(menuId)")[0].menuName
            foods = MenuService().getFoods(for: menuId)
            foodsToSearchFrom = MenuService().getFoods(for: menuId)
            
        } else if let restaurantId = parentRestaurantId {
            if let searchFilters = foodFilters {
                navItem.title = "Search Results"
                foods = foodService.filterFoods(for: restaurantService.getAllFoods(for: restaurantId), with: searchFilters)
                foodsToSearchFrom = foodService.filterFoods(for: restaurantService.getAllFoods(for: restaurantId), with: searchFilters)
            } else {
                navItem.title = "All Items"
                foods = restaurantService.getAllFoods(for: restaurantId)
                foodsToSearchFrom = restaurantService.getAllFoods(for: restaurantId)
            }
        }
        
        foods = foodService.sortFoods(for: foods!, with: selectedSortType)
        foodsToSearchFrom = foodService.sortFoods(for: foodsToSearchFrom!, with: selectedSortType)
        tableView.reloadData()
    }
    
    //MARK: - TableView Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath) as! FoodCell
        let food = foods![indexPath.row]
        cell.updateLabels(for: food)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showFoodDetailsSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! FoodDetailViewController
        if let currentSelectedIndexPath = tableView.indexPathForSelectedRow {
            destinationVC.foodId = foods?[currentSelectedIndexPath.row].foodId
        }
    }
    
    //MARK: - Search bar methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            foods = foodsToSearchFrom?.filter("foodName CONTAINS[cd] %@", searchBar.text!)
            tableView.reloadData()
        } else {
            loadFoods()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        loadFoods()
        searchBar.resignFirstResponder()
    }
    
    //MARK: - Sorting method
    @IBAction func onSortButtonPressed(_ sender: UIBarButtonItem) {
        let menuManager = PopMenuManager.default
        menuManager.popMenuAppearance.popMenuCornerRadius = CGFloat(integerLiteral: 4)
        // Disable scrolling using the below
        menuManager.popMenuAppearance.popMenuActionCountForScrollable = UInt(exactly: 6)!
        let alphabeticalSort = PopMenuDefaultAction(title: "Alphabetical") { (action) in
            self.selectedSortType = .SORT_BY_ALPHABETICAL
            self.loadFoods()
        }
        let caloriesSort = PopMenuDefaultAction(title: "Calories (Low to High)") { (action) in
            self.selectedSortType = .SORT_BY_INC_CAL
            self.loadFoods()
        }
        let proteinSort = PopMenuDefaultAction(title: "Protein (High to Low)") { (action) in
            self.selectedSortType = .SORT_BY_DEC_PROTEIN
            self.loadFoods()
        }
        let carbSort = PopMenuDefaultAction(title: "Carbohydrates (Low to High)") { (action) in
            self.selectedSortType = .SORT_BY_INC_CARBS
            self.loadFoods()
        }
        let fatSort = PopMenuDefaultAction(title: "Fat (Low to High)") { (action) in
            self.selectedSortType = .SORT_BY_INC_FAT
            self.loadFoods()
        }
//        let healthSort = PopMenuDefaultAction(title: "Healthiness (High to Low)") { (action) in
//            self.selectedSortType = .SORT_BY_DEC_HEALTH
//            self.loadFoods()
//        }
        // TODO find a way to add healthSort
        
        menuManager.actions = [alphabeticalSort, caloriesSort, proteinSort, carbSort, fatSort]
        menuManager.present()
    }

}
