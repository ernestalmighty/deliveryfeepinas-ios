//
//  CurrencyTableViewController.swift
//  DeliveryFeePinas
//
//  Created by user on 23/8/20.
//  Copyright © 2020 Ernest Martin Gayyed. All rights reserved.
//

import UIKit

class CurrencyTableViewController: UITableViewController {

    var currencys: [Currency] = []
    var delegate: CurrencySelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let phCurrency = Currency()
        phCurrency.currencyId = "PHP"
        phCurrency.displayName = "Philippine Peso"
        
        let sgCurrency = Currency()
        sgCurrency.currencyId = "SGD"
        sgCurrency.displayName = "Singapore Dollars"
        
        let usCurrency = Currency()
        usCurrency.currencyId = "USD"
        usCurrency.displayName = "US Dollars"
        
        currencys = [phCurrency, sgCurrency, usCurrency]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currencys.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(65)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = CurrencyTableViewCell()
        
        if let orderCell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath) as? CurrencyTableViewCell {
            orderCell.configureCurrency(currency: currencys[indexPath.row])
            
            cell = orderCell
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.updateCurrency(withCurrency: currencys[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
}

extension Locale {
    static let currency: [String: (code: String?, symbol: String?)] = Locale.isoRegionCodes.reduce(into: [:]) {
        let locale = Locale(identifier: Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: $1]))
        $0[$1] = (locale.currencyCode, locale.currencySymbol)
    }
}
