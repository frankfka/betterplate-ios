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
        return menus?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath)
        cell.textLabel?.text = menus?[indexPath.row].menuName ?? "No Menus Available"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "menuToFoodsSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! FoodsViewController
        if let currentSelectedIndexPath = tableView.indexPathForSelectedRow {
            destinationVC.parentMenuId = menus?[currentSelectedIndexPath.row].menuId
        }
    }

}
