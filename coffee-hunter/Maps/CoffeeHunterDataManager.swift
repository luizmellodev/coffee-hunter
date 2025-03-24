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
    
    let kFavoriteCoffeeShops = "favoriteCoffeeShops"
    let kVisitedCoffeeShops = "visitedCoffeeShops"

    
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
    }
    
    func addVisit(_ shop: CoffeeShop) {
        let visit = CoffeeShopVisit(shopName: shop.name, date: Date())
        visitHistory.append(visit)
        saveData()
    }
    
    func addFavorite(_ shop: CoffeeShop) {
        // Use shop.id for checking duplicates
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
    
    private func saveData() {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: kFavoriteCoffeeShops)
        }
        
        if let data = try? JSONEncoder().encode(visitHistory) {
            UserDefaults.standard.set(data, forKey: kVisitedCoffeeShops)
        }
    }
}
