//
//  SettingsViewController.swift
//  DeliveryFeePinas
//
//  Created by user on 23/8/20.
//  Copyright © 2020 Ernest Martin Gayyed. All rights reserved.
//

import UIKit
import MaterialComponents
import RealmSwift

class SettingsViewController: UIViewController, CurrencySelectionDelegate, DistanceUnitSelectionDelegate {
    
    let realm = try! Realm()
    
    var currency: Currency?
    var distanceUnit: DistanceUnit?
    
    @IBOutlet weak var currencyTextView: MDCTextField!
    @IBOutlet weak var unitTextView: MDCTextField!
    @IBOutlet weak var radiusTextView: MDCTextField!
    @IBOutlet weak var feeTextView: MDCTextField!
    
    var currencyTextController: MDCTextInputControllerFilled!
    var unitTextController: MDCTextInputControllerFilled!
    var freeDistanceTextController: MDCTextInputControllerFilled!
    var feeTextController: MDCTextInputControllerFilled!
    var changesMade = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currencyTextController = MDCTextInputControllerFilled(textInput: currencyTextView)
        self.unitTextController = MDCTextInputControllerFilled(textInput: unitTextView)
        self.freeDistanceTextController = MDCTextInputControllerFilled(textInput: radiusTextView)
        self.feeTextController = MDCTextInputControllerFilled(textInput: feeTextView)
        
        self.currencyTextController.floatingPlaceholderNormalColor = .gray
        self.currencyTextController.floatingPlaceholderActiveColor = .gray
        
        self.freeDistanceTextController.floatingPlaceholderNormalColor = .gray
        self.freeDistanceTextController.floatingPlaceholderActiveColor = .gray
        
        self.feeTextController.floatingPlaceholderNormalColor = .gray
        self.feeTextController.floatingPlaceholderActiveColor = .gray
        
        self.unitTextController.floatingPlaceholderNormalColor = .gray
        self.unitTextController.floatingPlaceholderActiveColor = .gray
        
        radiusTextView.addTarget(self, action: #selector(self.radiusFreeFieldDidChange(_:)), for: .editingChanged)
        feeTextView.addTarget(self, action: #selector(self.extraFeeFieldDidChange(_:)), for: .editingChanged)
        
        let storedPreference = realm.objects(UserPreference.self).first
        if(storedPreference != nil) {
            self.distanceUnit = storedPreference!.unitOfDistance
            self.currency = storedPreference!.currency
            
            currencyTextView.text = storedPreference!.currency!.displayName
            unitTextView.text = storedPreference!.unitOfDistance!.displayName
            radiusTextView.text = String(storedPreference!.freeRadius)
            feeTextView.text = String(storedPreference!.extraDistanceFee)
        }
    }
    
    @objc func radiusFreeFieldDidChange(_ textField: UITextField) {
        setSaveButton()
    }
    
    @objc func extraFeeFieldDidChange(_ textField: UITextField) {
        setSaveButton()
    }
    
    func setSaveButton() {
        let rightButtonItem = UIBarButtonItem.init(
              title: "Save",
              style: .done,
              target: self,
              action: #selector(saveButtonAction(sender:))
        )

        self.navigationItem.rightBarButtonItem = rightButtonItem
    }
    
    @objc func saveButtonAction(sender: UIBarButtonItem) {
        var isValid = true
        
        if(currencyTextView.text == "") {
            isValid = false
            self.currencyTextController.setErrorText("Please provide a currency.", errorAccessibilityValue: nil)
        } else {
            self.currencyTextController.setErrorText(nil, errorAccessibilityValue: nil)
        }
        
        if(unitTextView.text == "") {
            isValid = false
            self.unitTextController.setErrorText("Please provide a unit of distance.", errorAccessibilityValue: nil)
        } else {
            self.unitTextController.setErrorText(nil, errorAccessibilityValue: nil)
        }
        
        if(radiusTextView.text == "") {
            isValid = false
            self.freeDistanceTextController.setErrorText("Please provide a free distance radius.", errorAccessibilityValue: nil)
        } else {
            let radiusValue = radiusTextView.text
            
            if let _ = Int(radiusValue!) {
                self.freeDistanceTextController.setErrorText(nil, errorAccessibilityValue: nil)
            } else {
                isValid = false
                self.freeDistanceTextController.setErrorText("Please provide a valid free distance radius.", errorAccessibilityValue: nil)
            }
        }
        
        if(feeTextView.text == "") {
            isValid = false
            self.feeTextController.setErrorText("Please provide fee for extra distance.", errorAccessibilityValue: nil)
        } else {
            let feeValue = feeTextView.text
            
            if let _ = Int(feeValue!) {
                self.feeTextController.setErrorText(nil, errorAccessibilityValue: nil)
            } else {
                if let _ = Float(feeValue!) {
                    self.feeTextController.setErrorText(nil, errorAccessibilityValue: nil)
                } else {
                    isValid = false
                    self.feeTextController.setErrorText("Please provide a valid fee for extra distance.", errorAccessibilityValue: nil)
                }
            }
        }
        
        if(isValid) {
            let userPreference = UserPreference()
            let freeRadius = Int(radiusTextView.text!)
            let feeExtra = Float(feeTextView.text!)
            
            userPreference.currency = self.currency!
            userPreference.unitOfDistance = self.distanceUnit!
            userPreference.freeRadius = freeRadius!
            userPreference.extraDistanceFee = feeExtra!
            
            try! realm.write {
                realm.add(userPreference, update: .all)
            }
            
            isValid = false
            changesMade = false
            
            self.navigationItem.rightBarButtonItem = nil
            
            let alert = UIAlertController(title: "Successfully saved.", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (_) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func updateCurrency(withCurrency currency: Currency) {
        if(currency.currencyId != self.currency?.currencyId) {
            changesMade = true
            self.currency = currency
            
            setSaveButton()
        }
        
        currencyTextView.text = currency.displayName + " " + currency.currencyId
    }
    
    func updateDistanceUnit(withUnit distanceUnit: DistanceUnit) {
        if(distanceUnit.distanceUnitId != self.distanceUnit?.distanceUnitId) {
            changesMade = true
            self.distanceUnit = distanceUnit
            
            setSaveButton()
        }
        
        unitTextView.text = distanceUnit.displayName + " (" + distanceUnit.distanceUnitId + ")"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowCurrencyList" {
            let controller = segue.destination as! CurrencyTableViewController
            controller.delegate = self
        } else if (segue.identifier == "segueShowDistanceUnit") {
            let controller = segue.destination as! UnitTableViewController
            controller.delegate = self
        }
    }
}

