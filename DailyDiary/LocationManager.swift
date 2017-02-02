//
//  LocationManager.swift
//  DailyDiary
//
//  Created by redBred LLC on 1/29/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class LocationManager: NSObject {

    let manager = CLLocationManager()
    let geocoder = CLGeocoder()
   
    // dependency injection for presenting alerts
    let alertPresentingViewController: UIViewController
    
    init(alertPresentingViewController: UIViewController) {
        self.alertPresentingViewController = alertPresentingViewController
        super.init()
        
        manager.delegate = self
    }

    // a closure for what to do when successfully geolocated
    internal var onLocationFix: ((Double, Double) -> Void)?

    // used when requesting current location
    func getLocation(completion: @escaping (Double, Double) -> Void) {

        // capture the completion handler for use later
        onLocationFix = completion
        
        // what permissions do we have for using CLLocationManager?
        switch CLLocationManager.authorizationStatus() {
        
        case .authorizedAlways:
            // not requested by this app so should never happen
            break
            
        case .notDetermined:
            // ask for permission
            manager.requestWhenInUseAuthorization()
        
        case .authorizedWhenInUse:
            // yay - lets go!
            manager.startUpdatingLocation()
            
        case .restricted, .denied:
            // present an alert showing how to change the settings if the user wants to
            let alertController = UIAlertController(
                title: "Location Access Disabled",
                message: "If you want to add your location to your diary entries, please open this app's settings and set location access to 'When In Use'.",
                preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
                if let url = URL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
            alertController.addAction(openAction)
            
            alertPresentingViewController.present(alertController, animated: true, completion: nil)
        }        
    }
    
    // used when requesting a location be converted in to placement
    func getPlacement(latitude: Double, longitude: Double, completion: @escaping (String) -> Void) {
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in

            // make sure this happens on the main queue
            // just in case there is any GUI code inside the completion handler
            DispatchQueue.main.async {

                guard let placemark = placemarks?.first,
                    let _ = placemark.name,
                    let city = placemark.locality,
                    let area = placemark.administrativeArea else {
                        
                        completion("Unable to get location")
                        return
                }
                
                completion("\(city), \(area)")
            }

        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        // present alert with details of why geolocation failed
        let alertController = UIAlertController(
            title: "Location Error",
            message: "Unable to determine location: \(error).",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertPresentingViewController.present(alertController, animated: true, completion: nil)
    }

    // found our location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else { return }
        
        if let onLocationFix = onLocationFix {
            
            // make sure this happens on the main queue
            // just in case there is any GUI code inside the onLocationFix completion handler
            DispatchQueue.main.async {
                // call the closure for successful location
                onLocationFix(location.coordinate.latitude, location.coordinate.longitude)
            }
        }
        
        manager.stopUpdatingLocation()
    }
}
