//
//  DestinationAddress.swift
//  DeliveryFeePinas
//
//  Created by user on 24/8/20.
//  Copyright © 2020 Ernest Martin Gayyed. All rights reserved.
//

import UIKit
import RealmSwift

class DestinationAddress: Object {
    @objc dynamic var id: String = "0"
    @objc dynamic var destinationAddress: String = ""
    @objc dynamic var destLat: Double = 0.0
    @objc dynamic var destLong: Double = 0.0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
