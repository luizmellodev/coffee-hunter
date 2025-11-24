//
//  DailyRecommendation.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import Foundation

struct DailyRecommendation: Codable {
    let shopId: String
    let date: Date
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

