//
//  StreakCard.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI

struct StreakCard: View {
    let streak: UserStreak
    
    var body: some View {
        HStack(spacing: 16) {
            // Fire icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: streak.currentStreak > 0 ? 
                                [.orange, .red] : 
                                [.gray.opacity(0.3), .gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: "flame.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .symbolEffect(.pulse, options: .repeating, value: streak.currentStreak)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("\(streak.currentStreak)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(streak.currentStreak > 0 ? .orange : .secondary)
                        .contentTransition(.numericText())
                    
                    Text(streak.currentStreak == 1 ? "day" : "days")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                Text("Current streak")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if streak.longestStreak > streak.currentStreak {
                    Text("Record: \(streak.longestStreak) days")
                        .font(.caption2)
                        .foregroundColor(.orange)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            if streak.currentStreak > 0 {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("🔥")
                        .font(.title)
                    Text("Keep it up!")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    streak.currentStreak > 0 ? 
                        Color.orange.opacity(0.3) : 
                        Color.clear,
                    lineWidth: 2
                )
        )
    }
}

