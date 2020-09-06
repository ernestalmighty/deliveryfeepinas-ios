//
//  HomeViewController.swift
//  DeliveryFeePinas
//
//  Created by user on 23/8/20.
//  Copyright © 2020 Ernest Martin Gayyed. All rights reserved.
//

import UIKit
import RealmSwift
import Lottie

class HomeViewController: UIViewController {
    @IBOutlet weak var currencyText: UILabel!
    @IBOutlet weak var distanceUnitLabel: UILabel!
    @IBOutlet weak var freeRadiusLabel: UILabel!
    @IBOutlet weak var feeDistanceLabel: UILabel!
    @IBOutlet weak var sourceAddressLabel: UILabel!
    @IBOutlet weak var destAddressLabel: UILabel!
    @IBOutlet weak var settingsCardView: UIView!
    @IBOutlet weak var fromCardView: UIView!
    @IBOutlet weak var toCardView: UIView!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var deliveryLottieView: AnimationView!
    @IBOutlet weak var preferenceCardView: UIView!
    @IBOutlet weak var aboutCardView: UIView!
    
    
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()

        preferenceCardView.layer.cornerRadius = 24.0
        aboutCardView.layer.cornerRadius = 24.0
        
        deliveryLottieView.contentMode = .scaleAspectFill
        deliveryLottieView.loopMode = .loop
        
        deliveryLottieView.animationSpeed = 0.5
        
        // 4. Play animation
        deliveryLottieView.play()
        
        settingsCardView.layer.cornerRadius = 24.0
        settingsCardView.layer.shadowRadius = 5.0
        settingsCardView.layer.shadowOpacity = 0.2
        
        fromCardView.layer.cornerRadius = 24.0
        
        toCardView.layer.cornerRadius = 24.0
        
        calculateButton.layer.cornerRadius = 24.0
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        super.viewWillAppear(animated)
    }


    override func viewWillDisappear(_ animated: Bool) {
        if (navigationController?.topViewController != self) {
            navigationController?.navigationBar.isHidden = false
        }
        super.viewWillDisappear(animated)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "segueShowResults" {
            let storedSource = realm.objects(SourceAddress.self).first
            if(storedSource == nil) {
                let alert = UIAlertController(title: "You didn't set your source location yet.", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                return false
            }
            
            let storedDestination = realm.objects(DestinationAddress.self).first
            if(storedDestination == nil) {
                let alert = UIAlertController(title: "You didn't set your destionation yet.", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            let storedPreference = realm.objects(UserPreference.self).first
            if(storedPreference == nil) {
                let alert = UIAlertController(title: "You didn't set your preferences yet.", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            
            return true
        } else {
            return true
        }
    }
}
