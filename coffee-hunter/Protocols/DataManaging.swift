import Foundation
import CoreLocation
import MapKit

protocol CoffeeHunterDataManaging {
    var favorites: [CoffeeShop] { get }
    var visitHistory: [CoffeeShopVisit] { get }
    var isPremium: Bool { get }
    var userStreak: UserStreak { get }
    var dailyRecommendation: DailyRecommendation? { get }
    var purchasedTourIds: Set<String> { get }
    var purchasedGuideIds: Set<String> { get }
    var unlockedAchievements: [String: Date] { get }
    
    func addFavorite(_ shop: CoffeeShop)
    func removeFavorite(_ shop: CoffeeShop)
    func addVisit(_ shop: CoffeeShop)
    func clearVisitHistory()
    func setPremiumStatus(_ premium: Bool)
    func getRandomCoffeeShop(from shops: [CoffeeShop], userLocation: CLLocation) -> CoffeeShop?
    func generateCoffeeRoute(from shops: [CoffeeShop]) -> [CoffeeShop]
    
    // Daily recommendation
    func getDailyRecommendation(from shops: [CoffeeShop]) -> CoffeeShop?
    
    // Streak
    func updateStreak(visitDate: Date)
    
    // Purchases
    func purchaseTour(_ tourId: String)
    func hasPurchasedTour(_ tourId: String) -> Bool
    func purchaseGuide(_ guideId: String)
    func hasPurchasedGuide(_ guideId: String) -> Bool
    
    // Achievements
    func unlockAchievement(_ achievementId: String)
    func isAchievementUnlocked(_ achievementId: String) -> Bool
    func getUnlockedDate(for achievementId: String) -> Date?
}

protocol CoffeeShopServicing {
    var coffeeShops: [CoffeeShop] { get }
    func fetchNearbyCoffeeShops(near location: CLLocationCoordinate2D)
    func formatAddress(_ placemark: MKPlacemark) -> String
}
