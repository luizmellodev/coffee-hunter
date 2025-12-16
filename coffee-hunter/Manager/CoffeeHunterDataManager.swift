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
    private(set) var userStreak: UserStreak = .empty
    private(set) var dailyRecommendation: DailyRecommendation?
    private(set) var purchasedTourIds: Set<String> = []
    private(set) var purchasedGuideIds: Set<String> = []
    private(set) var unlockedAchievements: [String: Date] = [:]
    
    private let kFavoriteCoffeeShops = "favoriteCoffeeShops"
    private let kVisitedCoffeeShops = "visitedCoffeeShops"
    private let kIsPremium = "isPremium"
    private let kUserStreak = "userStreak"
    private let kDailyRecommendation = "dailyRecommendation"
    private let kPurchasedTours = "purchasedTours"
    private let kPurchasedGuides = "purchasedGuides"
    private let kUnlockedAchievements = "unlockedAchievements"
    
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
        
        if let data = UserDefaults.standard.data(forKey: kUserStreak),
           let streak = try? JSONDecoder().decode(UserStreak.self, from: data) {
            self.userStreak = streak
        }
        
        if let data = UserDefaults.standard.data(forKey: kDailyRecommendation),
           let recommendation = try? JSONDecoder().decode(DailyRecommendation.self, from: data) {
            self.dailyRecommendation = recommendation
        }
        
        if let data = UserDefaults.standard.data(forKey: kPurchasedTours),
           let tours = try? JSONDecoder().decode(Set<String>.self, from: data) {
            self.purchasedTourIds = tours
        }
        
        if let data = UserDefaults.standard.data(forKey: kPurchasedGuides),
           let guides = try? JSONDecoder().decode(Set<String>.self, from: data) {
            self.purchasedGuideIds = guides
        }
        
        if let data = UserDefaults.standard.data(forKey: kUnlockedAchievements),
           let achievements = try? JSONDecoder().decode([String: Date].self, from: data) {
            self.unlockedAchievements = achievements
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
        
        if let data = try? JSONEncoder().encode(userStreak) {
            UserDefaults.standard.set(data, forKey: kUserStreak)
        }
        
        if let data = try? JSONEncoder().encode(dailyRecommendation) {
            UserDefaults.standard.set(data, forKey: kDailyRecommendation)
        }
        
        if let data = try? JSONEncoder().encode(purchasedTourIds) {
            UserDefaults.standard.set(data, forKey: kPurchasedTours)
        }
        
        if let data = try? JSONEncoder().encode(purchasedGuideIds) {
            UserDefaults.standard.set(data, forKey: kPurchasedGuides)
        }
        
        if let data = try? JSONEncoder().encode(unlockedAchievements) {
            UserDefaults.standard.set(data, forKey: kUnlockedAchievements)
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
    
    // MARK: - Daily Recommendation
    func getDailyRecommendation(from shops: [CoffeeShop]) -> CoffeeShop? {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Check if we already have a recommendation for today
        if let recommendation = dailyRecommendation,
           Calendar.current.isDate(recommendation.date, inSameDayAs: today) {
            return shops.first { $0.id == recommendation.shopId }
        }
        
        // Generate a new daily recommendation using date as seed for consistency
        guard !shops.isEmpty else { return nil }
        
        let dateString = DateFormatter.yyyyMMdd.string(from: today)
        let seed = dateString.hash
        var generator = SeededRandomNumberGenerator(seed: seed)
        let index = Int.random(in: 0..<shops.count, using: &generator)
        let selectedShop = shops[index]
        
        // Save the recommendation
        dailyRecommendation = DailyRecommendation(shopId: selectedShop.id, date: today)
        saveData()
        
        return selectedShop
    }
    
    // MARK: - Streak Management
    func updateStreak(visitDate: Date = Date()) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: visitDate)
        
        if let lastVisit = userStreak.lastVisitDate {
            let lastVisitDay = calendar.startOfDay(for: lastVisit)
            let daysDifference = calendar.dateComponents([.day], from: lastVisitDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                // Consecutive day - increase streak
                userStreak.currentStreak += 1
                if userStreak.currentStreak > userStreak.longestStreak {
                    userStreak.longestStreak = userStreak.currentStreak
                }
            } else if daysDifference > 1 {
                // Streak broken - reset to 1
                userStreak.currentStreak = 1
            }
            // If daysDifference == 0, same day visit, don't change streak
        } else {
            // First visit ever
            userStreak.currentStreak = 1
            userStreak.longestStreak = 1
        }
        
        userStreak.lastVisitDate = visitDate
        saveData()
    }
    
    // MARK: - Purchases
    func purchaseTour(_ tourId: String) {
        purchasedTourIds.insert(tourId)
        saveData()
    }
    
    func hasPurchasedTour(_ tourId: String) -> Bool {
        return isPremium || purchasedTourIds.contains(tourId)
    }
    
    func purchaseGuide(_ guideId: String) {
        purchasedGuideIds.insert(guideId)
        saveData()
    }
    
    func hasPurchasedGuide(_ guideId: String) -> Bool {
        return purchasedGuideIds.contains(guideId)
    }
    
    // MARK: - Achievements
    func unlockAchievement(_ achievementId: String) {
        if unlockedAchievements[achievementId] == nil {
            unlockedAchievements[achievementId] = Date()
            saveData()
        }
    }
    
    func isAchievementUnlocked(_ achievementId: String) -> Bool {
        return unlockedAchievements[achievementId] != nil
    }
    
    func getUnlockedDate(for achievementId: String) -> Date? {
        return unlockedAchievements[achievementId]
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

// MARK: - Helpers
private struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: Int) {
        state = UInt64(truncatingIfNeeded: seed)
    }
    
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

private extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}
