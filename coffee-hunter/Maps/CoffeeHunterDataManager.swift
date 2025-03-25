//
//  CoffeeHunterDataManager.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI
import MapKit
import CoreLocation

class CoffeeHunterDataManager: ObservableObject {
    @Published var favorites: [CoffeeShop] = []
    @Published var visitHistory: [CoffeeShopVisit] = []
    @Published var isPremium: Bool = false
    
    let kFavoriteCoffeeShops = "favoriteCoffeeShops"
    let kVisitedCoffeeShops = "visitedCoffeeShops"
    let kIsPremium = "isPremium"
    
    init() {
        loadData()
    }
    
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
    
    func addVisit(_ shop: CoffeeShop) {
        let visit = CoffeeShopVisit(shopName: shop.name, date: Date())
        visitHistory.append(visit)
        saveData()
    }
    
    func addFavorite(_ shop: CoffeeShop) {
        if !favorites.contains(where: { $0.id == shop.id }) {
            DispatchQueue.main.async {
                self.favorites.append(shop)
                self.saveData()
                self.objectWillChange.send()
            }
        }
    }
    
    func removeFavorite(_ shop: CoffeeShop) {
        if let index = favorites.firstIndex(where: { $0.id == shop.id }) {
            DispatchQueue.main.async {
                self.favorites.remove(at: index)
                self.saveData()
                self.objectWillChange.send()
            }
        }
    }
    
    func clearVisitHistory() {
        DispatchQueue.main.async {
            self.visitHistory.removeAll()
            UserDefaults.standard.removeObject(forKey: self.kVisitedCoffeeShops)
            self.objectWillChange.send()
        }
    }
    
    func getRandomCoffeeShop(from shops: [CoffeeShop], userLocation: CLLocation) -> CoffeeShop? {
        let nearbyShops = shops.filter { shop in
            let shopLocation = CLLocation(latitude: shop.latitude, longitude: shop.longitude)
            let distance = userLocation.distance(from: shopLocation) / 1000
            return distance <= 10
        }
        
        return nearbyShops.randomElement()
    }
    
    func setPremiumStatus(_ isPremium: Bool) {
        self.isPremium = isPremium
        UserDefaults.standard.set(isPremium, forKey: kIsPremium)
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
