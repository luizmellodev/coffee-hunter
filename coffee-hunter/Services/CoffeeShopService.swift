//
//  CoffeeShopService.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI
import MapKit
import CoreLocation

class CoffeeShopService: ObservableObject, CoffeeShopServicing {
    @Published var coffeeShops: [CoffeeShop] = []
    
    // Rate limiting: prevent hitting Apple's 50 requests/60s limit
    private var lastSearchTime: Date?
    private var lastSearchLocation: CLLocationCoordinate2D?
    private let minimumSearchInterval: TimeInterval = 2.0 // 2 seconds between searches
    private let minimumDistanceChange: Double = 500 // 500m minimum change
    
    func fetchNearbyCoffeeShops(near location: CLLocationCoordinate2D) {
        // Rate limiting check
        let now = Date()
        
        // Check time throttle
        if let lastTime = lastSearchTime, now.timeIntervalSince(lastTime) < minimumSearchInterval {
            print("⏱️ Search throttled: too soon (wait \(Int(minimumSearchInterval - now.timeIntervalSince(lastTime)))s)")
            return
        }
        
        // Check distance throttle
        if let lastLocation = lastSearchLocation {
            let lastCLLocation = CLLocation(latitude: lastLocation.latitude, longitude: lastLocation.longitude)
            let currentCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let distance = currentCLLocation.distance(from: lastCLLocation)
            
            if distance < minimumDistanceChange {
                print("📍 Search throttled: too close (\(Int(distance))m < \(Int(minimumDistanceChange))m)")
                return
            }
        }
        
        // Update throttle tracking
        lastSearchTime = now
        lastSearchLocation = location
        // Clear previous results
        DispatchQueue.main.async {
            self.coffeeShops = []
        }
        
        let region = MKCoordinateRegion(
            center: location,
            latitudinalMeters: 20000,  // 20km radius
            longitudinalMeters: 20000
        )
        
        // Generic searches for global coverage
        searchByPOI(region: region, location: location)
        searchByText(region: region, query: "coffee", location: location)
        searchByText(region: region, query: "café", location: location)
        searchByText(region: region, query: "cafeteria", location: location)
        
        // Note: MKLocalSearch has a 25-result limit per query and prioritizes by "relevance"
        // Small/local cafes might not appear in generic searches
        // Future improvement: Allow users to manually add their favorite local spots
    }
    
    // POI search - finds well-categorized cafes worldwide
    private func searchByPOI(region: MKCoordinateRegion, location: CLLocationCoordinate2D) {
        let request = MKLocalSearch.Request()
        request.region = region
        
        // MKLocalSearch requires EITHER a query OR specific POI categories
        // Using a broad query with POI filter works better than POI-only search
        request.naturalLanguageQuery = "coffee shop"
        request.resultTypes = .pointOfInterest
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [
            .cafe, .bakery, .restaurant
        ])
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            self?.handleSearchResponse(response, error: error, source: "POI", location: location)
        }
    }
    
    // Text search - fallback for poorly categorized places
    private func searchByText(region: MKCoordinateRegion, query: String, location: CLLocationCoordinate2D) {
        let request = MKLocalSearch.Request()
        request.region = region
        request.naturalLanguageQuery = query
        // Don't set resultTypes or POI filter - let Maps decide
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            self?.handleSearchResponse(response, error: error, source: "Text(\(query))", location: location)
        }
    }
    
    private func handleSearchResponse(_ response: MKLocalSearch.Response?, error: Error?, source: String, location: CLLocationCoordinate2D) {
        if let error = error {
            print("❌ Search error [\(source)]: \(error.localizedDescription)")
            return
        }
        
        guard let response = response else {
            print("❌ No response [\(source)]")
            return
        }
        
        // Debug: print("✅ Found \(response.mapItems.count) places [\(source)]")
        
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        let shops = response.mapItems.compactMap { item -> CoffeeShop? in
            guard let itemLocation = item.placemark.location else { return nil }
            
            let distance = itemLocation.distance(from: userLocation) / 1000.0
            
            // Filter by distance (30km max for better coverage in small cities)
            guard distance <= 30 else { return nil }
            
            let name = item.name ?? "Unknown"
            let lowercasedName = name.lowercased()
            
            // Filter out non-coffee places by name
            let coffeeKeywords = ["café", "cafe", "coffee", "cafeteria", "espresso", "cappuccino", "cafézinho"]
            let hasCoffeeKeyword = coffeeKeywords.contains { lowercasedName.contains($0) }
            
            // Also check category if available
            let category = item.pointOfInterestCategory?.rawValue.lowercased() ?? ""
            let isCafeCategory = category.contains("cafe") || category.contains("bakery")
            
            // Exclude obvious non-coffee places
            let excludeKeywords = [
                "xis", "burger", "pizza", "churrasco", "lanche", "mercado", "supermercado",
                "cachorrão", "hot dog", "frango", "chicken", "açaí", "acai", "sorvete",
                "ice cream", "sushi", "japonês", "chinese", "chines", "Krep", "Kreps"
            ]
            let hasExcludeKeyword = excludeKeywords.contains { lowercasedName.contains($0) }
            
            // Exclude non-coffee places
            if hasExcludeKeyword {
                return nil
            }
            
            // Accept if name has coffee keyword OR is cafe category
            guard hasCoffeeKeyword || isCafeCategory else {
                return nil
            }
            
            return CoffeeShop(
                name: name,
                rating: Double.random(in: 3.5...5.0),
                distance: distance,
                address: self.formatAddress(item.placemark),
                coordinates: item.placemark.coordinate,
                mapItem: item
            )
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.mergeResults(shops)
        }
    }
    
    private func mergeResults(_ newShops: [CoffeeShop]) {
        for shop in newShops {
            let isDuplicate = coffeeShops.contains { existing in
                existing.name.lowercased() == shop.name.lowercased() &&
                abs(existing.latitude - shop.latitude) < 0.001 &&
                abs(existing.longitude - shop.longitude) < 0.001
            }
            if !isDuplicate {
                coffeeShops.append(shop)
            }
        }
        
        // Sort by distance (closest first)
        coffeeShops.sort { $0.distance < $1.distance }
        
        // Debug logging (optional)
        // print("📊 Total unique shops: \(coffeeShops.count)")
        // if coffeeShops.count > 0 {
        //     print("🏆 Closest: \(coffeeShops[0].name) - \(String(format: "%.1f", coffeeShops[0].distance))km")
        // }
    }
    
    func formatAddress(_ placemark: MKPlacemark) -> String {
        let street = placemark.thoroughfare ?? ""
        let number = placemark.subThoroughfare ?? ""
        return "\(number) \(street)".trimmingCharacters(in: .whitespaces)
    }
}
