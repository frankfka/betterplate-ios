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
        // Search if restaurant name exists (it should always)
        if let restaurant = restaurantName {
            // Create search request
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = restaurant
            // This does NOT limit the request to this specific region
            let mapRegionCoord = mapView.region
            searchRequest.region = mapRegionCoord
            
            // Dispatch request
            let search = MKLocalSearch(request: searchRequest)
            search.start { (response, error) in
                // No error, process data
                if error == nil {
                    // Filter the list to locations that are within the map region
                    let mapRegion = self.MKMapRectForCoordinateRegion(region: mapRegionCoord)
                    var itemsInRegion: [MKMapItem] = []
                    for item in response!.mapItems {
                        if mapRegion.contains(MKMapPoint(item.placemark.coordinate)) {
                            itemsInRegion.append(item)
                        }
                    }
                    
                    // Add annotations if locations found
                    if !itemsInRegion.isEmpty {
                        for item in itemsInRegion {
                            let location = item.placemark
                            print(location.title!)
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = location.coordinate
                            annotation.subtitle = location.title
                            self.mapView.addAnnotation(annotation)
                        }
                    } else {
                        print("No items found")
                    }
                } else {
                    print("Error in search")
                }
            }
        }
    }

    // This re-zooms the map to the user's current location
    private func updateViewToCurrentLocation() {
        currentLocation = self.locationManager.location
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
        // First zoom to user location
        updateViewToCurrentLocation()
        updateNearby()
    }
    
    
    
    // MARK: Private helper methods
    
    // Show no-location error and go back
    private func showErrorAndGoBack() {
        navigationController?.popViewController(animated: true)
        ViewHelperService.showErrorHUD(withMessage: "Please enable location services")
    }
    
    // Helper function for determining whether a coordinate is within a region
    func MKMapRectForCoordinateRegion(region:MKCoordinateRegion) -> MKMapRect {
        let topLeft = CLLocationCoordinate2D(latitude: region.center.latitude + (region.span.latitudeDelta/2), longitude: region.center.longitude - (region.span.longitudeDelta/2))
        let bottomRight = CLLocationCoordinate2D(latitude: region.center.latitude - (region.span.latitudeDelta/2), longitude: region.center.longitude + (region.span.longitudeDelta/2))
        
        let a = MKMapPoint(topLeft)
        let b = MKMapPoint(bottomRight)
        
        return MKMapRect(origin: MKMapPoint(x:min(a.x,b.x), y:min(a.y,b.y)), size: MKMapSize(width: abs(a.x-b.x), height: abs(a.y-b.y)))
    }
    
}
