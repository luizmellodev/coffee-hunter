//
//  ProfileView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: CoffeeHunterViewModel
    @State private var showingLocationPicker = false
    
    private var achievements: [Achievement] {
        [
            Achievement(
                title: "Coffee Explorer",
                description: "Visit 5 different coffee shops",
                icon: "map.fill",
                isUnlocked: viewModel.dataManager.visitHistory.count >= 5
            ),
            Achievement(
                title: "Coffee Enthusiast",
                description: "Add 10 coffee shops to favorites",
                icon: "heart.fill",
                isUnlocked: viewModel.dataManager.favorites.count >= 10
            ),
            Achievement(
                title: "Regular Customer",
                description: "Visit the same coffee shop 3 times",
                icon: "star.fill",
                isUnlocked: checkRegularCustomer()
            )
        ]
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    statsSection
                    achievementsSection
                    actionsSection
                }
                .padding()
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingLocationPicker) {
                Text("Location Picker Coming Soon")
            }
        }
    }
    
    private var statsSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.brown, .brown.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Text("CH")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
            .overlay {
                Circle()
                    .stroke(Color.brown.opacity(0.3), lineWidth: 4)
                    .frame(width: 110, height: 110)
            }
            
            Text("Coffee Hunter")
                .font(.title2)
                .bold()
            
            HStack(spacing: 30) {
                statItem(
                    count: viewModel.dataManager.visitHistory.count,
                    title: "Visits",
                    icon: "checkmark.circle.fill"
                )
                statItem(count: viewModel.dataManager.favorites.count, title: "Favorites", icon: "heart.fill")
                statItem(count: calculateUniquePlaces(), title: "Places", icon: "map.fill")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func statItem(count: Int, title: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.brown)
                .symbolEffect(.bounce, value: count)
            
            Text("\(count)")
                .font(.title2)
                .bold()
                .contentTransition(.numericText())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .contentShape(Rectangle())
        .hoverEffect(.lift)
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(.title3)
                .bold()
                .padding(.horizontal)
            
            ForEach(achievements) { achievement in
                AchievementRow(achievement: achievement)
            }
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            NavigationLink(destination: FavoritesView(viewModel: viewModel)) {
                ActionButton(title: "My Favorites", icon: "heart.fill", color: .pink)
            }
            
            NavigationLink(destination: VisitHistoryView(viewModel: viewModel)) {
                ActionButton(title: "Visit History", icon: "clock.fill", color: .brown)
            }
            
            Button(action: { showingLocationPicker = true }) {
                ActionButton(title: "Change Location", icon: "location.fill", color: .blue)
            }
        }
    }
    
    private func calculateUniquePlaces() -> Int {
        Set(viewModel.dataManager.visitHistory.map { $0.shopName }).count
    }
    
    private func checkRegularCustomer() -> Bool {
        let visits = viewModel.dataManager.visitHistory
        let shopVisits = Dictionary(grouping: visits, by: { $0.shopName })
        return shopVisits.values.contains(where: { $0.count >= 3 })
    }
}
