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
    @State private var isLiked = false
    @State private var showCheckInConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Image
                ZStack(alignment: .top) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.brown.opacity(0.3), .brown.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 250)
                    
                    VStack {
                        Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.brown)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 250)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Title and Rating
                    HStack {
                        Text(shop.name)
                            .font(.title)
                            .bold()
                        
                        Spacer()
                        
                        Button(action: { isLiked.toggle() }) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(isLiked ? .red : .primary)
                        }
                    }
                    
                    // Rating and Distance
                    HStack(spacing: 15) {
                        Label(String(format: "%.1f", shop.rating), systemImage: "star.fill")
                            .foregroundStyle(.yellow)
                        
                        Label(String(format: "%.1f km", shop.distance), systemImage: "location.fill")
                            .foregroundStyle(.brown)
                    }
                    
                    // Address
                    Label(shop.address, systemImage: "map")
                        .foregroundStyle(.secondary)
                    
                    // Phone (if available)
                    if let phone = shop.phoneNumber {
                        Label(phone, systemImage: "phone")
                            .foregroundStyle(.secondary)
                    }
                    
                    // Actions
                    HStack(spacing: 20) {
                        Button(action: {
                            shop.mapItem.openInMaps()
                        }) {
                            Label("Open in Maps", systemImage: "map.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.brown)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        if let url = shop.website {
                            Button(action: {
                                UIApplication.shared.open(url)
                            }) {
                                Label("Website", systemImage: "safari")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.brown)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding()
                
                VStack(alignment: .leading, spacing: 8) {
                    if visitCount > 0 {
                        Label("Visited \(visitCount) time\(visitCount == 1 ? "" : "s")", systemImage: "clock.fill")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if hasVisitedToday {
                        Label("Checked in today", systemImage: "checkmark.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: shareShop) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showCheckInConfirmation = true }) {
                    Label("Check In", systemImage: hasVisitedToday ? "checkmark.circle.fill" : "checkmark.circle")
                        .foregroundColor(hasVisitedToday ? .green : .primary)
                }
                .disabled(hasVisitedToday)
            }
        }
        .alert("Check In", isPresented: $showCheckInConfirmation) {
            Button("Yes, I'm here", role: .none) {
                viewModel.dataManager.addVisit(shop)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you currently at \(shop.name)?")
        }
    }
    
    private var hasVisitedToday: Bool {
        let calendar = Calendar.current
        return viewModel.dataManager.visitHistory.contains { visit in
            visit.shopName == shop.name &&
            calendar.isDateInToday(visit.date)
        }
    }
    
    private var visitCount: Int {
        viewModel.dataManager.visitHistory.filter { $0.shopName == shop.name }.count
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
