//
//  UnitTableViewController.swift
//  DeliveryFeePinas
//
//  Created by user on 23/8/20.
//  Copyright © 2020 Ernest Martin Gayyed. All rights reserved.
//

import UIKit

class UnitTableViewController: UITableViewController {

    var unitDataSource: [DistanceUnit] = []
    var delegate: DistanceUnitSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let kmUnit = DistanceUnit()
        kmUnit.distanceUnitId = "km"
        kmUnit.displayName = "Kilometers"
        
        let mileUnit = DistanceUnit()
        mileUnit.distanceUnitId = "mi"
        mileUnit.displayName = "Miles"
        
        let meterUnit = DistanceUnit()
        meterUnit.distanceUnitId = "m"
        meterUnit.displayName = "Meters"
        
        unitDataSource = [kmUnit, mileUnit, meterUnit]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return unitDataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = DistanceUnitTableViewCell()
        
        if let unitCell = tableView.dequeueReusableCell(withIdentifier: "distanceUnitCell", for: indexPath) as? DistanceUnitTableViewCell {
            
            unitCell.configureDistanceUnit(unit: unitDataSource[indexPath.row])
            
            cell = unitCell
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.updateDistanceUnit(withUnit: unitDataSource[indexPath.row])
        dismiss(animated: true, completion: nil)
    }

}
