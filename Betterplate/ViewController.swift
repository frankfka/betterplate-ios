//
//  ViewController.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-15.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let realm = try! Realm(configuration: RealmConfig.foodDataConfig())
        // Do any additional setup after loading the view, typically from a nib.
    }


}

