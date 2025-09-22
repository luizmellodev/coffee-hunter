//
//  CoffeeShop.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct CoffeeShop: Identifiable, Equatable, Codable, Hashable {

    var id: String {
        "\(name)-\(latitude)-\(longitude)".lowercased().replacingOccurrences(of: " ", with: "_")
    }
    
    let name: String
    let rating: Double
    let distance: Double
    let address: String
    let latitude: Double
    let longitude: Double
    var isLiked: Bool
    
    init(
        name: String,
        rating: Double,
        distance: Double,
        address: String,
        coordinates: CLLocationCoordinate2D,
        mapItem: MKMapItem
    ) {
        self.name = name
        self.rating = rating
        self.distance = distance
        self.address = address
        self.isLiked = false
        self.latitude = coordinates.latitude
        self.longitude = coordinates.longitude
    }
    
    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var mapItem: MKMapItem {
        let placemark = MKPlacemark(coordinate: coordinates)
        let item = MKMapItem(placemark: placemark)
        item.name = name
        return item
    }
    
    static func == (lhs: CoffeeShop, rhs: CoffeeShop) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var phoneNumber: String? {
        mapItem.phoneNumber
    }
    
    var website: URL? {
        mapItem.url
    }
}
