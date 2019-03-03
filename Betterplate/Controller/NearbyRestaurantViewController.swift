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

class NearbyRestaurantViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var restaurantName: String?
    var currentLocation: CLLocation?
    // These are to bypass the bugs in MKLocalSearch
    var hasAnnotations = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegate to this view controller
        locationManager.delegate = self
        mapView.delegate = self
        
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
    
    // MARK: Location & map delegate methods
    
    // Function is called everytime location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last
        // Keep trying to search if annotations are not present
        if !hasAnnotations {
            updateNearby()
        }
    }

    // Function is called when the authorization for location is changed
    // This is initially called when user selects an authorization
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
    
    // Function is called to get the popup annotation view for each map marker
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKUserLocation) {
            // User location, return nil to use default user location display
            return nil
        }
        
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "marker")
        let detailsButton = UIButton(type: .detailDisclosure)
        annotationView.isEnabled = true
        annotationView.canShowCallout = true
        // This offsets the annotation so it appears above the marker
        annotationView.calloutOffset = CGPoint(x: -5, y: 5)
        // Set colors
        let accentColor = UIColor(named: "accent")!
        annotationView.markerTintColor = accentColor
        detailsButton.tintColor = accentColor
        annotationView.rightCalloutAccessoryView = detailsButton
        
        return annotationView
    }
    
    // Function is called when the accessory button for the annotation is clicked
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let confirmationAlert = UIAlertController(title: "Launch in Maps", message: "This will open Apple Maps", preferredStyle: .alert)
        // Launch apple maps option
        confirmationAlert.addAction(UIAlertAction(title: "Open", style: .default, handler: { (action) in
            // Create MKItems from the annotation
            let place = MKPlacemark(coordinate: view.annotation!.coordinate)
            let mapItem = MKMapItem(placemark: place)
            // Get the annotation's title as the name or just display restaurant name
            mapItem.name = view.annotation?.title ?? self.restaurantName
            mapItem.openInMaps(launchOptions: [:])
        }))
        // Cancel action - do nothing
        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        // Present the alert
        present(confirmationAlert, animated: true, completion: nil)
    }
    
    
    // MARK: Private methods for dealing with location
    
    // Searches nearby based on current map rect and adds map annotations for the restaurant
    private func updateNearby() {
        
        // Clear current annotations
        mapView.removeAnnotations(mapView.annotations)
        
        // Search if restaurant name exists (it should always)
        if var restaurant = restaurantName {
            // Hack to remove country codes from name
            if restaurant.contains("(US)") || restaurant.contains("(CA)") {
                restaurant.removeLast(5)
            }
            
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
                        self.hasAnnotations = true
                        for item in itemsInRegion {
                            let location = item.placemark
                            // Create annotation from the point info
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = location.coordinate
                            // Create title with restaurant name & neighbourhood if the info exists
                            annotation.title = restaurant + (location.subLocality != nil ? " - " + location.subLocality! : "")
                            annotation.subtitle = location.title
                            self.mapView.addAnnotation(annotation)
                        }
                    }
                    // Unfortunately we can't let the user know that no results are found
                    // Because search seems to always come up empty the first time
                } else {
                    ViewHelperService.showErrorHUD(withMessage: "Something went wrong.")
                    print("Error searching: \(error!)")
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
