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
    }
    
    func updateLocation(_ location: CLLocationCoordinate2D) {
        selectedLocation = location
        coffeeShopService.fetchNearbyCoffeeShops(near: location)
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
}
