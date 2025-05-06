//
//  CoffeeShopService.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI
import MapKit
import CoreLocation

class CoffeeShopService: ObservableObject {
    @Published var coffeeShops: [MKMapItem] = []
    
    func fetchNearbyCoffeeShops(near location: CLLocationCoordinate2D) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "coffee shop"
        request.region = MKCoordinateRegion(
            center: location,
            latitudinalMeters: 150000,
            longitudinalMeters: 150000
        )
        
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.cafe])
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let response = response else { return }
            
            let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            
            DispatchQueue.main.async {
                self?.coffeeShops = response.mapItems.filter { item in
                    guard let shopLocation = item.placemark.location else { return false }
                    let distance = shopLocation.distance(from: userLocation) / 1000.0
                    CoffeeShopData.shared.updateMetadata(for: item, distance: distance)
                    return distance <= 150
                }
            }
        }
    }
}
