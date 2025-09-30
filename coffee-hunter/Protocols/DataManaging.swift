import Foundation
import CoreLocation
import MapKit

protocol CoffeeHunterDataManaging {
    var favorites: [CoffeeShop] { get }
    var visitHistory: [CoffeeShopVisit] { get }
    var isPremium: Bool { get }
    
    func addFavorite(_ shop: CoffeeShop)
    func removeFavorite(_ shop: CoffeeShop)
    func addVisit(_ shop: CoffeeShop)
    func clearVisitHistory()
    func setPremiumStatus(_ premium: Bool)
    func getRandomCoffeeShop(from shops: [CoffeeShop], userLocation: CLLocation) -> CoffeeShop?
    func generateCoffeeRoute(from shops: [CoffeeShop]) -> [CoffeeShop]
}

protocol CoffeeShopServicing {
    var coffeeShops: [CoffeeShop] { get }
    func fetchNearbyCoffeeShops(near location: CLLocationCoordinate2D)
    func formatAddress(_ placemark: MKPlacemark) -> String
}
