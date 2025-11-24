//
//  UserStreak.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import Foundation

struct UserStreak: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var lastVisitDate: Date?
    
    static var empty: UserStreak {
        UserStreak(currentStreak: 0, longestStreak: 0, lastVisitDate: nil)
    }
}

