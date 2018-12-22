//
//  MenuService.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-20.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import Foundation
import RealmSwift

class MenuService {
    
    var dataRealm = try! Realm(configuration: RealmConfig.foodDataConfig())
    
    func getFoods(for menuId: Int) -> Results<Food> {
        return dataRealm.objects(Food.self).filter("menuId == \(menuId)")
    }

}
