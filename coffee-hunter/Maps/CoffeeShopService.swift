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
    @Published var coffeeShops: [CoffeeShop] = []
    
    func fetchNearbyCoffeeShops(near location: CLLocationCoordinate2D) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "coffee shop"
        request.region = MKCoordinateRegion(
            center: location,
            latitudinalMeters: 150000,
            longitudinalMeters: 150000
        )
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let response = response else { return }
            
            let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            
            let shops = response.mapItems.map { item in
                let shopLocation = item.placemark.location
                let distance = (shopLocation?.distance(from: userLocation) ?? 0) / 1000.0
                
                return CoffeeShop(
                    name: item.name ?? "Unknown",
                    rating: Double.random(in: 3.5...5.0),
                    distance: distance,
                    address: self?.formatAddress(item.placemark) ?? "",
                    coordinates: item.placemark.coordinate,
                    mapItem: item
                )
            }
            
            DispatchQueue.main.async {
                self?.coffeeShops = shops.filter { $0.distance <= 150 }
            }
        }
    }
    
    private func formatAddress(_ placemark: MKPlacemark) -> String {
        let street = placemark.thoroughfare ?? ""
        let number = placemark.subThoroughfare ?? ""
        return "\(number) \(street)".trimmingCharacters(in: .whitespaces)
    }
}
