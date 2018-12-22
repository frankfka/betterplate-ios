//
//  MenusViewController.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-16.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import UIKit
import RealmSwift

class MenusViewController: UITableViewController {

    let realm = try! Realm(configuration: RealmConfig.foodDataConfig())
    var parentRestuaurantId: Int?
    var menus: Results<Menu>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: "menuCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 45
        if let restaurantId = parentRestuaurantId {
            getAllMenus(for: restaurantId)
        }
        // Do any additional setup after loading the view.
    }
    
    func getAllMenus(for restaurantId: Int) {
        menus = realm.objects(Menu.self).filter("restaurantId == \(restaurantId)")
        tableView.reloadData()
    }
    
    //MARK: - TableView Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Adding extra row for "All foods"
        if let listOfMenus = menus {
            return listOfMenus.count + 1
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuCell
        let currentRow = indexPath.row
        if let listOfMenus = menus {
            if currentRow == 0 {
                cell.menuNameLabel.text = "All Items"
            } else {
                cell.menuNameLabel.text = listOfMenus[currentRow - 1].menuName
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "menuToFoodsSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! FoodsViewController
        if let currentSelectedIndexPath = tableView.indexPathForSelectedRow {
            if currentSelectedIndexPath.row == 0 {
                // Initialize parentRestaurant to load all foods
                destinationVC.parentRestaurantId = parentRestuaurantId!
            } else {
                destinationVC.parentMenuId = menus?[currentSelectedIndexPath.row - 1].menuId
            }
        }
    }

}
