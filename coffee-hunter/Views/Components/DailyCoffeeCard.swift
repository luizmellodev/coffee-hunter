//
//  DailyCoffeeCard.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI

struct DailyCoffeeCard: View {
    let shop: CoffeeShop
    let viewModel: CoffeeHunterViewModel
    
    var body: some View {
        Button {
            viewModel.selectedCoffeeShop = shop
            viewModel.navigateToMapWithShop(shop)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Header with icon
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .yellow],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "sun.max.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("☕️ Coffee of the Day")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Image(systemName: "sparkles")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        
                        Text("Special recommendation for today")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                
                Divider()
                
                // Shop info
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(shop.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text(String(format: "%.1f", shop.rating))
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    
                    HStack(spacing: 12) {
                        Label(
                            String(format: "%.1f km", shop.distance),
                            systemImage: "location.fill"
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        if viewModel.hasVisitedToday(shop) {
                            Label("Visited today", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    
                    // CTA
                    HStack {
                        Spacer()
                        
                        Text("View on map")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.brown)
                        
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundColor(.brown)
                    }
                }
                .padding()
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [.orange.opacity(0.5), .yellow.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: .orange.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

