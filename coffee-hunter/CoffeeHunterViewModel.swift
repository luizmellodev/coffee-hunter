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
            checkFavoriteAchievements()
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
        // Here you would implement the actual In-App Purchase
        // For now, we'll just set it to true
        dataManager.setPremiumStatus(true)
    }
    
    func restorePurchases(completion: @escaping (Bool) -> Void) {
        // Here you would implement the actual restore purchase logic
        // For now, we'll just simulate a delay and return false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(false)
        }
    }
    
    // ADD: Achievement checks
    private func checkFavoriteAchievements() {
        let favoriteCount = dataManager.favorites.count
        
        if favoriteCount == 5 {
            addAchievement(
                Mission(
                    title: "Colecionador de Cafés",
                    description: "Favoritou 5 cafeterias",
                    points: 50
                )
            )
        } else if favoriteCount == 10 {
            addAchievement(
                Mission(
                    title: "Café Expert",
                    description: "Favoritou 10 cafeterias",
                    points: 100
                )
            )
        }
    }
    
    private func addAchievement(_ mission: Mission) {
        dataManager.addMission(mission)
        lastAchievement = mission
        showAchievementAlert = true
        
        // Auto-dismiss achievement alert after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showAchievementAlert = false
        }
    }
    
    // ADD: Visit tracking with achievements
    func recordVisit(to shop: CoffeeShop) {
        dataManager.addVisit(shop)
        dataManager.checkMissionCompletion(visit: CoffeeShopVisit(shopName: shop.name, date: Date()))
    }
    
    // ADD: Coffee route generation
    func generateCoffeeRoute() -> [CoffeeShop]? {
        guard dataManager.isPremium else { return nil }
        return dataManager.generateCoffeeRoute(from: coffeeShopService.coffeeShops)
    }
}
