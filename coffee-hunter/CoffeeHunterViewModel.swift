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
        
        dataManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
            
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
        selectedTab = 1 // Switch to map tab
        
        // First update the location to center the map
        updateLocation(shop.coordinates)
        
        // Then set the selected shop after a small delay to ensure proper animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.selectedCoffeeShop = shop
        }
    }
    
    func toggleFavorite(_ shop: CoffeeShop) {
        if isFavorite(shop) {
            dataManager.removeFavorite(shop)
        } else {
            dataManager.addFavorite(shop)
        }
        
        // Update selected shop if it's the one being modified
        if selectedCoffeeShop?.id == shop.id {
            selectedCoffeeShop = shop
        }
    }
    
    func isFavorite(_ shop: CoffeeShop) -> Bool {
        dataManager.favorites.contains(where: { $0.id == shop.id })
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
