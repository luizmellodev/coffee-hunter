//
//  CityToursView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI

struct CityToursView: View {
    let city: CoffeeCity
    @ObservedObject var viewModel: CoffeeHunterViewModel
    
    private var tours: [CoffeeTour] {
        viewModel.getAvailableTours(forCity: city.name)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                headerSection
                
                // Tours list
                VStack(spacing: 16) {
                    ForEach(tours) { tour in
                        NavigationLink(destination: TourDetailView(tour: tour, viewModel: viewModel)) {
                            TourCard(tour: tour, isPurchased: viewModel.hasPurchasedTour(tour))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // Support info
                supportInfoCard
            }
            .padding()
        }
        .navigationTitle(city.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(city.emoji)
                    .font(.system(size: 50))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(city.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(city.country)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Text("\(tours.count) curated tour\(tours.count == 1 ? "" : "s") available")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.brown.opacity(0.15), Color.brown.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
    
    private var supportInfoCard: some View {
        VStack(alignment: .center, spacing: 12) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
                
                Text("Support the Project")
                    .font(.headline)
            }
            
            Text("Tours are carefully curated to help you discover the best specialty coffee. Your purchase supports app development!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.pink.opacity(0.3), lineWidth: 1)
        )
    }
}

