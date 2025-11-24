//
//  TourDetailView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI

struct TourDetailView: View {
    let tour: CoffeeTour
    @ObservedObject var viewModel: CoffeeHunterViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showPurchaseAlert = false
    @State private var isPurchasing = false
    
    private var isPurchased: Bool {
        viewModel.hasPurchasedTour(tour)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Hero section
                heroSection
                
                // Tour info
                tourInfoSection
                
                // Description
                descriptionSection
                
                // Stops as Roadmap (only if purchased)
                if isPurchased && !tour.stops.isEmpty {
                    roadmapSection
                }
                
                // View Route button (if purchased and has stops)
                if isPurchased && !tour.stops.isEmpty {
                    viewRouteButton
                }
                
                // Purchase/Access button
                actionButton
            }
            .padding()
        }
        .navigationTitle(tour.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Purchase Tour", isPresented: $showPurchaseAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Purchase R$ \(String(format: "%.2f", tour.price ?? 0))") {
                purchaseTour()
            }
        } message: {
            Text("Would you like to purchase the \"\(tour.name)\" tour? This purchase supports app development.")
        }
    }
    
    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("\(tour.city), \(tour.country)", systemImage: "mappin.and.ellipse")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if isPurchased {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Purchased")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.brown.opacity(0.2), Color.brown.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
    
    private var tourInfoSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                infoItem(
                    icon: "clock.fill",
                    title: "Duration",
                    value: tour.duration.displayName,
                    color: .blue
                )
                
                infoItem(
                    icon: "map.fill",
                    title: "Distance",
                    value: "\(String(format: "%.1f", tour.estimatedDistance)) km",
                    color: .green
                )
                
                infoItem(
                    icon: tour.difficulty.icon,
                    title: "Difficulty",
                    value: tour.difficulty.rawValue,
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func infoItem(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About this tour")
                .font(.title3)
                .fontWeight(.bold)
            
            Text(tour.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
    
    private var roadmapSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Coffee Trail")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            LazyVStack(spacing: 0) {
                ForEach(Array(tour.stops.enumerated()), id: \.element.id) { index, stop in
                    NavigationLink(destination: TourStopDetailView(stop: stop, stopNumber: index + 1)) {
                        TourRoadmapItem(
                            stop: stop,
                            number: index + 1,
                            direction: index % 2 == 0 ? .left : .right,
                            isFirstItem: index == 0,
                            isLastItem: index == tour.stops.count - 1
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var viewRouteButton: some View {
        NavigationLink(destination: TourMapView(tour: tour)) {
            HStack {
                Image(systemName: "map.fill")
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("View on Map")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        // BETA badge
                        Text("BETA")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    Text("Interactive map with walking route")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.caption)
            }
            .foregroundColor(.primary)
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.brown.opacity(0.15), Color.brown.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.brown.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var actionButton: some View {
        Group {
            if !isPurchased {
                VStack(spacing: 16) {
                    // Support message
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.brown)
                            Text("Support the Project")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        
                        Text("This tour is a curated experience to help you discover the best specialty coffee spots. Your purchase helps keep this project alive and supports ongoing development!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.brown.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Purchase button
                    Button {
                        showPurchaseAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "lock.open.fill")
                            Text("Unlock for R$ \(String(format: "%.2f", tour.price ?? 0))")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brown)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(isPurchasing)
                }
            }
        }
    }
    
    private func purchaseTour() {
        isPurchasing = true
        
        viewModel.purchaseTour(tour) { success in
            isPurchasing = false
            if success {
                // Show success feedback
            }
        }
    }
}

