//
//  CoffeeCity.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import Foundation

struct CoffeeCity: Identifiable, Hashable {
    let id: String
    let name: String
    let country: String
    let tourCount: Int
    let emoji: String
    
    var displayName: String {
        "\(name), \(country)"
    }
}

