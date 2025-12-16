//
//  LocationManager.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI
import MapKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    private var isUpdatingContinuously: Bool = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 50 // meters
        requestAuthorizationIfNeeded()
    }
    
    func startContinuousUpdates() {
        isUpdatingContinuously = true
        manager.startUpdatingLocation()
    }
    
    func stopContinuousUpdates() {
        isUpdatingContinuously = false
        manager.stopUpdatingLocation()
    }
    
    func requestSingleLocationUpdate() {
        isUpdatingContinuously = false
        manager.requestLocation()
    }
    
    private func requestAuthorizationIfNeeded() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("Location access denied or restricted.")
        case .authorizedWhenInUse, .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        print("Authorization changed to: \(String(describing: authorizationStatus))")
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if isUpdatingContinuously {
                manager.startUpdatingLocation()
            }
        case .restricted, .denied:
            userLocation = nil
        case .notDetermined:
            requestAuthorizationIfNeeded()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
        
        if !isUpdatingContinuously {
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
