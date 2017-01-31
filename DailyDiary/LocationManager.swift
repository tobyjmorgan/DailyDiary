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
   
    let alertPresentingViewController: UIViewController
    var onLocationFix: ((Double, Double) -> Void)?
    
    init(alertPresentingViewController: UIViewController) {
        self.alertPresentingViewController = alertPresentingViewController
        super.init()
        
        manager.delegate = self
    }
    
    func getLocation(completion: @escaping (Double, Double) -> Void) {
        
        onLocationFix = completion
        
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
    
    func getPlacement(latitude: Double, longitude: Double, completion: @escaping (String) -> Void) {
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            
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

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alertController = UIAlertController(
            title: "Location Error",
            message: "Unable to determine location: \(error).",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertPresentingViewController.present(alertController, animated: true, completion: nil)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else { return }
        
        if let onLocationFix = onLocationFix {
            
            onLocationFix(location.coordinate.latitude, location.coordinate.longitude)
        }
        
        manager.stopUpdatingLocation()
    }
}
