//
//  HomeViewController.swift
//  DeliveryFeePinas
//
//  Created by user on 23/8/20.
//  Copyright © 2020 Ernest Martin Gayyed. All rights reserved.
//

import UIKit
import RealmSwift

class HomeViewController: UIViewController {
    @IBOutlet weak var currencyText: UILabel!
    @IBOutlet weak var distanceUnitLabel: UILabel!
    @IBOutlet weak var freeRadiusLabel: UILabel!
    @IBOutlet weak var feeDistanceLabel: UILabel!
    @IBOutlet weak var sourceAddressLabel: UILabel!
    @IBOutlet weak var destAddressLabel: UILabel!
    
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let storedPreference = realm.objects(UserPreference.self).first
        if(storedPreference != nil) {
            currencyText.text = storedPreference!.currency?.displayName
            distanceUnitLabel.text = storedPreference!.unitOfDistance?.displayName
            freeRadiusLabel.text = String(storedPreference!.freeRadius)
            feeDistanceLabel.text = String(storedPreference!.extraDistanceFee)
        }
        
        let storedSource = realm.objects(SourceAddress.self).first
        if(storedSource != nil) {
            sourceAddressLabel.text = String(storedSource!.sourceAddress)
        }
        
        let storedDestination = realm.objects(DestinationAddress.self).first
        if(storedDestination != nil) {
            destAddressLabel.text = String(storedDestination!.destinationAddress)
        }
    }

}
