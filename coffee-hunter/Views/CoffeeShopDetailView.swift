//
//  CoffeeShopDetailView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct CoffeeShopDetailView: View {
    let shop: CoffeeShop
    @ObservedObject var viewModel: CoffeeHunterViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showCheckInConfirmation = false
    @State private var showContent = false
    
    private var isFavorite: Bool {
        viewModel.isFavorite(shop)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Section
                heroSection
                
                // Content
                VStack(spacing: 24) {
                    // Quick Actions
                    quickActionsSection
                    
                    // Info Cards
                    infoCardsSection
                    
                    // Visit History
                    if visitCount > 0 {
                        visitHistorySection
                    }
                    
                    // Action Buttons
                    actionButtonsSection
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                .offset(y: -25)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarItems
        }
        .alert("Check In", isPresented: $showCheckInConfirmation) {
            Button("Yes, I'm here", role: .none) {
                viewModel.addVisit(shop)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you currently at \(shop.name)?")
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
    }
    
    private var heroSection: some View {
        ZStack(alignment: .top) {
            // Background
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.4, green: 0.2, blue: 0.1), // Darker brown
                            Color(red: 0.6, green: 0.4, blue: 0.3)  // Lighter brown
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Rectangle()
                        .fill(.black.opacity(0.3)) // Additional overlay for better contrast
                )
                .frame(height: 300)
            
            // Content
            VStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color(.systemBackground))
                        .frame(width: 100, height: 100)
                        .shadow(color: .black.opacity(0.1), radius: 10)
                    
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.brown, .brown.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .padding(.top, 60)
                
                // Title
                Text(shop.name)
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
                
                // Rating and Distance
                HStack(spacing: 16) {
                    Label(String(format: "%.1f", shop.rating), systemImage: "star.fill")
                        .foregroundStyle(.yellow)
                    
                    Label(String(format: "%.1f km", shop.distance), systemImage: "location.fill")
                        .foregroundStyle(.white)
                }
                .font(.headline)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
        }
    }
    
    private var quickActionsSection: some View {
        HStack(spacing: 16) {
            // Favorite Button
            Button {
                viewModel.toggleFavorite(shop)
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.title2)
                        .foregroundColor(isFavorite ? .red : .primary)
                    
                    Text(isFavorite ? "Saved" : "Save")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Check-in Button
            Button {
                showCheckInConfirmation = true
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: hasVisitedToday ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(hasVisitedToday ? .green : .primary)
                    
                    Text("Check In")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(hasVisitedToday)
            
            // Share Button
            Button(action: shareShop) {
                VStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                    
                    Text("Share")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
    }
    
    private var infoCardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Address
            infoCard(icon: "map", title: "Address", content: shop.address)
            
            // Phone
            if let phone = shop.phoneNumber {
                infoCard(icon: "phone", title: "Phone", content: phone)
            }
            
            // Website
            if let website = shop.website {
                Button {
                    UIApplication.shared.open(website)
                } label: {
                    infoCard(icon: "safari", title: "Website", content: website.absoluteString)
                }
            }
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
    }
    
    private func infoCard(icon: String, title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(content)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var visitHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Visit History")
                .font(.headline)
            
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("\(visitCount)")
                        .font(.title)
                        .bold()
                    Text("Total Visits")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                if hasVisitedToday {
                    VStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.green)
                        Text("Visited Today")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.navigateToMapWithShop(shop)
                dismiss()
            } label: {
                Label("View on Map", systemImage: "map")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brown)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button {
                shop.mapItem.openInMaps(launchOptions: [
                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                ])
            } label: {
                Label("Get Directions", systemImage: "location.fill")
                    .font(.headline)
                    .foregroundColor(.brown)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brown.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
    }
    
    private var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    private var hasVisitedToday: Bool {
        viewModel.hasVisitedToday(shop)
    }
    
    private var visitCount: Int {
        viewModel.getVisitCount(for: shop)
    }
    
    private func shareShop() {
        let shareText = "Check out \(shop.name) on Coffee Hunter! Rating: \(shop.rating)★\nAddress: \(shop.address)"
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: shop.coordinates))
        mapItem.name = shop.name
        
        let activityItems: [Any] = [shareText, mapItem]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController
        else { return }
        
        rootVC.present(activityVC, animated: true)
    }
}