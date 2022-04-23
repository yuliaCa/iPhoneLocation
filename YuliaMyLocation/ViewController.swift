//
//  ViewController.swift
//  YuliaMyLocation
//
//  Created by Yulia Kirienko on 2022-04-13.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
//    initialize the location manager variable
  var coreLocationManager = CLLocationManager()
//    initialize currentLocation variable from the CLLocationCoordinates
  private var currentLocation: CLLocationCoordinate2D?
    
// Outlets from Main storyboard
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//       delegate the coreLocationManager to self
        coreLocationManager.delegate = self
//here we are checking if the user has already given us authorization to use their location. If not - we will request for it (you should see a prompt when you first load the application). If yes - we will get to getting their coordinates and updating the map.
//        CLLocationManager.authorizationStatus() while still available and working, is deprecated as of iOS 14.0. In the future, will need to find more current alternative. 
        if CLLocationManager.authorizationStatus() == .notDetermined{
            coreLocationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            beginLocUpdates(coreLocationManager: coreLocationManager)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
//        initializing more variables to determine and use for the current user's location
        let location = locations[0]
        guard let latestLocation = locations.first else {return}
        
//        we will do a check if the currentLocaiton is nil, then we will use the latest determined location and we will assign it to the current location.
        if currentLocation == nil {
            zoomToCurrentLoc(with: latestLocation.coordinate)
        }
        
        currentLocation = latestLocation.coordinate
        
//       When determining the locaiton, we only get the latitude and longtitude from the Map package. But to make it human readable, we need to reverse the geocode. CLGeocoder helps us do that.
        CLGeocoder().reverseGeocodeLocation(location) { placemark, error in
            if error != nil{
                print("There is an error")
            } else {
                if let place = placemark?[0]{
                    self.addressLabel.text = " \(place.name!) \n \(place.locality!), \(place.administrativeArea!),  \(place.country!)\n \(place.postalCode!)"
                    
                }
            }
        }
    }

//This function helps us check the authorization status to see if we can start showing the details about the location.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            beginLocUpdates(coreLocationManager: coreLocationManager)
        }
    }
    
//  the below function then finds the exact region the locaiton is determined in and sets the map to this location. With the user's location being in the center of the screen.
    private func zoomToCurrentLoc(with coordinate: CLLocationCoordinate2D)
    {
        let region = MKCoordinateRegion(center: coordinate,latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
    }
    
//Finally we get the detailed map with the location and the annotations on the map.
    private func beginLocUpdates(coreLocationManager:CLLocationManager){
        mapView.showsUserLocation = true
        mapView.addAnnotation(MKPointAnnotation())
        mapView.showAnnotations([MKPointAnnotation()], animated: true)
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        coreLocationManager.startUpdatingLocation()
    }
}


