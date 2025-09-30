//
//  CoffeeHunterDataManager.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import Foundation
import CoreLocation

class CoffeeHunterDataManager: CoffeeHunterDataManaging {
    private(set) var favorites: [CoffeeShop] = []
    private(set) var visitHistory: [CoffeeShopVisit] = []
    private(set) var isPremium: Bool = false
    
    private let kFavoriteCoffeeShops = "favoriteCoffeeShops"
    private let kVisitedCoffeeShops = "visitedCoffeeShops"
    private let kIsPremium = "isPremium"
    
    init() {
        loadData()
    }
    
    // MARK: - Persistence
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: kFavoriteCoffeeShops),
           let favorites = try? JSONDecoder().decode([CoffeeShop].self, from: data) {
            self.favorites = favorites
        }
        
        if let data = UserDefaults.standard.data(forKey: kVisitedCoffeeShops),
           let visits = try? JSONDecoder().decode([CoffeeShopVisit].self, from: data) {
            self.visitHistory = visits
        }
        
        self.isPremium = UserDefaults.standard.bool(forKey: kIsPremium)
    }
    
    private func saveData() {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: kFavoriteCoffeeShops)
        }
        
        if let data = try? JSONEncoder().encode(visitHistory) {
            UserDefaults.standard.set(data, forKey: kVisitedCoffeeShops)
        }
        
        UserDefaults.standard.set(isPremium, forKey: kIsPremium)
    }
    
    // MARK: - Favorites
    func addFavorite(_ shop: CoffeeShop) {
        guard !favorites.contains(where: { $0.id == shop.id }) else { return }
        favorites.append(shop)
        saveData()
    }
    
    func removeFavorite(_ shop: CoffeeShop) {
        favorites.removeAll(where: { $0.id == shop.id })
        saveData()
    }
    
    // MARK: - Visits
    func addVisit(_ shop: CoffeeShop) {
        let visit = CoffeeShopVisit(shopName: shop.name, date: Date())
        visitHistory.append(visit)
        saveData()
    }
    
    func clearVisitHistory() {
        visitHistory.removeAll()
        UserDefaults.standard.removeObject(forKey: kVisitedCoffeeShops)
    }
    
    // MARK: - Premium
    func setPremiumStatus(_ premium: Bool) {
        isPremium = premium
        UserDefaults.standard.set(premium, forKey: kIsPremium)
    }
    
    // MARK: - Helpers
    func getRandomCoffeeShop(from shops: [CoffeeShop], userLocation: CLLocation) -> CoffeeShop? {
        let nearbyShops = shops.filter { shop in
            let shopLocation = CLLocation(latitude: shop.latitude, longitude: shop.longitude)
            let distance = userLocation.distance(from: shopLocation) / 1000
            return distance <= 50
        }
        return nearbyShops.randomElement()
    }
    
    func generateCoffeeRoute(from shops: [CoffeeShop]) -> [CoffeeShop] {
        var availableShops = shops
        var route: [CoffeeShop] = []
        let maxStops = 3
        
        while route.count < maxStops && !availableShops.isEmpty {
            if let randomIndex = availableShops.indices.randomElement() {
                route.append(availableShops[randomIndex])
                availableShops.remove(at: randomIndex)
            }
        }
        return route
    }
}
