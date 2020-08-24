//
//  UserPreference.swift
//  DeliveryFeePinas
//
//  Created by user on 23/8/20.
//  Copyright © 2020 Ernest Martin Gayyed. All rights reserved.
//

import UIKit
import RealmSwift

class UserPreference: Object {
    @objc dynamic var id: String = "0"
    @objc dynamic var currency: Currency?
    @objc dynamic var unitOfDistance: DistanceUnit?
    @objc dynamic var freeRadius: Int = 0
    @objc dynamic var extraDistanceFee: Float = Float(0)
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
