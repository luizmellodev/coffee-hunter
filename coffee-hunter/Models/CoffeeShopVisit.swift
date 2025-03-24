//
//  CoffeeShopVisit.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import Foundation

struct CoffeeShopVisit: Codable, Identifiable {
    var id: UUID
    let shopName: String
    let date: Date
    
    init(shopName: String, date: Date) {
        self.id = UUID()
        self.shopName = shopName
        self.date = date
    }
}
