//
//  ResultViewController.swift
//  DeliveryFeePinas
//
//  Created by user on 24/8/20.
//  Copyright © 2020 Ernest Martin Gayyed. All rights reserved.
//

import UIKit
import GoogleMaps
import RealmSwift
import GoogleMobileAds

class ResultViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var distanceCoveredLabel: UILabel!
    @IBOutlet weak var distanceChargedLabel: UILabel!
    @IBOutlet weak var distanceFreeLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    
    let realm = try! Realm()
    var gmsCoordinateBounds: GMSCoordinateBounds? = nil
    var markers: [GMSMarker] = []
    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-1965212949581065/7668551588")
        let request = GADRequest()
        interstitial.load(request)
        
        mapView.layer.cornerRadius = 24.0
        cardView.layer.cornerRadius = 24.0
        
        calculateRoute()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if interstitial.isReady {
          interstitial.present(fromRootViewController: self)
        } else {
          print("Ad wasn't ready")
        }
    }
    
    func calculateRoute() {
        let realmSource = self.realm.objects(SourceAddress.self).first
        let sourceCoordinate = CLLocationCoordinate2DMake(realmSource!.sourceLat, realmSource!.sourceLong)
        let sourceMarker = GMSMarker(position: sourceCoordinate)
        sourceMarker.title = "Source"
        sourceMarker.map = mapView
        
        markers.append(sourceMarker)
        
        let realmDestination = self.realm.objects(DestinationAddress.self).first
        let destinationCoordinate = CLLocationCoordinate2DMake(realmDestination!.destLat, realmDestination!.destLong)
        let destMarker = GMSMarker(position: destinationCoordinate)
        destMarker.title = "Destination"
        destMarker.map = mapView
        
        markers.append(destMarker)
        
        
        let distanceInMeters = CLLocation(latitude: CLLocationDegrees(sourceCoordinate.latitude), longitude: CLLocationDegrees(sourceCoordinate.longitude)).distance(from: CLLocation(latitude: CLLocationDegrees(destinationCoordinate.latitude), longitude: CLLocationDegrees(destinationCoordinate.longitude)))
        
        let preference = realm.objects(UserPreference.self).first
        
        if(preference != nil) {
            var distanceFloat = Float(distanceInMeters)
            var distance = String(format: "%.2f %@", distanceInMeters, "m")
            if(preference?.unitOfDistance?.distanceUnitId == "km") {
                distance = String(format: "%.2f %@", distanceInMeters/1000, "km")
                distanceFloat = distanceFloat/1000
            } else if (preference?.unitOfDistance?.distanceUnitId == "mi") {
                distance = String(format: "%.2f %@", distanceInMeters/1609, "mi")
                distanceFloat = distanceFloat/1609
            }
            
            distanceCoveredLabel.text = distance
            distanceFreeLabel.text = String(format: "%d %@", preference!.freeRadius, String((preference?.unitOfDistance!.distanceUnitId)!))
            
            if(distanceFloat <= Float(preference!.freeRadius)) {
                distanceChargedLabel.text = String(format: "%@ %@", "0", String((preference?.unitOfDistance!.distanceUnitId)!))
                
                totalAmountLabel.text = String(format: "%@ %@", preference!.currency!.currencyId, "0.0")
            } else {
                let chargedDistance = distanceFloat - Float(preference!.freeRadius)
                print(preference!.freeRadius)
                distanceChargedLabel.text = String(format: "%.2f %@", chargedDistance, String((preference?.unitOfDistance!.distanceUnitId)!))
                
                let total = chargedDistance * Float(preference!.extraDistanceFee)
                totalAmountLabel.text = String(format: "%@ %.2f", preference!.currency!.currencyId, total)
            }
        }
        
        
        gmsCoordinateBounds = GMSCoordinateBounds(coordinate: sourceCoordinate, coordinate: destinationCoordinate)
        
        let url = NSURL(string: String(format: "https://maps.googleapis.com/maps/api/directions/json?origin=%@,%@&destination=%@,%@&key=%@", String(sourceCoordinate.latitude), String(sourceCoordinate.longitude), String(destinationCoordinate.latitude), String(destinationCoordinate.longitude), "AIzaSyDb3-ku0AOTC_jIWb6AhLBiSLs-d_QNPeE"))
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                if data != nil {
                    let dic = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  [String:AnyObject]
                    //                        print(dic)
                    
                    let status = dic["status"] as! String
                    var routesArray:String!
                    if status == "OK" {
                        routesArray = ((((dic["routes"]!as! [Any])[0] as! [String:Any])["overview_polyline"] as! [String:Any])["points"] as! String)
                        //                            print("routesArray: \(String(describing: routesArray))")
                    }
                    
                    DispatchQueue.main.async {
                        if(routesArray != nil) {
                            let path = GMSPath.init(fromEncodedPath: routesArray!)
                            let singleLine = GMSPolyline.init(path: path)
                            singleLine.strokeWidth = 4.0
                            singleLine.strokeColor = .blue
                            singleLine.map = self.mapView
                            
                            self.focusMapToShowAllMarkers()
                        }
                    }
                }
            } catch {
                print("Error")
            }
        }
        
        task.resume()
    }
    
    func focusMapToShowAllMarkers() {
        let firstLocation = (markers.first! as GMSMarker).position
        var bounds = GMSCoordinateBounds(coordinate: firstLocation, coordinate: firstLocation)

          for marker in markers {
              bounds = bounds.includingCoordinate(marker.position)
          }
        let update = GMSCameraUpdate.fit(bounds)
        
        self.mapView.animate(toZoom: 20)
        self.mapView.moveCamera(update)
    }
}
