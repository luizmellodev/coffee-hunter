import Foundation
import CoreLocation
import MapKit
@testable import coffee_hunter

class MockCoffeeHunterDataManager: CoffeeHunterDataManaging {
    var favorites: [CoffeeShop] = []
    var visitHistory: [CoffeeShopVisit] = []
    var isPremium: Bool = false
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
}
