import Foundation
import CoreLocation
import MapKit
@testable import coffee_hunter

class MockCoffeeShopService: CoffeeShopServicing {
    var coffeeShops: [CoffeeShop] = []
    var lastFetchedLocation: CLLocationCoordinate2D?
    
    func fetchNearbyCoffeeShops(near location: CLLocationCoordinate2D) {
        lastFetchedLocation = location
        coffeeShops = [
            CoffeeShop.mock(distance: 1.0),
            CoffeeShop.mock(distance: 2.0),
            CoffeeShop.mock(distance: 3.0)
        ]
    }
    
    func formatAddress(_ placemark: MKPlacemark) -> String {
        let street = placemark.thoroughfare ?? ""
        let number = placemark.subThoroughfare ?? ""
        return "\(number) \(street)".trimmingCharacters(in: .whitespaces)
    }
}
