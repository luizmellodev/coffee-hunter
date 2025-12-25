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
        viewModel.getAchievements()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    statsSection
                        .padding(.horizontal)
                    
                    // Streak section
                    StreakInfoView(streak: viewModel.userStreak)
                        .padding(.horizontal)
                    
                    VStack(spacing: 25) {
                        achievementsSection
                        actionsSection
                        aboutSection
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .stroke(Color(.separator), lineWidth: 0.5)
                    )
                }
                .padding(.vertical)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Profile")
            .sheet(isPresented: $showingLocationPicker) {
                LocationPickerView(viewModel: viewModel)
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
                    count: viewModel.visitHistory.count,
                    title: "Visits",
                    icon: "checkmark.circle.fill"
                )
                statItem(count: viewModel.favorites.count, title: "Favorites", icon: "heart.fill")
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
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Achievements")
                    .font(.title3)
                    .bold()
                
                Spacer()
                
                Text("\(achievements.filter(\.isUnlocked).count)/\(achievements.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemBackground))
                    .clipShape(Capsule())
            }
            
            ForEach(achievements) { achievement in
                AchievementRow(achievement: achievement)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.separator), lineWidth: 0.5)
                    )
            }
        }
    }
    
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.title3)
                .bold()
            
            VStack(spacing: 12) {
                NavigationLink(destination: FavoritesView(viewModel: viewModel)) {
                    ActionButton(title: "My Favorites", icon: "heart.fill", color: .pink)
                }
                
                NavigationLink(destination: VisitHistoryView(viewModel: viewModel)) {
                    ActionButton(title: "Visit History", icon: "clock.fill", color: .brown)
                }
                
            VStack(spacing: 8) {
                Button(action: { showingLocationPicker = true }) {
                    ActionButton(
                        title: viewModel.isLocationThrottled ? 
                            "Please wait \(viewModel.throttleTimeRemaining)s" : 
                            "Change Location",
                        icon: "location.fill",
                        color: viewModel.isLocationThrottled ? .gray : .blue
                    )
                }
                .disabled(viewModel.isLocationThrottled)
                
                if viewModel.selectedLocation != nil {
                    Button(action: { viewModel.clearCustomLocation() }) {
                        Text("Reset to Current Location")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .disabled(viewModel.isLocationThrottled)
                }
                
                if viewModel.isLocationThrottled {
                    Text("Too many location searches. Please wait.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            }
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.brown)
                Text("About Coffee Shop Search")
                    .font(.title3)
                    .bold()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Coffee Hunter uses Apple Maps to find nearby cafes. While we find most popular coffee shops, some smaller or newer cafes might not appear in search results due to Apple Maps limitations.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundColor(.pink)
                    Text("Missing a favorite spot?")
                        .font(.subheadline)
                        .bold()
                }
                
                Text("We're working on features to let you add your favorite local cafes manually. Stay tuned for updates!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.brown.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private func calculateUniquePlaces() -> Int {
        viewModel.getUniqueVisitedPlaces()
    }
}
