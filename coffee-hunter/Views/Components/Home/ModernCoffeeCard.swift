//
//  ModernCoffeeCard.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 26/03/25.
//

import SwiftUI

struct ModernCoffeeCard: View {
    let shop: CoffeeShop
    @ObservedObject var viewModel: CoffeeHunterViewModel
    @State private var showDetail = false
    @State private var isHovered = false
    
    private var isFavorite: Bool {
        viewModel.favorites.contains(where: { $0.id == shop.id })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.brown.opacity(0.2), .brown.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.brown, .brown.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    if isFavorite {
                        Label("Favorite", systemImage: "heart.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    
                    if shop.rating >= 4.5 {
                        Label("Top Rated", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.yellow.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    
                    if shop.distance <= 1.0 {
                        Label("Nearby", systemImage: "location.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(shop.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", shop.rating))
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.brown)
                        Text(String(format: "%.1f km", shop.distance))
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                }
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            HStack(spacing: 12) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        viewModel.toggleFavorite(shop)
                    }
                } label: {
                    HStack {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .symbolEffect(.bounce, value: isFavorite)
                        Text(isFavorite ? "Saved" : "Save")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isFavorite ? .red : .brown)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                }
                
                Button {
                    viewModel.navigateToMapWithShop(shop)
                } label: {
                    HStack {
                        Image(systemName: "map.fill")
                        Text("View")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.brown)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .id("card-\(shop.id)-\(isFavorite)")
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            showDetail = true
        }
        .sheet(isPresented: $showDetail) {
            NavigationView {
                CoffeeShopDetailView(shop: shop, viewModel: viewModel)
            }
        }
    }
}
