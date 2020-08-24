//
//  DestinationViewController.swift
//  DeliveryFeePinas
//
//  Created by user on 24/8/20.
//  Copyright © 2020 Ernest Martin Gayyed. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import RealmSwift

class DestinationViewController: UIViewController, GMSAutocompleteViewControllerDelegate {

    @IBOutlet weak var destMapView: GMSMapView!
    @IBOutlet weak var destinationLabel: UILabel!
    
    let locationManager = CLLocationManager()
    let realm = try! Realm()
    var hasChanges = false
    var mapMarker: GMSMarker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        destMapView.delegate = self
        
        let realmSource = realm.objects(DestinationAddress.self).first
        if(realmSource != nil) {
            destinationLabel.text = realmSource?.destinationAddress
            
            let coordinate = CLLocationCoordinate2DMake(realmSource!.destLat, realmSource!.destLong)
            
            destMapView.camera = GMSCameraPosition(
                target: coordinate,
                zoom: 19,
                bearing: 0,
                viewingAngle: 0)
            
            mapMarker = GMSMarker(position: coordinate)
            mapMarker!.title = "Destination"
            mapMarker!.map = destMapView
            mapMarker!.isDraggable = true
        } else {
            locationManager.delegate = self
            if CLLocationManager.locationServicesEnabled() {
              // 3
              locationManager.requestLocation()

              // 4
              destMapView.isMyLocationEnabled = true
              destMapView.settings.myLocationButton = true
            } else {
              // 5
              locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        setSaveButton()
        
        let location = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        
        destMapView.camera = GMSCameraPosition(
            target: location.coordinate,
            zoom: 19,
            bearing: 0,
            viewingAngle: 0)
        
        mapMarker?.position = place.coordinate
        
        var userAddress: [String] = []
        
        for addressComponent in place.addressComponents! {
            userAddress.append(String(addressComponent.name))
        }
        
        destinationLabel.text = userAddress.joined(separator: ", ")
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
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
        let realmSource = realm.objects(DestinationAddress.self).first
        
        if(realmSource != nil) {
            try! realm.write {
                realmSource!.destinationAddress = destinationLabel.text!
                realmSource!.destLat = Double(mapMarker!.position.latitude)
                realmSource!.destLong = Double(mapMarker!.position.longitude)
            }
        } else {
            let newPreference = DestinationAddress()
            
            newPreference.destinationAddress = destinationLabel.text!
            newPreference.destLat = Double(mapMarker!.position.latitude)
            newPreference.destLong = Double(mapMarker!.position.longitude)
            
            try! realm.write {
                realm.add(newPreference, update: .modified)
            }
        }
        
        self.navigationItem.rightBarButtonItem = nil
    }
    
    @IBAction func onAddressTapped(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.primaryTextColor = UIColor.gray
        autocompleteController.primaryTextHighlightColor = UIColor.black
        autocompleteController.secondaryTextColor = .gray
        
        autocompleteController.delegate = self

        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.coordinate.rawValue | UInt(GMSPlaceField.addressComponents.rawValue)))!
        autocompleteController.placeFields = fields

        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        filter.countries = ["PH"]
        autocompleteController.autocompleteFilter = filter

        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }
}

extension DestinationViewController: CLLocationManagerDelegate {
    func locationManager(
      _ manager: CLLocationManager,
      didChangeAuthorization status: CLAuthorizationStatus
    ) {
      // 3
      guard status == .authorizedWhenInUse else {
        return
      }
      // 4
      locationManager.requestLocation()

      //5
      destMapView.isMyLocationEnabled = true
      destMapView.settings.myLocationButton = true
    }

    // 6
    func locationManager(
      _ manager: CLLocationManager,
      didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        destMapView.camera = GMSCameraPosition(
            target: location.coordinate,
            zoom: 19,
            bearing: 0,
            viewingAngle: 0)
        
        let position = location.coordinate
        mapMarker = GMSMarker(position: position)
        mapMarker!.title = "Source"
        mapMarker!.map = destMapView
        mapMarker!.isDraggable = true
        
        let geoCoder = GMSGeocoder()
        geoCoder.reverseGeocodeCoordinate(position, completionHandler: { response, error in
            let gmsAddress: GMSAddress = response!.firstResult()!
            self.destinationLabel.text = gmsAddress.lines?.first!
        })
        
        manager.stopUpdatingLocation()
        manager.delegate = nil
    }

    // 8
    func locationManager(
      _ manager: CLLocationManager,
      didFailWithError error: Error
    ) {
      print(error)
    }
}

extension DestinationViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
    }
    
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        setSaveButton()
        mapMarker?.position = coordinate
        
        let position = mapMarker?.position
        let geoCoder = GMSGeocoder()
        geoCoder.reverseGeocodeCoordinate(position!, completionHandler: { response, error in
            let gmsAddress: GMSAddress = response!.firstResult()!
            self.destinationLabel.text = gmsAddress.lines?.first!
        })
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        setSaveButton()
        let position = mapMarker?.position
        let geoCoder = GMSGeocoder()
        geoCoder.reverseGeocodeCoordinate(position!, completionHandler: { response, error in
            let gmsAddress: GMSAddress = response!.firstResult()!
            self.destinationLabel.text = gmsAddress.lines?.first!
        })
    }
}
