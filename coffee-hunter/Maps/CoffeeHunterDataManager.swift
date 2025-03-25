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
    @Published var missions: [Mission] = []
    
    let kFavoriteCoffeeShops = "favoriteCoffeeShops"
    let kVisitedCoffeeShops = "visitedCoffeeShops"
    let kMissions = "missions"
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
        
        if let data = UserDefaults.standard.data(forKey: kMissions),
           let missions = try? JSONDecoder().decode([Mission].self, from: data) {
            self.missions = missions
        }
        
        self.isPremium = UserDefaults.standard.bool(forKey: kIsPremium)
    }
    
    func addVisit(_ shop: CoffeeShop) {
        let visit = CoffeeShopVisit(shopName: shop.name, date: Date())
        visitHistory.append(visit)
        saveData()
        checkMissionCompletion(visit: visit)
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
    
    func generateCoffeeRoute(from shops: [CoffeeShop], maxStops: Int = 5) -> [CoffeeShop]? {
        guard isPremium else { return nil }
        
        var route: [CoffeeShop] = []
        var availableShops = shops
        
        while route.count < maxStops && !availableShops.isEmpty {
            if let randomShop = availableShops.randomElement(),
               let index = availableShops.firstIndex(where: { $0.id == randomShop.id }) {
                route.append(randomShop)
                availableShops.remove(at: index)
            }
        }
        
        return route.isEmpty ? nil : route
    }
    
    func checkMissionCompletion(visit: CoffeeShopVisit) {
        let today = Calendar.current.startOfDay(for: Date())
        
        let todayVisits = visitHistory.filter { visit in
            Calendar.current.isDate(visit.date, inSameDayAs: today)
        }
        
        if todayVisits.count >= 2 {
            addMission(Mission(title: "Coffee Explorer", description: "Visited 2 coffee shops in one day", points: 100))
        }
    }
    
    func addMission(_ mission: Mission) {
        if !missions.contains(where: { $0.id == mission.id }) {
            missions.append(mission)
            saveData()
        }
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
        
        if let data = try? JSONEncoder().encode(missions) {
            UserDefaults.standard.set(data, forKey: kMissions)
        }
        
        UserDefaults.standard.set(isPremium, forKey: kIsPremium)
    }
}
