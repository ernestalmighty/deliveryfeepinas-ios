//
//  Currency.swift
//  DeliveryFeePinas
//
//  Created by user on 23/8/20.
//  Copyright © 2020 Ernest Martin Gayyed. All rights reserved.
//

import UIKit
import RealmSwift

class Currency: Object {
    @objc dynamic var currencyId: String = ""
    @objc dynamic var displayName: String = ""
    
    override class func primaryKey() -> String? {
        return "currencyId"
    }
}
