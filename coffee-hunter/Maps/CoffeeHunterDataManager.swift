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
    @Published var favorites: [MKMapItem] = []
    @Published var visitHistory: [CoffeeShopVisit] = []
    @Published var isPremium: Bool = false
    
    let kFavoriteCoffeeShops = "favoriteCoffeeShops"
    let kVisitedCoffeeShops = "visitedCoffeeShops"
    let kIsPremium = "isPremium"
    let kShopMetadata = "shopMetadata"
    
    init() {
        loadData()
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: kShopMetadata),
           let metadata = try? JSONDecoder().decode([String: CoffeeShopData.ShopMetadata].self, from: data) {
            CoffeeShopData.shared.shopData = metadata
        }
        
        if let data = UserDefaults.standard.data(forKey: kVisitedCoffeeShops),
           let visits = try? JSONDecoder().decode([CoffeeShopVisit].self, from: data) {
            self.visitHistory = visits
        }
        
        self.isPremium = UserDefaults.standard.bool(forKey: kIsPremium)
    }
    
    func addVisit(_ shop: MKMapItem) {
        let visit = CoffeeShopVisit(shopName: shop.name ?? "Unknown", date: Date())
        visitHistory.append(visit)
        saveData()
    }
    
    func addFavorite(_ shop: MKMapItem) {
        if !favorites.contains(where: { CoffeeShopData.shared.id(for: $0) == CoffeeShopData.shared.id(for: shop) }) {
            DispatchQueue.main.async {
                self.favorites.append(shop)
                self.saveData()
                self.objectWillChange.send()
            }
        }
    }
    
    func removeFavorite(_ shop: MKMapItem) {
        if let index = favorites.firstIndex(where: { CoffeeShopData.shared.id(for: $0) == CoffeeShopData.shared.id(for: shop) }) {
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
    
    private func saveData() {
        if let data = try? JSONEncoder().encode(CoffeeShopData.shared.shopData) {
            UserDefaults.standard.set(data, forKey: kShopMetadata)
        }
        
        if let data = try? JSONEncoder().encode(visitHistory) {
            UserDefaults.standard.set(data, forKey: kVisitedCoffeeShops)
        }
        
        UserDefaults.standard.set(isPremium, forKey: kIsPremium)
    }
    
    // CHANGE: update getRandomCoffeeShop to work with MKMapItems
    func getRandomCoffeeShop(from shops: [MKMapItem], userLocation: CLLocation) -> MKMapItem? {
        let nearbyShops = shops.filter { shop in
            guard let shopLocation = shop.placemark.location else { return false }
            let distance = shopLocation.distance(from: userLocation) / 1000
            return distance <= 10
        }
        
        return nearbyShops.randomElement()
    }
    
    func setPremiumStatus(_ isPremium: Bool) {
        self.isPremium = isPremium
        UserDefaults.standard.set(isPremium, forKey: kIsPremium)
    }
    
    func generateCoffeeRoute(from shops: [MKMapItem]) -> [MKMapItem] {
        var availableShops = shops
        var route: [MKMapItem] = []
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
