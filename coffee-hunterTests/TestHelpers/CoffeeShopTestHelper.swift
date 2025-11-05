import Foundation
import CoreLocation
import MapKit
@testable import coffee_hunter

extension CoffeeShop {
    static func mock(
        id: String = UUID().uuidString,
        name: String = "Test Coffee Shop",
        rating: Double = 4.5,
        distance: Double = 1.0,
        address: String = "123 Test St",
        latitude: Double = 0.0,
        longitude: Double = 0.0
    ) -> CoffeeShop {
        CoffeeShop(
            name: name,
            rating: rating,
            distance: distance,
            address: address,
            coordinates: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            mapItem: MKMapItem(
                placemark: MKPlacemark(
                    coordinate: CLLocationCoordinate2D(
                        latitude: latitude,
                        longitude: longitude
                    )
                )
            )
        )
    }
}
