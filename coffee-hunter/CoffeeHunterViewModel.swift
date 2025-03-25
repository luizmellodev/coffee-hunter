//
//  CoffeeHunterViewModel.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

class CoffeeHunterViewModel: ObservableObject {
    @Published var selectedLocation: CLLocationCoordinate2D?
    @Published var selectedCoffeeShop: CoffeeShop?
    @Published var showAchievementAlert = false
    @Published var lastAchievement: Mission?
    @Published var selectedTab: Int = 0
    
    let locationManager = LocationManager()
    let coffeeShopService = CoffeeShopService()
    @Published var dataManager: CoffeeHunterDataManager
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.dataManager = CoffeeHunterDataManager()
        
        // Subscribe to dataManager changes
        dataManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
            
        // Initialize coffee shops when location is available
        locationManager.$userLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                print("Debug: Got initial user location, fetching coffee shops")
                self?.updateLocation(location)
            }
            .store(in: &cancellables)
    }
    
    func updateLocation(_ location: CLLocationCoordinate2D) {
        print("Debug: Updating location and fetching coffee shops")
        selectedLocation = location
        coffeeShopService.fetchNearbyCoffeeShops(near: location)
    }
    
    func navigateToMapWithShop(_ shop: CoffeeShop) {
        print("Debug: Navigating to map with shop: \(shop.name)")
        selectedCoffeeShop = shop
        selectedTab = 1
        updateLocation(shop.coordinates)
    }
    
    func toggleFavorite(_ shop: CoffeeShop) {
        if isFavorite(shop) {
            dataManager.removeFavorite(shop)
        } else {
            dataManager.addFavorite(shop)
        }
    }
    
    func isFavorite(_ shop: CoffeeShop) -> Bool {
        dataManager.favorites.contains(where: { $0.id == shop.id })
    }
    
    func clearVisitHistory() {
        dataManager.clearVisitHistory()
    }
    
    // ADD: Premium features
    func upgradeToPremium() {
        dataManager.setPremiumStatus(true)
    }
    
    func restorePurchases(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(false)
        }
    }
}
