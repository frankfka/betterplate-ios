//
//  MealViewController.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-16.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import UIKit

class MealViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var itemsInMeal: [Food] = []
    let mealService = CurrentMealService()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        itemsInMeal = mealService.getFoodsInMeal()
        tableView.reloadData()
    }
    
    //MARK: - Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsInMeal.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealItemCell")!
        cell.textLabel?.text = itemsInMeal[indexPath.row].foodName
        return cell
    }
    
}
