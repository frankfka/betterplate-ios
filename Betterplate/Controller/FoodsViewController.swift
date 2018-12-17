//
//  FoodsViewController.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-16.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import UIKit
import RealmSwift

class FoodsViewController: UITableViewController {

    let realm = try! Realm(configuration: RealmConfig.foodDataConfig())
    var parentMenuId: Int?
    var foods: Results<Food>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let menuId = parentMenuId {
            getAllFoods(for: menuId)
        }
        // Do any additional setup after loading the view.
    }
    
    func getAllFoods(for menuId: Int) {
        foods = realm.objects(Food.self).filter("menuId == \(menuId)")
        tableView.reloadData()
    }
    
    //MARK: - TableView Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath)
        cell.textLabel?.text = foods?[indexPath.row].foodName ?? "No Foods Available"
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

}
