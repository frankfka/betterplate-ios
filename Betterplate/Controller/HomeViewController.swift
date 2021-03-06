//
//  ViewController.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-15.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import UIKit
import RealmSwift
import SVProgressHUD
import MessageUI

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var favoriteRestaurantsTable: UITableView!
    @IBOutlet weak var favoriteRestaurantsHeight: NSLayoutConstraint!
    @IBOutlet weak var mealTable: UITableView!
    @IBOutlet weak var mealTableHeight: NSLayoutConstraint!
    @IBOutlet weak var nutritionOverviewLabel: UILabel!
    @IBOutlet weak var emptyMealHelpLabel: UILabel!
    @IBOutlet weak var emptyFavRestaurantsHelpLabel: UILabel!
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    var itemsInMeal: [Food] = []
    var favoriteRestaurants: [Restaurant] = []
    let mealService = CurrentMealService()
    let favoriteRestaurantService = FavoriteRestaurantService()
    
    override func viewDidLoad() {
        //homeToFoodSegue
        super.viewDidLoad()
        favoriteRestaurantsTable.delegate = self
        favoriteRestaurantsTable.dataSource = self
        favoriteRestaurantsTable.register(UINib(nibName: "RestaurantCell", bundle: nil), forCellReuseIdentifier: "restaurantCell")
        mealTable.delegate = self
        mealTable.dataSource = self
        mealTable.register(UINib(nibName: "FoodCell", bundle: nil), forCellReuseIdentifier: "foodCell")
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateViews()
    }
    
    private func updateViews() {
        // Get data
        itemsInMeal = mealService.getFoodsInMeal()
        favoriteRestaurants = favoriteRestaurantService.getAllFavoriteRestaurants()
        let mealNutrition = mealService.getMealNutrition(for: itemsInMeal)
        
        // Reload views
        nutritionOverviewLabel.text = "\(Int(mealNutrition[CurrentMealService.calories] ?? 0)) Cal | C: \(Int(mealNutrition[CurrentMealService.carbohydrates] ?? 0))g F: \(Int(mealNutrition[CurrentMealService.fat] ?? 0))g P: \(Int(mealNutrition[CurrentMealService.protein] ?? 0))g"
        favoriteRestaurantsTable.reloadData()
        mealTable.reloadData()
        
        // Show or display helper text
        if (favoriteRestaurants.isEmpty) {
            emptyFavRestaurantsHelpLabel.text = "Add restaurants to favorites for easy access."
        } else {
            emptyFavRestaurantsHelpLabel.text = ""
        }
        if (itemsInMeal.isEmpty) {
            emptyMealHelpLabel.text = "Add items to your meal to see overall nutrition."
        } else {
            emptyMealHelpLabel.text = ""
        }
        
        // Reinitialize constraints
        ViewHelperService.updateTableviewSize(tableView: mealTable, tableViewHeightConstraint: mealTableHeight)
        ViewHelperService.updateTableviewSize(tableView: favoriteRestaurantsTable, tableViewHeightConstraint: favoriteRestaurantsHeight)
        // TODO this doesnt work :(
        ViewHelperService.updateScrollViewSize(scrollView: mainScrollView)
    }

    // MARK: - Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == mealTable {
            return itemsInMeal.count
        } else {
            return favoriteRestaurants.count
        }
        // TODO might want to check that the else statement is actually the other tableview, but should be OK
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == mealTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell") as! FoodCell
            cell.updateLabels(for: itemsInMeal[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as! RestaurantCell
            cell.updateLabels(for: favoriteRestaurants[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == mealTable {
            performSegue(withIdentifier: "homeToFoodSegue", sender: self)
        } else {
            performSegue(withIdentifier: "homeToRestaurantSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeToFoodSegue" {
            let destinationVC = segue.destination as! FoodDetailViewController
            if let currentSelectedIndexPath = mealTable.indexPathForSelectedRow {
                destinationVC.foodId = itemsInMeal[currentSelectedIndexPath.row].foodId
            }
        } else if segue.identifier == "homeToRestaurantSegue" {
            let destinationVC = segue.destination as! RestaurantOverviewViewController
            if let currentSelectedIndexPath = favoriteRestaurantsTable.indexPathForSelectedRow {
                destinationVC.parentRestuaurantId = favoriteRestaurants[currentSelectedIndexPath.row].restaurantId
            }
        }
    }
    
    // MARK: - Contact Button
    @IBAction func contactButtonPressed(_ sender: UIButton) {
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            SVProgressHUD.showError(withStatus: "Mail Services are Not Available")
            SVProgressHUD.dismiss(withDelay: TimeInterval(exactly: 2)!)
            return
        }
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.setToRecipients(["frank@betterplate.app"])
        composeVC.setSubject("Betterplate Feedback")
        composeVC.setMessageBody("", isHTML: false)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }

}

