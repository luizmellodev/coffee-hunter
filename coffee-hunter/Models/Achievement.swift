//
//  Achievement.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import Foundation
import SwiftUI

struct Achievement: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
    let category: AchievementCategory
    let progress: Int?
    let maxProgress: Int?
    let unlockedDate: Date?
    let rarity: AchievementRarity
    
    enum AchievementCategory: String, Codable {
        case exploration = "Exploration"
        case social = "Social"
        case dedication = "Dedication"
        case collection = "Collection"
        case special = "Special"
    }
    
    enum AchievementRarity: String, Codable {
        case common = "Common"
        case rare = "Rare"
        case epic = "Epic"
        case legendary = "Legendary"
        
        var color: Color {
            switch self {
            case .common: return .gray
            case .rare: return .blue
            case .epic: return .purple
            case .legendary: return .orange
            }
        }
        
        var gradientColors: [Color] {
            switch self {
            case .common: return [.gray, .gray.opacity(0.6)]
            case .rare: return [.blue, .cyan]
            case .epic: return [.purple, .pink]
            case .legendary: return [.orange, .yellow]
            }
        }
    }
    
    var progressText: String? {
        guard let progress = progress, let max = maxProgress else { return nil }
        return "\(progress)/\(max)"
    }
    
    var isComplete: Bool {
        if let progress = progress, let max = maxProgress {
            return progress >= max
        }
        return isUnlocked
    }
}
