//
//  CoffeeTour.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import Foundation

struct CoffeeTour: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let city: String
    let country: String
    let duration: TourDuration
    let description: String
    let stops: [TourStop]
    let isPremium: Bool
    let price: Double?
    let estimatedDistance: Double // in kilometers
    let difficulty: TourDifficulty
    
    enum TourDuration: String, Codable, CaseIterable {
        case oneHour = "1h"
        case twoHours = "2h"
        case threeHours = "3h"
        
        var displayName: String {
            switch self {
            case .oneHour: return "1 hour"
            case .twoHours: return "2 hours"
            case .threeHours: return "3 hours"
            }
        }
        
        var minutes: Int {
            switch self {
            case .oneHour: return 60
            case .twoHours: return 120
            case .threeHours: return 180
            }
        }
    }
    
    enum TourDifficulty: String, Codable {
        case easy = "Easy"
        case moderate = "Moderate"
        case challenging = "Challenging"
        
        var icon: String {
            switch self {
            case .easy: return "figure.walk"
            case .moderate: return "figure.hiking"
            case .challenging: return "figure.run"
            }
        }
    }
}

// Sample tours for Porto Alegre and Curitiba
extension CoffeeTour {
    static let sampleTours: [CoffeeTour] = [
        // Porto Alegre Tours
        CoffeeTour(
            id: "poa-classic-1h",
            name: "Porto Alegre Classic",
            city: "Porto Alegre",
            country: "Brazil",
            duration: .oneHour,
            description: "A quick tour through the best specialty coffee spots in the historic center of Porto Alegre.",
            stops: [
                TourStop(
                    id: "poa-stop-1",
                    shopName: "Octopus Coffee",
                    order: 1,
                    latitude: -30.0346,
                    longitude: -51.2177,
                    description: "Start your journey at Octopus, one of Porto Alegre's pioneering specialty coffee shops. Known for their excellent pour-overs and friendly baristas who are always happy to chat about coffee origins.",
                    recommendedItem: "V60 Pour Over - Ethiopian",
                    estimatedTimeMinutes: 20
                ),
                TourStop(
                    id: "poa-stop-2",
                    shopName: "Kaffa Café Especial",
                    order: 2,
                    latitude: -30.0368,
                    longitude: -51.2065,
                    description: "A cozy spot in Moinhos de Vento neighborhood. Perfect for understanding the difference between light and dark roasts. The space has a minimalist design with great natural lighting.",
                    recommendedItem: "Flat White with house blend",
                    estimatedTimeMinutes: 20
                ),
                TourStop(
                    id: "poa-stop-3",
                    shopName: "Armazém do Café",
                    order: 3,
                    latitude: -30.0277,
                    longitude: -51.2287,
                    description: "End your tour at this charming coffee shop that also sells beans and equipment. Great place to buy souvenirs and learn about home brewing. They often have coffee tastings on weekends.",
                    recommendedItem: "Espresso Tonic",
                    estimatedTimeMinutes: 20
                )
            ],
            isPremium: true,
            price: 12.90,
            estimatedDistance: 2.5,
            difficulty: .easy
        ),
        CoffeeTour(
            id: "poa-moinhos-2h",
            name: "Moinhos de Vento Explorer",
            city: "Porto Alegre",
            country: "Brazil",
            duration: .twoHours,
            description: "Explore the trendy Moinhos de Vento neighborhood and its amazing coffee culture.",
            stops: [
                TourStop(
                    id: "poa-moinhos-1",
                    shopName: "Café do Mercado",
                    order: 1,
                    latitude: -30.0255,
                    longitude: -51.2065,
                    description: "Located inside a beautiful historic market building. This café offers a unique experience combining specialty coffee with local pastries. The atmosphere is lively and perfect for people-watching.",
                    recommendedItem: "Cappuccino with homemade croissant",
                    estimatedTimeMinutes: 30
                ),
                TourStop(
                    id: "poa-moinhos-2",
                    shopName: "Santo Grão",
                    order: 2,
                    latitude: -30.0312,
                    longitude: -51.2098,
                    description: "A hidden gem in a quiet street. Known for their cold brew variations and experimental drinks. The baristas here love to create custom drinks based on your preferences.",
                    recommendedItem: "Nitro Cold Brew",
                    estimatedTimeMinutes: 25
                ),
                TourStop(
                    id: "poa-moinhos-3",
                    shopName: "Café Cultura",
                    order: 3,
                    latitude: -30.0287,
                    longitude: -51.2134,
                    description: "More than just a coffee shop - they also host art exhibitions and live music. Great for afternoon visits. The space has high ceilings and a bohemian vibe.",
                    recommendedItem: "Aeropress with Brazilian single origin",
                    estimatedTimeMinutes: 30
                ),
                TourStop(
                    id: "poa-moinhos-4",
                    shopName: "Bloom Coffee Roasters",
                    order: 4,
                    latitude: -30.0334,
                    longitude: -51.2156,
                    description: "Finish at this roastery where you can see the roasting process and learn about green bean selection. They offer tours on Saturdays. Best place to buy fresh beans to take home.",
                    recommendedItem: "Coffee flight tasting",
                    estimatedTimeMinutes: 35
                )
            ],
            isPremium: true,
            price: 15.90,
            estimatedDistance: 4.0,
            difficulty: .moderate
        ),
        
        // Curitiba Tours
        CoffeeTour(
            id: "cwb-centro-1h",
            name: "Curitiba Centro",
            city: "Curitiba", country: "Brazil",
            duration: .oneHour,
            description: "Discover specialty coffee gems in the heart of Curitiba.",
            stops: [],
            isPremium: true,
            price: 12.90,
            estimatedDistance: 2.0,
            difficulty: .easy
        ),
        CoffeeTour(
            id: "cwb-batel-3h",
            name: "Batel Complete Experience",
            city: "Curitiba", country: "Brazil",
            duration: .threeHours,
            description: "A comprehensive coffee journey through Batel's finest cafés.",
            stops: [],
            isPremium: true,
            price: 18.90,
            estimatedDistance: 5.5,
            difficulty: .challenging
        )
    ]
}

