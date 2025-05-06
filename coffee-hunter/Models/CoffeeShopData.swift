
import Foundation
import MapKit

class CoffeeShopData: ObservableObject {
    static var shared = CoffeeShopData()
    
    @Published var shopData: [String: ShopMetadata] = [:]
    
    struct ShopMetadata: Codable {
        var isLiked: Bool
        var rating: Double
        var distance: Double
    }
    
    func id(for item: MKMapItem) -> String {
        "\(item.name ?? "")-\(item.placemark.coordinate.latitude)-\(item.placemark.coordinate.longitude)"
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
    }
    
    func metadata(for item: MKMapItem) -> ShopMetadata {
        shopData[id(for: item)] ?? ShopMetadata(isLiked: false, rating: Double.random(in: 3.5...5.0), distance: 0)
    }
    
    func updateMetadata(for item: MKMapItem, isLiked: Bool? = nil, rating: Double? = nil, distance: Double? = nil) {
        let shopId = id(for: item)
        var current = metadata(for: item)
        
        if let isLiked = isLiked { current.isLiked = isLiked }
        if let rating = rating { current.rating = rating }
        if let distance = distance { current.distance = distance }
        
        shopData[shopId] = current
    }
}
