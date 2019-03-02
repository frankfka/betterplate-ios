//
//  NearbyRestaurantViewController.swift
//  Betterplate
//
//  Created by Frank Jia on 2019-03-02.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

let DEFAULT_LAT_SPAN = 0.1
let DEFAULT_LONG_SPAN = 0.1

class NearbyRestaurantViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var restaurantName: String?
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegate to this view controller
        locationManager.delegate = self
        
        // Determine authorization status
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request authorization
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted, .denied:
            // No permissions given, show error and go back
            showErrorAndGoBack()
            break
        case .authorizedWhenInUse, .authorizedAlways:
            // Start initializing locaton services
            setupLocation()
            break
        }
    }
    
    // Re-zoom to the standard boundary
    @IBAction func resetZoomButtonPressed(_ sender: UIBarButtonItem) {
        updateViewToCurrentLocation()
    }
    
    // MARK: Location delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            showErrorAndGoBack()
            break
        case .authorizedWhenInUse, .authorizedAlways:
            // Start enabling location features
            setupLocation()
            break
        case .notDetermined:
            // User hasn't responded yet
            break
        }
    }
    
    
    // MARK: Private methods for dealing with location
    
    // Searches nearby and adds map annotations for the restaurant
    private func updateNearby() {
        print(restaurantName)
    }

    // This re-zooms the map to the user's current location
    private func updateViewToCurrentLocation() {
        if let location = currentLocation {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: DEFAULT_LAT_SPAN, longitudeDelta: DEFAULT_LONG_SPAN)
            let region = MKCoordinateRegion(center: center, span: span)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    // This initializes location services for the first time
    private func setupLocation() {
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        updateNearby()
    }
    
    
    
    // MARK: Private helper methods
    
    // Show no-location error and go back
    private func showErrorAndGoBack() {
        navigationController?.popViewController(animated: true)
        ViewHelperService.showErrorHUD(withMessage: "Please enable location services")
    }
    
}
