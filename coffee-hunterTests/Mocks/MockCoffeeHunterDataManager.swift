import Foundation
import CoreLocation
import MapKit
@testable import coffee_hunter

class MockCoffeeHunterDataManager: CoffeeHunterDataManaging {
    var favorites: [CoffeeShop] = []
    var visitHistory: [CoffeeShopVisit] = []
    var isPremium: Bool = false
    var userStreak: UserStreak = .empty
    var dailyRecommendation: DailyRecommendation?
    var purchasedTourIds: Set<String> = []
    var purchasedGuideIds: Set<String> = []
    var unlockedAchievements: [String: Date] = [:]
    var dateToUseForVisits: Date = Date()
    
    func addFavorite(_ shop: CoffeeShop) {
        favorites.append(shop)
    }
    
    func removeFavorite(_ shop: CoffeeShop) {
        favorites.removeAll { $0.id == shop.id }
    }
    
    func addVisit(_ shop: CoffeeShop) {
        visitHistory.append(CoffeeShopVisit(shopName: shop.name, date: dateToUseForVisits))
    }
    
    func clearVisitHistory() {
        visitHistory.removeAll()
    }
    
    func setPremiumStatus(_ premium: Bool) {
        isPremium = premium
    }
    
    func getRandomCoffeeShop(from shops: [CoffeeShop], userLocation: CLLocation) -> CoffeeShop? {
        let nearbyShops = shops.filter { shop in
            let shopLocation = CLLocation(latitude: shop.latitude, longitude: shop.longitude)
            let distance = userLocation.distance(from: shopLocation) / 1000
            return distance <= 50
        }
        return nearbyShops.first
    }
    
    func generateCoffeeRoute(from shops: [CoffeeShop]) -> [CoffeeShop] {
        Array(shops.prefix(3))
    }
    
    // Daily recommendation
    func getDailyRecommendation(from shops: [CoffeeShop]) -> CoffeeShop? {
        return shops.first
    }
    
    // Streak
    func updateStreak(visitDate: Date = Date()) {
        if userStreak.lastVisitDate == nil {
            userStreak.currentStreak = 1
            userStreak.longestStreak = 1
        } else {
            userStreak.currentStreak += 1
            if userStreak.currentStreak > userStreak.longestStreak {
                userStreak.longestStreak = userStreak.currentStreak
            }
        }
        userStreak.lastVisitDate = visitDate
    }
    
    // Purchases
    func purchaseTour(_ tourId: String) {
        purchasedTourIds.insert(tourId)
    }
    
    func hasPurchasedTour(_ tourId: String) -> Bool {
        return isPremium || purchasedTourIds.contains(tourId)
    }
    
    func purchaseGuide(_ guideId: String) {
        purchasedGuideIds.insert(guideId)
    }
    
    func hasPurchasedGuide(_ guideId: String) -> Bool {
        return purchasedGuideIds.contains(guideId)
    }
    
    // Achievements
    func unlockAchievement(_ achievementId: String) {
        if unlockedAchievements[achievementId] == nil {
            unlockedAchievements[achievementId] = Date()
        }
    }
    
    func isAchievementUnlocked(_ achievementId: String) -> Bool {
        return unlockedAchievements[achievementId] != nil
    }
    
    func getUnlockedDate(for achievementId: String) -> Date? {
        return unlockedAchievements[achievementId]
    }
}
