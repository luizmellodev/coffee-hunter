//
//  TourStop.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import Foundation
import CoreLocation

struct TourStop: Identifiable, Codable, Hashable {
    let id: String
    let shopName: String
    let order: Int
    let latitude: Double
    let longitude: Double
    let description: String
    let recommendedItem: String?
    let estimatedTimeMinutes: Int
    
    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

