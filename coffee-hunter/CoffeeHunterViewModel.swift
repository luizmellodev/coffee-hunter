import SwiftUI
import MapKit
import CoreLocation
import Combine

class CoffeeHunterViewModel: ObservableObject {
    @Published var selection: MKMapItem?
    @Published var selectedTab: Int = 0

    @Published var dataManager = CoffeeHunterDataManager()
    let locationManager = LocationManager()
    let coffeeShopService = CoffeeShopService()
    
    private var cancellables = Set<AnyCancellable>()
    
    func startLocationUpdates() {
        locationManager.$userLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                print("Debug: Got initial user location, fetching coffee shops")
                self?.updateLocation(location)
            }
            .store(in: &cancellables)
        
        locationManager.startContinuousUpdates()
    }
    
    func refreshLocation() {
        locationManager.requestSingleLocationUpdate()
    }
    
    func updateLocation(_ location: CLLocationCoordinate2D) {
        print("Debug: Updating location and fetching coffee shops")
        coffeeShopService.fetchNearbyCoffeeShops(near: location)
    }
    
    func navigateToMapWithShop(_ shop: MKMapItem) {
        print("Debug: Navigating to map with shop: \(shop.name ?? "")")
        selectedTab = 1
        
        updateLocation(shop.placemark.coordinate)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.selection = shop
        }
    }
    
    func toggleFavorite(_ shop: MKMapItem) {
        let isCurrentlyLiked = CoffeeShopData.shared.metadata(for: shop).isLiked
        CoffeeShopData.shared.updateMetadata(for: shop, isLiked: !isCurrentlyLiked)
        
        if isCurrentlyLiked {
            dataManager.removeFavorite(shop)
        } else {
            dataManager.addFavorite(shop)
        }
    }
    
    func isFavorite(_ shop: MKMapItem) -> Bool {
        CoffeeShopData.shared.metadata(for: shop).isLiked
    }
    
    func clearVisitHistory() {
        dataManager.clearVisitHistory()
    }
    
    func upgradeToPremium() {
        dataManager.setPremiumStatus(true)
    }
    
    func restorePurchases(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(false)
        }
    }
}
