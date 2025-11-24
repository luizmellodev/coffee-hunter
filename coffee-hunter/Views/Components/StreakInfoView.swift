//
//  StreakInfoView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI

struct StreakInfoView: View {
    let streak: UserStreak
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Your Streak")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
            }
            
            VStack(spacing: 16) {
                statRow(
                    icon: "flame.fill",
                    title: "Current Streak",
                    value: "\(streak.currentStreak) days",
                    color: .orange
                )
                
                Divider()
                
                statRow(
                    icon: "trophy.fill",
                    title: "Longest Streak",
                    value: "\(streak.longestStreak) days",
                    color: .yellow
                )
                
                if let lastVisit = streak.lastVisitDate {
                    Divider()
                    
                    statRow(
                        icon: "calendar",
                        title: "Last Visit",
                        value: lastVisit.formatted(date: .abbreviated, time: .omitted),
                        color: .blue
                    )
                }
            }
            
            if streak.currentStreak == 0 {
                VStack(spacing: 8) {
                    Text("💡 Tip")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text("Visit a coffee shop today to start your streak!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func statRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline)
            }
            
            Spacer()
        }
    }
}

