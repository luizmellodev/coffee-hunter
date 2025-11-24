//
//  AchievementRow.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked ?
                        LinearGradient(
                            colors: achievement.rarity.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
            Image(systemName: achievement.icon)
                    .font(.title3)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                Text(achievement.title)
                    .font(.headline)
                        .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                    
                    if achievement.isUnlocked {
                        // Rarity indicator
                        Circle()
                            .fill(achievement.rarity.color)
                            .frame(width: 8, height: 8)
                    }
                }
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // Progress bar if applicable
                if let progress = achievement.progress, let max = achievement.maxProgress {
                    VStack(alignment: .leading, spacing: 4) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 4)
                                    .clipShape(Capsule())
                                
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: achievement.isUnlocked ? 
                                                achievement.rarity.gradientColors : 
                                                [.brown, .brown.opacity(0.7)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * CGFloat(progress) / CGFloat(max), height: 4)
                                    .clipShape(Capsule())
                            }
                        }
                        .frame(height: 4)
                        
                        Text("\(progress)/\(max)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 2)
                }
                
                // Unlocked date if available
                if let date = achievement.unlockedDate {
                    Text("Unlocked on \(date.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            if achievement.isUnlocked {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundColor(achievement.rarity.color)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .opacity(achievement.isUnlocked ? 1 : 0.6)
    }
}
