//
//  Menu.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-15.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import Foundation
import RealmSwift

class Menu: Object {
    @objc dynamic var menuId: Int = 0
    @objc dynamic var menuName: String = ""
    @objc dynamic var restaurantId: Int = 0
}
