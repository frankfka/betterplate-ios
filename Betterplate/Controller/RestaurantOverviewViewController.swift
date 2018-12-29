//
//  RestaurantOverviewViewController.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-19.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import UIKit
import RealmSwift
import RangeSeekSlider

class RestaurantOverviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let realm = try! Realm(configuration: RealmConfig.foodDataConfig())
    let restaurantService = RestaurantService()
    var parentRestuaurantId: Int?
    var restaurant: Restaurant?
    var healthierPicks: Results<Food>?
    var pickedFoodItemId: Int?
    var advancedSearchFilters: [FoodFilters:String]?
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var healthierPicksTable: UITableView!
    @IBOutlet weak var restaurantTitle: UILabel!
    @IBOutlet weak var isFavoritedBarButton: UIBarButtonItem!
    @IBOutlet weak var healthierPicksTableHeightConstraint: NSLayoutConstraint!
    // Advanced Search
    @IBOutlet weak var calSlider: RangeSeekSlider!
    @IBOutlet weak var proteinSlider: RangeSeekSlider!
    @IBOutlet weak var carbSlider: RangeSeekSlider!
    @IBOutlet weak var fatSlider: RangeSeekSlider!
    @IBOutlet weak var vegetarianSwitch: UISwitch!
    @IBOutlet weak var gfSwitch: UISwitch!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var advancedSearchButton: UIButton!
    @IBOutlet weak var advancedSearchResultsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let restaurantId = parentRestuaurantId {
            
            let viewHelper = ViewHelperService()
            
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
            healthierPicks = RestaurantService().getHealthierPicks(for: restaurant!)
            healthierPicksTable.register(UINib(nibName: "FoodCell", bundle: nil), forCellReuseIdentifier: "foodCell")
            viewHelper.updateTableviewSize(tableView: healthierPicksTable, tableViewHeightConstraint: healthierPicksTableHeightConstraint)
            
            // Update scrollview size
            viewHelper.updateScrollViewSize(scrollView: mainScrollView)
            
            // Set up sliders with min & max values from the food list
            calSlider.delegate = self
            proteinSlider.delegate = self
            fatSlider.delegate = self
            carbSlider.delegate = self
            initializeSliders()
            updateAdvancedSearch()
            
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
        } else if segue.identifier == "advancedSearchToFoodsSegue" {
            let destinationVC = segue.destination as! FoodsViewController
            destinationVC.parentRestaurantId = parentRestuaurantId!
            destinationVC.foodFilters = advancedSearchFilters!
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
    
    // MARK: - Advanced Search Stuff
    @IBAction func advancedSearchButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "advancedSearchToFoodsSegue", sender: self)
    }
    
    @IBAction func searchResetButtonPressed(_ sender: UIButton) {
        initializeSliders()
        // TODO seems to be a bug - needs to be called twice. also can optimize performance in that function
        initializeSliders()
        updateAdvancedSearch()
    }
    
    @IBAction func vegetarianButtonToggled(_ sender: UISwitch) {
        updateAdvancedSearch()
    }
    
    @IBAction func gfButtonToggled(_ sender: UISwitch) {
        updateAdvancedSearch()
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
    
    private func getRoundedCGFloat(for value: Double, roundedTo: Double) -> CGFloat {
        return CGFloat(roundedTo) * CGFloat(value / roundedTo).rounded(.up)
    }

}

// MARK: - RangeSeekSliderDelegate
extension RestaurantOverviewViewController: RangeSeekSliderDelegate {
    
    func didEndTouches(in slider: RangeSeekSlider) {
        updateAdvancedSearch()
    }
    
    private func updateAdvancedSearch() {
        // States
        let minCalories = calSlider.selectedMinValue
        let maxCalories = calSlider.selectedMaxValue
        let minProtein = proteinSlider.selectedMinValue
        let maxProtein = proteinSlider.selectedMaxValue
        let minCarbs = carbSlider.selectedMinValue
        let maxCarbs = carbSlider.selectedMaxValue
        let minFat = fatSlider.selectedMinValue
        let maxFat = fatSlider.selectedMaxValue
        let wantsVeg = vegetarianSwitch.isOn
        let wantsGF = gfSwitch.isOn
        let filters: [FoodFilters: String] = [
            .MIN_CALS:minCalories.description,
            .MAX_CALS:maxCalories.description,
            .MIN_PROTEIN:minProtein.description,
            .MAX_PROTEIN:maxProtein.description,
            .MIN_CARBS:minCarbs.description,
            .MAX_CARBS:maxCarbs.description,
            .MIN_FAT:minFat.description,
            .MAX_FAT:maxFat.description,
            .WANTS_GF: String(wantsGF),
            .WANTS_VEG: String(wantsVeg)
        ]
        
        // Update variables and labels
        self.advancedSearchFilters = filters
        let numResults = FoodService().filterFoods(for: restaurantService.getAllFoods(for: parentRestuaurantId!), with: filters).count
        advancedSearchResultsLabel.text = "Number of Results: \(numResults)"
    }
    
    private func initializeSliders() {
        var allFoodsForRestaurant: Results<Food> = restaurantService.getAllFoods(for: parentRestuaurantId!)
        allFoodsForRestaurant = allFoodsForRestaurant.sorted(byKeyPath: "calories", ascending: true)
        calSlider.minValue = getRoundedCGFloat(for: allFoodsForRestaurant.first!.calories, roundedTo: 50)
        calSlider.maxValue = getRoundedCGFloat(for: allFoodsForRestaurant.last!.calories, roundedTo: 50)
        calSlider.selectedMinValue = calSlider.minValue
        calSlider.selectedMaxValue = calSlider.maxValue
        
        allFoodsForRestaurant = allFoodsForRestaurant.sorted(byKeyPath: "protein", ascending: true)
        proteinSlider.minValue = getRoundedCGFloat(for: allFoodsForRestaurant.first!.protein, roundedTo: 10)
        proteinSlider.maxValue = getRoundedCGFloat(for: allFoodsForRestaurant.last!.protein, roundedTo: 10)
        proteinSlider.selectedMinValue = proteinSlider.minValue
        proteinSlider.selectedMaxValue = proteinSlider.maxValue
        
        allFoodsForRestaurant = allFoodsForRestaurant.sorted(byKeyPath: "fat", ascending: true)
        fatSlider.minValue = getRoundedCGFloat(for: allFoodsForRestaurant.first!.fat, roundedTo: 10)
        fatSlider.maxValue = getRoundedCGFloat(for: allFoodsForRestaurant.last!.fat, roundedTo: 10)
        fatSlider.selectedMinValue = fatSlider.minValue
        fatSlider.selectedMaxValue = fatSlider.maxValue
        
        allFoodsForRestaurant = allFoodsForRestaurant.sorted(byKeyPath: "carbohydrates", ascending: true)
        carbSlider.minValue = getRoundedCGFloat(for: allFoodsForRestaurant.first!.carbohydrates, roundedTo: 10)
        carbSlider.maxValue = getRoundedCGFloat(for: allFoodsForRestaurant.last!.carbohydrates, roundedTo: 10)
        carbSlider.selectedMinValue = carbSlider.minValue
        carbSlider.selectedMaxValue = carbSlider.maxValue
        
        gfSwitch.setOn(false, animated: true)
        vegetarianSwitch.setOn(false, animated: true)
    }
    
    
}
